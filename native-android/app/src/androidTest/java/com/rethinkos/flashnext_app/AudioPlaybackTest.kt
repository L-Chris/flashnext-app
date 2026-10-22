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

class AudioPlaybackTest {
    @get:Rule val rule=createComposeRule()
    private val server=MockWebServer()
    private val requests=CopyOnWriteArrayList<String>()
    private lateinit var audio: AudioController
    private lateinit var api: HttpStudyApi
    @Before fun setup() {
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                requests.add(request.path.orEmpty())
                return MockResponse().setHeader("Content-Type","audio/wav").setBody(Buffer().write(wav()))
            }
        }; server.start(); api=HttpStudyApi(server.url("/").toString().trimEnd('/'))
        rule.runOnUiThread { audio=AudioController(InstrumentationRegistry.getInstrumentation().targetContext) }
        rule.setContent { Text("Audio test") }
    }
    @After fun cleanup() { rule.runOnUiThread { audio.stop() }; api.close(); server.shutdown() }
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
