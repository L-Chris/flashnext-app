package com.rethinkos.flashnext_app

import java.io.File
import java.security.MessageDigest
import java.util.concurrent.TimeUnit
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
    private val url="https://github.com/L-Chris/flashnext-app/releases/download/v0.4.0/FlashNext-0.4.0-android-arm64-v8a.apk"
    private val bytes=ByteArray(32*1024) { (it%251).toByte() }
    private val digest get() = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }
    private fun update(hash: String?=digest)=Update("0.4.0",true,url,bytes.size.toLong(),hash,url.substringBeforeLast('/')+"/SHA256SUMS.txt")
    @Before fun setup() {
        server=MockWebServer(); server.start()
        val client=OkHttpClient.Builder().followRedirects(false).retryOnConnectionFailure(false).addInterceptor { chain ->
            val original=chain.request()
            val local=original.newBuilder().url(server.url(original.url.encodedPath)).build()
            chain.proceed(local).newBuilder().request(original).build()
        }.build()
        source=GitHubUpdateSource(client,server.url("/latest").toString(),"0.3.0",listOf("arm64-v8a"))
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
