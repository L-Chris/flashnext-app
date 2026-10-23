package com.rethinkos.flashnext_app

import android.os.Build
import java.io.File
import java.io.IOException
import java.io.EOFException
import java.net.SocketTimeoutException
import java.security.MessageDigest
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference
import kotlinx.coroutines.*
import okhttp3.*
import okhttp3.HttpUrl.Companion.toHttpUrl
import org.json.JSONObject
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

fun trustedReleaseUrl(address: String, file: String? = null): Boolean = runCatching {
    val u=address.toHttpUrl()
    u.scheme=="https" && u.host=="github.com" && u.port==443 && u.username.isEmpty() && u.password.isEmpty() &&
        u.query==null && u.fragment==null && u.encodedPath.startsWith("/$RELEASE_REPOSITORY/releases/download/") &&
        u.pathSegments.size==6 && parseVersion(u.pathSegments[4])!=null && (file==null || u.pathSegments.last()==file)
}.getOrDefault(false)
fun checksumFor(text: String, fileName: String): String {
    val entries=text.lineSequence().mapNotNull { Regex("^([0-9a-fA-F]{64})\\s+\\*?(?:\\./)?([^/\\\\]+)$").matchEntire(it.trim()) }
        .filter { it.groupValues[2]==fileName }.map { it.groupValues[1].lowercase() }.toList()
    require(entries.size==1) { "未找到安装包校验值" }; return entries.single()
}
fun sha256(file: File): String = MessageDigest.getInstance("SHA-256").let { digest ->
    file.inputStream().use { input -> val buffer=ByteArray(32*1024); while(true) { val count=input.read(buffer); if(count<0) break; digest.update(buffer,0,count) } }
    digest.digest().joinToString("") { "%02x".format(it) }
}
interface UpdateSource {
    suspend fun latest(): Update?
    suspend fun download(update: Update, directory: File, status: (TransferStatus) -> Unit = {}, progress: (Long,Long) -> Unit): DownloadedUpdate
    fun cancel() {}
    fun close() { cancel() }
}
data class DownloadedUpdate(val file: File, val update: Update)

