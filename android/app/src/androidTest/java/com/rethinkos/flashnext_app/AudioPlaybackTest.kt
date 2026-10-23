package com.rethinkos.flashnext_app

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import androidx.compose.material3.Text
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.platform.app.InstrumentationRegistry
import okhttp3.mockwebserver.*
import okio.Buffer
import org.junit.*
import org.junit.Assert.*
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.CopyOnWriteArrayList
import java.io.File
import java.net.InetAddress
import java.util.UUID
import java.util.concurrent.TimeUnit
import android.os.SystemClock
import androidx.media3.exoplayer.ExoPlayer
import kotlinx.coroutines.*

@androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
class AudioPlaybackTest {
    @get:Rule val rule=createComposeRule()
    private val server=MockWebServer()
    private val requests=CopyOnWriteArrayList<String>()
    private lateinit var audio: AudioController
    private lateinit var api: HttpStudyApi
    private lateinit var store: AudioStore
    private lateinit var directory: File
    private var creations=0
    private val context get()=InstrumentationRegistry.getInstrumentation().targetContext
    private fun controller()=AudioController(context,store) { creations++; ExoPlayer.Builder(it).build() }
    @Before fun setup() {
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                requests.add(request.path.orEmpty())
                return MockResponse().setHeader("Content-Type","audio/wav").setBody(Buffer().write(wav()))
            }
        }; server.start(InetAddress.getByName("127.0.0.1"),0)
        api=HttpStudyApi(server.url("/").newBuilder().host("127.0.0.1").build().toString().trimEnd('/'))
        directory=File(context.cacheDir,"audio-test-${UUID.randomUUID()}")
        store=AudioStore(context,directory)
        rule.runOnUiThread { audio=controller() }
        rule.setContent { Text("Audio test") }
    }
    @After fun cleanup() {
        rule.runOnUiThread { audio.close() }
        runBlocking { audio.awaitClosed(); store.close(delete=true) }
        api.close(); server.shutdown()
    }
    private fun media(path: String="/a.wav",version: String="a")=Media(path,"front",0,path,wav().size.toLong(),version.repeat(64))
    private fun play(items: List<Media>) {
        rule.runOnUiThread { audio.play(api,items) }
        rule.waitUntil(10_000) { audio.state.value.playing }
    }
    private fun finish() { rule.waitUntil(10_000) { !audio.state.value.playing && !audio.state.value.loading }; assertNull(audio.state.value.error) }
    @Test fun cachedReplayIsOfflineAndPlayerIsReusedAcrossFacesAndRecreation() {
        val item=media(); play(listOf(item)); finish()
        val count=server.requestCount
        server.dispatcher=object: Dispatcher() { override fun dispatch(request: RecordedRequest)=MockResponse().setResponseCode(503) }
        play(listOf(item)); finish(); assertEquals(count,server.requestCount); assertEquals(1,creations)
        rule.runOnUiThread { audio.close() }
        runBlocking { audio.awaitClosed(); store.close() }
        store=AudioStore(context,directory)
        rule.runOnUiThread { audio=controller() }
        play(listOf(item)); finish(); assertEquals(count,server.requestCount); assertEquals(2,creations)
    }
    @Test fun preloadedAudioPlaysWithoutNetworkAndNewContentVersionsFetchAgain() {
        val item=media()
        val cache=runBlocking { store.cache()!! }
        val key=audioTrack(api,item,"ignored").key
        rule.runOnUiThread { audio.warm(api,listOf(item)) }
        rule.waitUntil(10_000) { cache.isCached(key,0,item.bytes) }
        val count=server.requestCount
        play(listOf(item)); finish(); assertEquals(count,server.requestCount)
        play(listOf(item.copy(sha256="b".repeat(64)))); finish(); assertEquals(count+1,server.requestCount)
    }
    @Test fun foregroundPlaybackPreemptsSlowPreloadAndBackgroundDoesNotResumeIt() {
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                requests.add(request.path.orEmpty())
                val response=MockResponse().setHeader("Content-Type","audio/wav").setBody(Buffer().write(wav()))
                return if(request.path=="/slow.wav") MockResponse().setSocketPolicy(SocketPolicy.NO_RESPONSE) else response
            }
        }
        rule.runOnUiThread { audio.warm(api,listOf(media("/slow.wav"))) }
        rule.waitUntil(5000) { requests.contains("/slow.wav") }
        val started=SystemClock.elapsedRealtime()
        play(listOf(media("/fast.wav"))); assertTrue("Playback waited for speculative IO",SystemClock.elapsedRealtime()-started<3000)
        rule.runOnUiThread { audio.suspendPlayback() }; assertFalse(audio.state.value.playing)
        val count=server.requestCount
        rule.waitForIdle(); assertEquals(count,server.requestCount); assertNull(audio.state.value.error)
        play(listOf(media("/fast.wav"))); assertEquals(2,creations)
    }
    @Test fun rapidPlaybackReplacementIgnoresTheOldLoadingRequest() {
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                requests.add(request.path.orEmpty())
                return if(request.path=="/old.wav") MockResponse().setSocketPolicy(SocketPolicy.NO_RESPONSE)
                    else MockResponse().setHeader("Content-Type","audio/wav").setBody(Buffer().write(wav()))
            }
        }
        rule.runOnUiThread { audio.play(api,listOf(media("/old.wav"))) }
        rule.waitUntil(5000) { requests.contains("/old.wav") }
        play(listOf(media("/new.wav"))); finish()
        assertEquals(1,creations); assertNull(audio.state.value.error)
    }
    @Test fun invalidCacheDirectoryFallsBackToStreaming() {
        rule.runOnUiThread { audio.close() }; runBlocking { audio.awaitClosed(); store.close() }
        directory.parentFile!!.mkdirs(); directory.writeText("not a directory")
        store=AudioStore(context,directory)
        rule.runOnUiThread { audio=controller(); audio.warm(api,listOf(media())) }
        play(listOf(media())); finish(); assertTrue(server.requestCount>0)
        directory.delete()
    }
    @Test fun malformedCachedAudioIsRemovedAndRetriedOnlineOnce() {
        val item=media()
        // Use an explicit dispatcher, since setup normally generates the fixture dynamically.
        var first=true
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                val data=if(first) ByteArray(wav().size).also { first=false } else wav()
                return MockResponse().setHeader("Content-Type","audio/wav").setBody(Buffer().write(data))
            }
        }
        runBlocking { withContext(Dispatchers.IO) { store.transfer(store.cache()!!,audioTrack(api,item,"ignored")).run() } }
        play(listOf(item)); finish(); assertEquals(2,server.requestCount)
    }
    @Test fun malformedNetworkAudioStopsAfterOneCacheRecovery() {
        val item=media()
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest)=MockResponse().setHeader("Content-Type","audio/wav").setBody(Buffer().write(ByteArray(wav().size)))
        }
        runBlocking { withContext(Dispatchers.IO) { store.transfer(store.cache()!!,audioTrack(api,item,"ignored")).run() } }
        rule.runOnUiThread { audio.play(api,listOf(item)) }
        rule.waitUntil(10_000) { audio.state.value.error!=null }
        assertFalse(audio.state.value.playing); assertFalse(audio.state.value.loading); assertEquals(2,server.requestCount)
    }
    @Test fun leastRecentlyUsedAudioIsEvictedAtTheConfiguredCapacity() {
        rule.runOnUiThread { audio.close() }; runBlocking { audio.awaitClosed(); store.close() }
        val first=media("/first.wav"); val second=media("/second.wav")
        val limit=first.bytes+1024
        store=AudioStore(context,directory,limit)
        runBlocking { withContext(Dispatchers.IO) {
            val cache=store.cache()!!
            val a=audioTrack(api,first,"test"); val b=audioTrack(api,second,"test")
            store.transfer(cache,a).run(); store.transfer(cache,b).run()
            assertTrue(cache.cacheSpace<=limit); assertFalse(cache.isCached(a.key,0,first.bytes)); assertTrue(cache.isCached(b.key,0,second.bytes))
        } }
    }
    @Test fun orderedAudioCompletesAndCanBeReplayedWithoutLateCallbacks() {
        val card=StudyCard(1,media=listOf(Media("b","front",1,"/b.wav"),Media("a","front",0,"/a.wav"),Media("c","back",0,"/c.wav")))
        rule.runOnUiThread { audio.play(api,card.media(false)) }
        rule.waitUntil(15_000) { audio.state.value.playing }
        rule.waitUntil(15_000) { requests.contains("/b.wav") && !audio.state.value.playing }
        assertEquals(listOf("/a.wav","/b.wav"),requests.toList()); assertNull(audio.state.value.error)
        rule.runOnUiThread { audio.play(api,card.media(true)) }
        rule.waitUntil(10_000) { audio.state.value.playing }
        rule.runOnUiThread { audio.stop() }; rule.waitForIdle(); assertFalse(audio.state.value.playing)
    }
    @Test fun transientAudioFocusLossStopsAndDoesNotResumeAutomatically() {
        rule.runOnUiThread { audio.play(api,listOf(Media("a","front",0,"/a.wav"))) }
        rule.waitUntil(15_000) { audio.state.value.playing }
        val context=InstrumentationRegistry.getInstrumentation().targetContext
        val manager=context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val focus=AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
            .setAudioAttributes(AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA).setContentType(AudioAttributes.CONTENT_TYPE_SPEECH).build())
            .setOnAudioFocusChangeListener {}.build()
        rule.runOnUiThread { assertEquals(AudioManager.AUDIOFOCUS_REQUEST_GRANTED,manager.requestAudioFocus(focus)) }
        rule.waitUntil(5000) { !audio.state.value.playing }
        rule.runOnUiThread { manager.abandonAudioFocusRequest(focus) }; rule.waitForIdle(); assertFalse(audio.state.value.playing)
    }
    private fun wav(): ByteArray {
        val size=8000*2*2
        return ByteBuffer.allocate(44+size).order(ByteOrder.LITTLE_ENDIAN).apply {
            put("RIFF".toByteArray()); putInt(36+size); put("WAVEfmt ".toByteArray()); putInt(16)
            putShort(1); putShort(1); putInt(8000); putInt(16000); putShort(2); putShort(16)
            put("data".toByteArray()); putInt(size); repeat(size/2) { putShort((kotlin.math.sin(it*2*Math.PI*440/8000)*3000).toInt().toShort()) }
        }.array()
    }
}
