package com.rethinkos.flashnext_app

import java.io.File
import java.security.MessageDigest
import java.util.concurrent.TimeUnit
import java.util.concurrent.CopyOnWriteArrayList
import java.net.SocketTimeoutException
import javax.net.ssl.SSLHandshakeException
import kotlinx.coroutines.*
import kotlinx.coroutines.test.runTest
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.*
import okio.Buffer
import org.json.JSONObject
import org.junit.*
import org.junit.Assert.*
import org.junit.rules.TemporaryFolder

class UpdateDownloadTest {
    @get:Rule val folder=TemporaryFolder()
    private lateinit var server: MockWebServer
    private lateinit var source: GitHubUpdateSource
    private lateinit var client: OkHttpClient
    private val url="https://github.com/L-Chris/flashnext-app/releases/download/v0.4.0/FlashNext-0.4.0-android-arm64-v8a.apk"
    private val bytes=ByteArray(32*1024) { (it%251).toByte() }
    private val digest get() = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }
    private fun update(hash: String?=digest)=Update("0.4.0",true,url,bytes.size.toLong(),hash,url.substringBeforeLast('/')+"/SHA256SUMS.txt")
    @Before fun setup() {
        server=MockWebServer(); server.start()
        client=OkHttpClient.Builder().followRedirects(false).retryOnConnectionFailure(false).addInterceptor { chain ->
            val original=chain.request()
            val local=original.newBuilder().url(server.url(original.url.encodedPath+(original.url.encodedQuery?.let { "?$it" } ?: ""))).build()
            chain.proceed(local).newBuilder().request(original).build()
        }.build()
        source=GitHubUpdateSource(client,server.url("/latest").toString(),"0.3.0",listOf("arm64-v8a"),TransferPolicy(retryDelayMillis=0))
    }
    @After fun cleanup() { source.close(); server.shutdown() }
    @Test fun `streams bytes reports progress and verifies before returning a candidate`() = runTest {
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        val progress=mutableListOf<Long>()
        val result=source.download(update(),folder.newFolder()) { n,_ -> progress.add(n) }
        assertArrayEquals(bytes,result.file.readBytes()); assertEquals(digest,sha256(result.file))
        assertEquals(bytes.size.toLong(),progress.last()); assertTrue(progress.zipWithNext().all { it.first<=it.second })
    }
    @Test fun `missing API digest falls back to the exact matching checksum entry`() = runTest {
        server.enqueue(MockResponse().setBody("${"0".repeat(64)}  ./other.apk\n$digest  ./${update().fileName}\n"))
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        val result=source.download(update(null),folder.newFolder()) { _,_ -> }
        assertEquals(digest,result.update.sha256); assertEquals(2,server.requestCount)
    }
    @Test fun `asset API skips the web host and preserves ranges through CDN redirects`() = runTest {
        val apiPath="/repos/$RELEASE_REPOSITORY/releases/assets/123"
        var offset=0
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse = when(request.path) {
                apiPath -> MockResponse().setResponseCode(302).setHeader("Location","https://release-assets.githubusercontent.com/asset?token=example")
                "/asset?token=example" -> if(request.getHeader("Range")==null)
                    MockResponse().setBody(Buffer().write(bytes)).setSocketPolicy(SocketPolicy.DISCONNECT_DURING_RESPONSE_BODY)
                else {
                    offset=request.getHeader("Range")!!.removePrefix("bytes=").removeSuffix("-").toInt()
                    MockResponse().setResponseCode(206).setHeader("Content-Range","bytes $offset-${bytes.size-1}/${bytes.size}")
                        .setBody(Buffer().write(bytes,offset,bytes.size-offset))
                }
                else -> MockResponse().setResponseCode(404)
            }
        }
        val statuses=CopyOnWriteArrayList<TransferStatus>()
        val result=source.download(update().copy(assetId=123),folder.newFolder(),status={statuses.add(it)}) { _,_ -> }
        assertArrayEquals(bytes,result.file.readBytes()); assertTrue(offset in 1 until bytes.size)
        assertFalse(statuses.any { it.host=="github.com" }); assertEquals("api.github.com",statuses.first().host)
        assertEquals(4,server.requestCount)
        val requests=(1..4).map { server.takeRequest() }
        assertEquals(listOf(apiPath,"/asset?token=example",apiPath,"/asset?token=example"),requests.map { it.path })
        assertEquals("application/octet-stream",requests.first().getHeader("Accept"))
        assertEquals(requests[2].getHeader("Range"),requests[3].getHeader("Range"))
    }
    @Test fun `checksum fallback also uses the public asset API`() = runTest {
        server.enqueue(MockResponse().setBody("$digest  ./${update().fileName}\n"))
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        val result=source.download(update(null).copy(assetId=123,checksumsAssetId=456),folder.newFolder()) { _,_ -> }
        assertEquals(digest,result.update.sha256)
        assertEquals("/repos/$RELEASE_REPOSITORY/releases/assets/456",server.takeRequest().path)
        assertEquals("/repos/$RELEASE_REPOSITORY/releases/assets/123",server.takeRequest().path)
    }
    @Test fun `only approved HTTPS redirects are followed`() = runTest {
        server.enqueue(MockResponse().setResponseCode(302).setHeader("Location","https://release-assets.githubusercontent.com/asset?token=example"))
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        assertTrue(source.download(update(),folder.newFolder()) { _,_ -> }.file.exists())
        server.enqueue(MockResponse().setResponseCode(302).setHeader("Location","https://evil.example/asset"))
        assertTrue(runCatching { source.download(update(),folder.newFolder()) { _,_ -> } }.isFailure)
        assertEquals(3,server.requestCount)
    }
    @Test fun `bad hashes sizes and truncated responses leave no installable file`() = runTest {
        val directory=folder.newFolder()
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        assertTrue(runCatching { source.download(update("0".repeat(64)),directory) { _,_ -> } }.isFailure)
        server.enqueue(MockResponse().setBody("short"))
        assertTrue(runCatching { source.download(update(),directory) { _,_ -> } }.isFailure)
        assertTrue(directory.listFiles()!!.isEmpty())
        assertTrue(runCatching { source.download(update().copy(size=MAX_UPDATE_BYTES+1),directory) { _,_ -> } }.isFailure)
    }
    @Test fun `cancel closes a streaming response and removes partial bytes`() = runTest {
        val directory=folder.newFolder(); val started=CompletableDeferred<Unit>()
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)).throttleBody(1024,100,TimeUnit.MILLISECONDS))
        val job=launch { source.download(update(),directory) { _,_ -> started.complete(Unit) } }
        started.await(); job.cancelAndJoin()
        withContext(Dispatchers.IO) { withTimeout(3000) { while(directory.listFiles()!!.isNotEmpty()) delay(10) } }
    }
    @Test fun `headers timeout retries with a visible connection stage before any bytes arrive`() = runTest {
        source.close()
        source=GitHubUpdateSource(client.newBuilder().readTimeout(150,TimeUnit.MILLISECONDS).build(),
            server.url("/latest").toString(),"0.3.0",listOf("arm64-v8a"),TransferPolicy(retryDelayMillis=0))
        server.enqueue(MockResponse().setSocketPolicy(SocketPolicy.NO_RESPONSE))
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        val statuses=CopyOnWriteArrayList<TransferStatus>()
        val result=source.download(update(),folder.newFolder(),status={statuses.add(it)}) { _,_ -> }
        assertArrayEquals(bytes,result.file.readBytes())
        assertTrue(statuses.any { it.phase==TransferPhase.CONNECTING && it.attempt==1 })
        assertTrue(statuses.any { it.phase==TransferPhase.RETRYING && it.attempt==2 })
        assertTrue(statuses.any { it.phase==TransferPhase.RECEIVING && it.attempt==2 })
        assertEquals(2,server.requestCount)
    }
    @Test fun `interrupted body resumes its exact byte range and verifies the whole APK`() = runTest {
        var offset=0
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                val range=request.getHeader("Range")
                return if(range==null) MockResponse().setBody(Buffer().write(bytes)).setSocketPolicy(SocketPolicy.DISCONNECT_DURING_RESPONSE_BODY)
                else {
                    offset=range.removePrefix("bytes=").removeSuffix("-").toInt()
                    MockResponse().setResponseCode(206).setHeader("Content-Range","bytes $offset-${bytes.size-1}/${bytes.size}")
                        .setBody(Buffer().write(bytes,offset,bytes.size-offset))
                }
            }
        }
        val result=source.download(update(),folder.newFolder()) { _,_ -> }
        assertTrue(offset in 1 until bytes.size); assertEquals(2,server.requestCount)
        assertArrayEquals(bytes,result.file.readBytes()); assertEquals(digest,sha256(result.file))
    }
    @Test fun `a server that ignores range causes a clean restart instead of appended corruption`() = runTest {
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)).setSocketPolicy(SocketPolicy.DISCONNECT_DURING_RESPONSE_BODY))
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        val result=source.download(update(),folder.newFolder()) { _,_ -> }
        assertArrayEquals(bytes,result.file.readBytes()); assertEquals(bytes.size.toLong(),result.file.length())
        server.takeRequest(); assertNotNull(server.takeRequest().getHeader("Range"))
    }
    @Test fun `wrong resume ranges and digest failures are never retried or installed`() = runTest {
        val directory=folder.newFolder()
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)).setSocketPolicy(SocketPolicy.DISCONNECT_DURING_RESPONSE_BODY))
        server.enqueue(MockResponse().setResponseCode(206).setHeader("Content-Range","bytes 0-${bytes.size-1}/${bytes.size}").setBody(Buffer().write(bytes)))
        assertTrue(runCatching { source.download(update(),directory) { _,_ -> } }.isFailure)
        assertEquals(2,server.requestCount); assertTrue(directory.listFiles()!!.isEmpty())
        server.enqueue(MockResponse().setBody(Buffer().write(bytes)))
        assertTrue(runCatching { source.download(update("0".repeat(64)),directory) { _,_ -> } }.isFailure)
        assertEquals(3,server.requestCount); assertTrue(directory.listFiles()!!.isEmpty())
    }
    @Test fun `temporary errors retry at most three times while forbidden responses do not retry`() = runTest {
        repeat(3) { server.enqueue(MockResponse().setResponseCode(503)) }
        val directory=folder.newFolder()
        val error=runCatching { source.download(update(),directory) { _,_ -> } }.exceptionOrNull()
        assertTrue(error is UpdateHttpException); assertEquals(3,server.requestCount); assertTrue(directory.listFiles()!!.isEmpty())
        server.enqueue(MockResponse().setResponseCode(403))
        assertTrue(runCatching { source.download(update(),directory) { _,_ -> } }.isFailure)
        assertEquals(4,server.requestCount)
    }
    @Test fun `download deadline produces an actionable error instead of leaving a cancelled operation`() = runTest {
        source.close()
        source=GitHubUpdateSource(client,server.url("/latest").toString(),"0.3.0",listOf("arm64-v8a"),TransferPolicy(timeoutMillis=250,retryDelayMillis=0))
        val directory=folder.newFolder()
        server.enqueue(MockResponse().setResponseCode(302).setHeader("Location","https://release-assets.githubusercontent.com/asset"))
        server.enqueue(MockResponse().setSocketPolicy(SocketPolicy.NO_RESPONSE))
        val error=runCatching { source.download(update(),directory) { _,_ -> } }.exceptionOrNull()
        assertTrue(error is UpdateTransportException); assertFalse(error is CancellationException)
        assertTrue(error!!.updateMessage().contains("下载安装包超时"))
        assertTrue(error.updateMessage().contains("release-assets.githubusercontent.com"))
        withContext(Dispatchers.IO) { withTimeout(3000) { while(directory.listFiles()!!.isNotEmpty()) delay(10) } }
    }
    @Test fun `certificate failures are not retried and update errors never point to the study server`() {
        assertFalse(retryableUpdateFailure(UpdateTransportException(UpdateResource.APK,"release-assets.githubusercontent.com",SSLHandshakeException("bad certificate"))))
        val message=UpdateTransportException(UpdateResource.APK,"release-assets.githubusercontent.com",SocketTimeoutException()).updateMessage()
        assertTrue(message.contains("release-assets.githubusercontent.com")); assertTrue(message.contains("超时")); assertFalse(message.contains("服务器地址"))
    }
    @Test fun `ABI packages win over universal packages and trusted URLs cannot escape the repository`() {
        val body=JSONObject("""{"tag_name":"v0.4.0","html_url":"https://github.com/L-Chris/flashnext-app/releases/tag/v0.4.0","assets":[{"name":"FlashNext-0.4.0-android.apk","state":"uploaded","size":100},{"name":"FlashNext-0.4.0-android-arm64-v8a.apk","state":"uploaded","size":50,"digest":"sha256:${"a".repeat(64)}"}]}""")
        val next=parseUpdate(body,"0.3.0",listOf("arm64-v8a"))!!
        assertEquals(url,next.url); assertEquals("a".repeat(64),next.sha256); assertTrue(trustedReleaseUrl(next.url))
        assertFalse(trustedReleaseUrl(url.replace("github.com","github.com.evil.example")))
        assertFalse(trustedReleaseUrl(url+"?token=x")); assertFalse(trustedReleaseUrl(url.replace("https:","http:")))
        assertTrue(runCatching { checksumFor("$digest  ./wrong.apk",next.fileName) }.isFailure)
        assertTrue(runCatching { checksumFor("$digest  ./${next.fileName}\n$digest  ./${next.fileName}",next.fileName) }.isFailure)
    }
}
