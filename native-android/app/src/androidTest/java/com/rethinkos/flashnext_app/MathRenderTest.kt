package com.rethinkos.flashnext_app

import android.app.Activity
import android.graphics.Bitmap
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.lifecycle.ActivityLifecycleMonitorRegistry
import androidx.test.runner.lifecycle.Stage
import kotlinx.coroutines.*
import org.junit.*
import org.junit.Assert.*
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

class MathRenderTest {
    @get:Rule val rule=createComposeRule()
    @Test fun realKatexFontsAreReadyOnBothSidesInSystemWebView() {
        val address=InstrumentationRegistry.getArguments().getString("previewServer")
        Assume.assumeTrue("Optional read-only preview bridge required",address!=null)
        val api=HttpStudyApi(address!!)
        val card=StudyCard(1,front="计算：\n\n$$\\int_0^1 x^2\\,dx$$",back="答案：\\(\\frac{1}{3}\\)",format="markdown_math")
        lateinit var session: ReviewSession; lateinit var scope: CoroutineScope
        val fake=object: StudyApi {
            override val baseUrl=api.baseUrl
            override suspend fun due(deck: Int)=listOf(card)
            override suspend fun review(id: Int,rating: Int,duration: Long): StudyCard = error("No live review writes permitted")
            override suspend fun undo(id: Int): StudyCard = error("No live undo writes permitted")
        }
        rule.runOnUiThread { scope=CoroutineScope(SupervisorJob()+Dispatchers.Main.immediate); session=ReviewSession(fake,1,scope); session.load() }
        val audio=AudioController(InstrumentationRegistry.getInstrumentation().targetContext)
        rule.setContent { MaterialTheme { androidx.compose.material3.Surface { ReviewScreen(session,api,audio,false) } } }
        try {
            rule.waitUntil(45_000) { session.state.value.ready }
            assertEquals("{\"katex\":true,\"hidden\":true,\"failed\":false}",evaluate("JSON.stringify({katex:!!document.querySelector('.katex'),hidden:document.getElementById('answer').hidden,failed:Array.from(document.fonts).some(f=>f.status==='error')})").let { org.json.JSONTokener(it).nextValue() })
            screenshot("math-front.png")
            rule.runOnUiThread { session.reveal() }
            rule.waitUntil(30_000) { session.state.value.ready && session.state.value.revealed }
            assertEquals("false",evaluate("document.getElementById('answer').hidden"))
            assertEquals("true",evaluate("!!document.querySelector('#answer .katex')")); assertTrue(session.state.value.canRate)
            screenshot("math-back.png")
        } finally { rule.runOnUiThread { session.close(); scope.cancel(); api.close() } }
    }
    private fun findWeb(v: View): WebView? {
        if(v is WebView) return v
        if(v is ViewGroup) for(i in 0 until v.childCount) findWeb(v.getChildAt(i))?.let { return it }
        return null
    }
    private fun evaluate(js: String): String {
        val latch=CountDownLatch(1); var result=""
        rule.runOnUiThread {
            val activity=ActivityLifecycleMonitorRegistry.getInstance().getActivitiesInStage(Stage.RESUMED).first() as Activity
            findWeb(activity.window.decorView)!!.evaluateJavascript(js) { result=it; latch.countDown() }
        }
        assertTrue(latch.await(5,TimeUnit.SECONDS)); return result
    }
    private fun screenshot(name: String) {
        rule.waitForIdle()
        InstrumentationRegistry.getInstrumentation().waitForIdleSync()
        android.os.SystemClock.sleep(250)
        val context=InstrumentationRegistry.getInstrumentation().targetContext
        val folder=File(context.getExternalFilesDir(null),"qa").apply { mkdirs() }
        InstrumentationRegistry.getInstrumentation().uiAutomation.takeScreenshot().also { bitmap ->
            File(folder,name).outputStream().use { bitmap.compress(Bitmap.CompressFormat.PNG,100,it) }; bitmap.recycle()
        }
    }
}