/** No private server URL or credentials are used by the updater. */
class GitHubUpdateSource(private val client: OkHttpClient = OkHttpClient.Builder().retryOnConnectionFailure(true)
    .followRedirects(false).connectTimeout(15,TimeUnit.SECONDS).readTimeout(45,TimeUnit.SECONDS).callTimeout(2,TimeUnit.MINUTES).build(),
    private val endpoint: String = "https://api.github.com/repos/$RELEASE_REPOSITORY/releases/latest",
    private val current: String = BuildConfig.VERSION_NAME, private val abis: List<String> = Build.SUPPORTED_ABIS.toList(),
    private val policy: TransferPolicy = TransferPolicy()) : UpdateSource {
    private suspend fun <T> read(url: String, resource: UpdateResource, offset: Long=0, consume: (Response) -> T): T = suspendCancellableCoroutine { continuation ->
        val request=Request.Builder().url(url).header("User-Agent","FlashNext-Android")
            .header("Accept",if(url==endpoint) "application/vnd.github+json" else "application/octet-stream")
            .apply { if(resource!=UpdateResource.RELEASE) header("Accept-Encoding","identity"); if(offset>0) header("Range","bytes=$offset-") }.build()
        val call=client.newCall(request)
        if(resource==UpdateResource.RELEASE) call.timeout().timeout(45,TimeUnit.SECONDS)
        fun networkError(error: IOException) = if(error is UpdateTransportException || error is UpdateHttpException) error else UpdateTransportException(resource,request.url.host,error)
        continuation.invokeOnCancellation { call.cancel() }
        call.enqueue(object: Callback {
            override fun onFailure(call: Call,e: IOException) { if(continuation.isActive) continuation.resumeWithException(networkError(e)) }
            override fun onResponse(call: Call,response: Response) {
                try { val result=response.use(consume); if(continuation.isActive) continuation.resume(result) }
                catch(e: Exception) { if(continuation.isActive) continuation.resumeWithException(if(e is IOException) networkError(e) else e) }
            }
        })
    }
    override suspend fun latest(): Update? = read(endpoint,UpdateResource.RELEASE) { r ->
        if(r.code==404) null else {
            check(r.isSuccessful) { if(r.code in listOf(403,429)) "检查过于频繁，请稍后再试" else "无法连接 GitHub (${r.code})" }
            parseUpdate(JSONObject(r.body!!.byteStream().readBounded(1024*1024).toString(Charsets.UTF_8)),current,abis)
        }
    }
    private suspend fun <T> asset(url: String, assetId: Long, resource: UpdateResource, attempt: Int, status: (TransferStatus) -> Unit,
        offset: Long=0, consume: (Response) -> T): T {
        require(trustedReleaseUrl(url)) { "更新下载地址无效" }
        // The public asset API goes directly to GitHub's CDN, without connecting to github.com.
        // Construct it from the numeric ID instead of accepting an arbitrary metadata URL.
        var next=if(assetId>0) "https://api.github.com/repos/$RELEASE_REPOSITORY/releases/assets/$assetId" else url
        repeat(6) {
            status(TransferStatus(if(resource==UpdateResource.CHECKSUM) TransferPhase.CHECKSUM else TransferPhase.CONNECTING,attempt,next.toHttpUrl().host))
            var redirect: String?=null
            val result: T?=read(next,resource,offset) { r ->
                if(r.code in listOf(301,302,303,307,308)) {
                    val target=r.request.url.resolve(r.header("Location") ?: error("下载重定向无效")) ?: error("下载重定向无效")
                    require(target.scheme=="https" && target.port==443 && target.username.isEmpty() && target.password.isEmpty() && target.fragment==null &&
                        target.host in setOf("github.com","release-assets.githubusercontent.com","objects.githubusercontent.com")) { "下载重定向地址无效" }
                    redirect=target.toString(); null
                } else { if(!r.isSuccessful) throw UpdateHttpException(r.code); consume(r) }
            }
            if(redirect==null) return result ?: error("下载内容为空")
            next=redirect
        }
        error("下载重定向次数过多")
    }
    private suspend fun <T> retrying(status: (TransferStatus) -> Unit, block: suspend (Int) -> T): T {
        repeat(policy.attempts) { index ->
            try { return block(index+1) }
            catch(e: IOException) {
                currentCoroutineContext().ensureActive()
                if(index+1>=policy.attempts || !retryableUpdateFailure(e)) throw e
                status(TransferStatus(TransferPhase.RETRYING,index+2))
                delay(policy.retryDelayMillis*(index+1))
            }
        }
        error("下载重试失败")
    }
    override suspend fun download(update: Update,directory: File,status: (TransferStatus) -> Unit,progress: (Long,Long) -> Unit): DownloadedUpdate {
        var candidate: DownloadedUpdate?=null
        val connection=AtomicReference(TransferStatus(TransferPhase.CONNECTING,host=if(update.assetId>0) "api.github.com" else update.url.toHttpUrl().host))
        try {
            return withContext(Dispatchers.IO) {
                withTimeoutOrNull(policy.timeoutMillis) {
                    downloadVerified(update,directory,{ value -> if(value.host!=null) connection.set(value); status(value) },progress).also { candidate=it }
                } ?: connection.get().let { last -> throw UpdateTransportException(
                    if(last.phase==TransferPhase.CHECKSUM) UpdateResource.CHECKSUM else UpdateResource.APK,
                    last.host!!,SocketTimeoutException("Download deadline exceeded")) }
            }
        } catch(e: Exception) { candidate?.file?.delete(); throw e }
    }
    private suspend fun downloadVerified(update: Update,directory: File,status: (TransferStatus) -> Unit,progress: (Long,Long) -> Unit): DownloadedUpdate {
        require(update.size in 1..MAX_UPDATE_BYTES && trustedReleaseUrl(update.url,update.fileName)) { "安装包信息无效" }
        val expected=update.sha256 ?: retrying(status) { attempt -> asset(update.checksumsUrl,update.checksumsAssetId,UpdateResource.CHECKSUM,attempt,status) { r ->
            checksumFor(r.body!!.byteStream().readBounded(128*1024).toString(Charsets.UTF_8),update.fileName)
        } }
        require(expected.matches(Regex("[0-9a-f]{64}"))) { "安装包校验值无效" }
        val part=try {
            check(directory.isDirectory || directory.mkdirs()) { "无法创建更新目录，请检查存储空间" }
            File.createTempFile("download-",".part",directory)
        } catch(e: IOException) { throw IllegalStateException("无法保存安装包，请检查存储空间",e) }
        val abandoned=AtomicBoolean(false)
        try {
            retrying(status) { attempt ->
                val offset=part.length()
                asset(update.url,update.assetId,UpdateResource.APK,attempt,status,offset) { response ->
                    try { receive(response,update,part,expected,offset,attempt,status,progress) }
                    finally { if(abandoned.get()) part.delete() }
                }
            }
            currentCoroutineContext().ensureActive()
            return DownloadedUpdate(part,update.copy(sha256=expected))
        } catch(e: Exception) { abandoned.set(true); part.delete(); throw e }
    }
    /** Runs on OkHttp's worker; only bytes from a validated range may be appended. */
    private fun receive(response: Response,update: Update,part: File,expected: String,offset: Long,attempt: Int,
        status: (TransferStatus) -> Unit,progress: (Long,Long) -> Unit) {
        val body=response.body ?: error("安装包为空")
        val start=if(response.code==206) {
            val range=Regex("bytes ([0-9]+)-([0-9]+)/([0-9]+)").matchEntire(response.header("Content-Range").orEmpty()) ?: error("安装包续传响应无效")
            val values=range.groupValues.drop(1).map { it.toLongOrNull() ?: error("安装包续传响应无效") }
            require(values[0]==offset && values[1]==update.size-1 && values[2]==update.size) { "安装包续传范围不匹配" }
            offset
        } else { require(response.code==200) { "安装包下载响应无效" }; 0L }
        require(body.contentLength()==-1L || body.contentLength()==update.size-start) { "安装包大小不匹配" }
        val digest=MessageDigest.getInstance("SHA-256"); var total=start
        val host=response.request.url.host
        status(TransferStatus(TransferPhase.RECEIVING,attempt,host)); progress(start,update.size)
        body.byteStream().use { input ->
            try {
                if(start>0) part.inputStream().use { existing ->
                    val buffer=ByteArray(32*1024)
                    while(true) { val n=existing.read(buffer); if(n<0) break; digest.update(buffer,0,n) }
                }
                java.io.FileOutputStream(part,start>0).use { output ->
                    val buffer=ByteArray(32*1024)
                    while(true) {
                        val count=try { input.read(buffer) } catch(e: IOException) { throw UpdateTransportException(UpdateResource.APK,host,e) }
                        if(count<0) break
                        total+=count; require(total<=update.size) { "安装包大小不匹配" }
                        output.write(buffer,0,count); digest.update(buffer,0,count); progress(total,update.size)
                    }
                }
            } catch(e: UpdateTransportException) { throw e }
            catch(e: IOException) { throw IllegalStateException("无法保存安装包，请检查存储空间",e) }
        }
        if(total!=update.size) throw UpdateTransportException(UpdateResource.APK,host,EOFException("Incomplete APK response"))
        require(digest.digest().joinToString("") { "%02x".format(it) }==expected) { "安装包校验失败，请重新下载" }
    }
    override fun cancel() { client.dispatcher.cancelAll() }
    override fun close() { cancel(); client.connectionPool.evictAll() }
}
private fun java.io.InputStream.readBounded(limit: Int): ByteArray {
    val output=java.io.ByteArrayOutputStream(); val buffer=ByteArray(8192)
    while(true) { val count=read(buffer); if(count<0) break; require(output.size()+count<=limit) { "更新响应过大" }; output.write(buffer,0,count) }
    return output.toByteArray()
}
