package com.rethinkos.flashnext_app

import android.os.Build
import java.io.File
import java.io.IOException
import java.security.MessageDigest
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
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
    suspend fun download(update: Update, directory: File, progress: (Long,Long) -> Unit): DownloadedUpdate
    fun cancel() {}
    fun close() { cancel() }
}
data class DownloadedUpdate(val file: File, val update: Update)

/** No private server URL or credentials are used by the updater. */
class GitHubUpdateSource(private val client: OkHttpClient = OkHttpClient.Builder().retryOnConnectionFailure(false)
    .followRedirects(false).connectTimeout(10,TimeUnit.SECONDS).readTimeout(25,TimeUnit.SECONDS).callTimeout(5,TimeUnit.MINUTES).build(),
    private val endpoint: String = "https://api.github.com/repos/$RELEASE_REPOSITORY/releases/latest",
    private val current: String = BuildConfig.VERSION_NAME, private val abis: List<String> = Build.SUPPORTED_ABIS.toList()) : UpdateSource {
    private suspend fun <T> read(url: String, consume: (Response) -> T): T = suspendCancellableCoroutine { continuation ->
        val request=Request.Builder().url(url).header("User-Agent","FlashNext-Android")
            .header("Accept",if(url==endpoint) "application/vnd.github+json" else "application/octet-stream").build()
        val call=client.newCall(request)
        continuation.invokeOnCancellation { call.cancel() }
        call.enqueue(object: Callback {
            override fun onFailure(call: Call,e: IOException) { if(continuation.isActive) continuation.resumeWithException(e) }
            override fun onResponse(call: Call,response: Response) {
                try { val result=response.use(consume); if(continuation.isActive) continuation.resume(result) }
                catch(e: Exception) { if(continuation.isActive) continuation.resumeWithException(e) }
            }
        })
    }
    override suspend fun latest(): Update? = read(endpoint) { r ->
        if(r.code==404) null else {
            check(r.isSuccessful) { if(r.code in listOf(403,429)) "检查过于频繁，请稍后再试" else "无法连接 GitHub (${r.code})" }
            parseUpdate(JSONObject(r.body!!.byteStream().readBounded(1024*1024).toString(Charsets.UTF_8)),current,abis)
        }
    }
    private suspend fun <T> asset(url: String, consume: (Response) -> T): T {
        require(trustedReleaseUrl(url)) { "更新下载地址无效" }
        var next=url
        repeat(6) {
            var redirect: String?=null
            val result: T?=read(next) { r ->
                if(r.code in listOf(301,302,303,307,308)) {
                    val target=r.request.url.resolve(r.header("Location") ?: error("下载重定向无效")) ?: error("下载重定向无效")
                    require(target.scheme=="https" && target.port==443 && target.username.isEmpty() && target.password.isEmpty() && target.fragment==null &&
                        target.host in setOf("github.com","release-assets.githubusercontent.com","objects.githubusercontent.com")) { "下载重定向地址无效" }
                    redirect=target.toString(); null
                } else { check(r.isSuccessful) { "更新下载失败 (${r.code})" }; consume(r) }
            }
            if(redirect==null) return result ?: error("下载内容为空")
            next=redirect
        }
        error("下载重定向次数过多")
    }
    override suspend fun download(update: Update,directory: File,progress: (Long,Long) -> Unit): DownloadedUpdate {
        require(update.size in 1..MAX_UPDATE_BYTES && trustedReleaseUrl(update.url,update.fileName)) { "安装包信息无效" }
        val expected=update.sha256 ?: asset(update.checksumsUrl) { r -> checksumFor(r.body!!.byteStream().readBounded(128*1024).toString(Charsets.UTF_8),update.fileName) }
        require(expected.matches(Regex("[0-9a-f]{64}"))) { "安装包校验值无效" }
        directory.mkdirs(); val part=File.createTempFile("download-",".part",directory)
        val abandoned=AtomicBoolean(false)
        try {
            asset(update.url) { r ->
                try {
                val body=r.body ?: error("安装包为空")
                require(body.contentLength()==-1L || body.contentLength()==update.size) { "安装包大小不匹配" }
                val digest=MessageDigest.getInstance("SHA-256"); var total=0L
                body.byteStream().use { input -> part.outputStream().use { output ->
                    val buffer=ByteArray(32*1024)
                    while(true) {
                        val count=input.read(buffer); if(count<0) break
                        total+=count; require(total<=update.size) { "安装包大小不匹配" }
                        output.write(buffer,0,count); digest.update(buffer,0,count); progress(total,update.size)
                    }
                } }
                require(total==update.size && digest.digest().joinToString("") { "%02x".format(it) }==expected) { "安装包校验失败，请重新下载" }
                } finally { if(abandoned.get()) part.delete() }
            }
            currentCoroutineContext().ensureActive()
            return DownloadedUpdate(part,update.copy(sha256=expected))
        } catch(e: Exception) { abandoned.set(true); part.delete(); throw e }
    }
    override fun cancel() { client.dispatcher.cancelAll() }
    override fun close() { cancel(); client.connectionPool.evictAll() }
}
private fun java.io.InputStream.readBounded(limit: Int): ByteArray {
    val output=java.io.ByteArrayOutputStream(); val buffer=ByteArray(8192)
    while(true) { val count=read(buffer); if(count<0) break; require(output.size()+count<=limit) { "更新响应过大" }; output.write(buffer,0,count) }
    return output.toByteArray()
}
