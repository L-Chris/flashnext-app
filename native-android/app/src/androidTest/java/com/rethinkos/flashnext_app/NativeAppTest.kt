package com.rethinkos.flashnext_app

import android.app.Application
import android.os.SystemClock
import android.view.MotionEvent
import androidx.compose.material3.MaterialTheme
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.platform.app.InstrumentationRegistry
import kotlinx.coroutines.*
import okhttp3.mockwebserver.*
import org.json.JSONObject
import org.junit.*
import org.junit.Assert.*
import java.util.concurrent.CopyOnWriteArrayList

/** All mutations target a loopback test server. No real study records are modified. */
class NativeAppTest {
    @get:Rule val rule = createComposeRule()
    private val server = MockWebServer()
    private val requests=CopyOnWriteArrayList<String>()
    private var rated=false
    private lateinit var model: AppViewModel
    private val card="""{"id":1,"front":"native question","back":"native answer","presentation":{}}"""
    @Before fun setup() {
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(r: RecordedRequest): MockResponse {
                requests.add("${r.method} ${r.path}")
                val data=when(r.path) {
                    "/api/decks" -> """[{"id":1,"name":"Native test","dueCount":1}]"""
                    "/api/decks/1/cards/due" -> """{"cards":${if(rated) "[]" else "[$card]"}}"""
                    "/api/cards/1/review" -> { rated=true; card }
                    "/api/cards/1/undo" -> { rated=false; card }
                    "/api/settings" -> """{"timezone":"Asia/Shanghai"}"""
                    "/api/decks/1/settings" -> """{"deckId":1,"newPerDay":20,"reviewPerDay":500,"rolloverHour":4,"autoRevealAnswerSeconds":null}"""
                    "/api/decks/1/fsrs/params" -> """{"reviewCount":0,"minReviews":1000,"w":[],"source":"default"}"""
                    "/api/decks/1/fsrs/optimize" -> """{"running":false}"""
                    else -> return MockResponse().setResponseCode(404)
                }
                return MockResponse().setHeader("Content-Type","application/json").setBody("{\"data\":$data}")
            }
        }; server.start()
        val app=InstrumentationRegistry.getInstrumentation().targetContext.applicationContext as Application
        app.getSharedPreferences("flashnext",0).edit().clear().commit()
        app.getSharedPreferences("FlutterSharedPreferences",0).edit().putString("flutter.baseUrl",server.url("/").toString().trimEnd('/')).commit()
        rule.runOnUiThread { model=AppViewModel(app) }
    }
    @After fun cleanup() {
        rule.runOnUiThread { model.leaveReview(false); model.api.close() }
        val app=InstrumentationRegistry.getInstrumentation().targetContext
        app.getSharedPreferences("flashnext",0).edit().clear().commit()
        app.getSharedPreferences("FlutterSharedPreferences",0).edit().clear().commit()
        server.shutdown()
    }
    private fun waitText(text: String) {
        try { rule.waitUntil(20_000) { rule.onAllNodesWithText(text).fetchSemanticsNodes().isNotEmpty() } }
        catch(e: Exception) { throw AssertionError("Missing '$text'; home=${model.home.value}; requests=$requests; tree=${rule.onRoot().printToString()}",e) }
    }
    @Test fun reviewCompletesAndUndoRestoresWithMigratedServerAddress() {
        assertEquals(server.url("/").toString().trimEnd('/'),model.api.baseUrl)
        rule.setContent { MaterialTheme { FlashNext(model,false) } }
        waitText("Native test"); rule.onNodeWithTag("deck-1").performClick()
        waitText("native question"); rule.onNodeWithTag("reveal").performClick(); waitText("native answer")
        rule.waitUntil { rule.onNodeWithTag("rating-3").isEnabled() }; rule.onNodeWithTag("rating-3").performClick()
        waitText("本次学习完成"); rule.onNodeWithText("撤销").performClick(); waitText("native question")
        assertEquals(1,requests.count { it=="POST /api/cards/1/review" }); assertEquals(1,requests.count { it=="POST /api/cards/1/undo" })
        rule.onAllNodesWithText("新卡剩余",substring=true).assertCountEquals(0)
    }
    @Test fun settingsPanelKeepsInsideTapsClosesOutsideAndProtectsDraft() {
        rule.setContent { MaterialTheme { FlashNext(model,false) } }
        waitText("Native test")
        rule.onNodeWithText("牌组设置").performClick()
        waitText("每日新卡")
        rule.onNodeWithText("每日新卡").performClick(); rule.onNodeWithText("每日新卡").assertExists()
        // Hide the keyboard before testing outside dismissal.
        androidx.test.espresso.Espresso.closeSoftKeyboard()
        outsideTap(); rule.waitUntil { rule.onAllNodesWithText("每日新卡").fetchSemanticsNodes().isEmpty() }
        rule.onNodeWithText("牌组设置").performClick(); waitText("每日新卡")
        rule.onNodeWithText("每日新卡").performTextReplacement("25"); androidx.test.espresso.Espresso.closeSoftKeyboard()
        outsideTap(); waitText("放弃未保存的修改？"); rule.onNodeWithText("继续编辑").performClick(); rule.onNodeWithText("25").assertExists()
        assertEquals(0,requests.count { it=="POST /api/decks/1/settings" })
    }
    private fun outsideTap() {
        val ui=InstrumentationRegistry.getInstrumentation().uiAutomation
        val y=InstrumentationRegistry.getInstrumentation().targetContext.resources.displayMetrics.heightPixels/2f
        val time=SystemClock.uptimeMillis()
        listOf(MotionEvent.ACTION_DOWN,MotionEvent.ACTION_UP).forEach { action ->
            val event=MotionEvent.obtain(time,SystemClock.uptimeMillis(),action,1f,y,0); ui.injectInputEvent(event,true); event.recycle()
        }
    }
}

private fun SemanticsNodeInteraction.isEnabled(): Boolean = runCatching { assertIsEnabled(); true }.getOrDefault(false)
