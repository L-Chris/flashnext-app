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
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Density
import androidx.compose.ui.unit.dp
import android.graphics.Bitmap
import java.io.File

/** All mutations target a loopback test server. No real study records are modified. */
class NativeAppTest {
    @get:Rule val rule = createComposeRule()
    private val server = MockWebServer()
    private val requests=CopyOnWriteArrayList<String>()
    private var rated=false
    private var settingsGate: CountDownLatch?=null
    private lateinit var model: AppViewModel
    private val card="""{"id":1,"front":"native question","back":"native answer","presentation":{},"media":[{"mediaId":"front","side":"front","position":0,"url":"/audio/front.wav"},{"mediaId":"back","side":"back","position":0,"url":"/audio/back.wav"}]}"""
    @Before fun setup() {
        server.dispatcher=object: Dispatcher() {
            override fun dispatch(request: RecordedRequest): MockResponse {
                val r=request
                requests.add("${r.method} ${r.path}")
                if(r.path=="/api/decks/1/settings") settingsGate?.await(20,TimeUnit.SECONDS)
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
        settingsGate?.countDown()
        rule.runOnUiThread { model.leaveReview(false); model.api.close(); model.updater.close() }
        val app=InstrumentationRegistry.getInstrumentation().targetContext
        app.getSharedPreferences("flashnext",0).edit().clear().commit()
        app.getSharedPreferences("FlutterSharedPreferences",0).edit().clear().commit()
        server.shutdown()
    }
    private fun waitText(text: String) {
        try { rule.waitUntil(20_000) { runCatching { rule.onAllNodesWithText(text).fetchSemanticsNodes().isNotEmpty() }.getOrDefault(false) } }
        catch(e: Exception) { throw AssertionError("Missing '$text'; home=${model.home.value}; requests=$requests; tree=${runCatching { rule.onAllNodes(isRoot()).printToString() }.getOrDefault("unavailable")}",e) }
    }
    @Test fun reviewCompletesAndUndoRestoresWithMigratedServerAddress() {
        assertEquals(server.url("/").toString().trimEnd('/'),model.api.baseUrl)
        rule.setContent { FlashNextTheme(false) { FlashNext(model,false) } }
        waitText("Native test"); capture("home-light")
        waitText("Native test"); rule.onNodeWithTag("deck-1").performClick()
        waitText("native question"); rule.onNodeWithTag("reveal").performClick(); waitText("native answer")
        capture("review-light")
        rule.waitUntil { rule.onNodeWithTag("rating-3").isEnabled() }; rule.onNodeWithTag("rating-3").performClick()
        waitText("太棒了！当前没有需要复习的卡片"); rule.onNodeWithContentDescription("撤销上一次").performClick(); waitText("native question")
        assertEquals(1,requests.count { it=="POST /api/cards/1/review" }); assertEquals(1,requests.count { it=="POST /api/cards/1/undo" })
        rule.onAllNodesWithText("新卡剩余",substring=true).assertCountEquals(0)
    }
    @Test fun settingsPanelKeepsInsideTapsClosesOutsideAndProtectsDraft() {
        rule.setContent { FlashNextTheme(false) { FlashNext(model,false) } }
        waitText("Native test")
        rule.onNodeWithTag("deck-settings-1").performClick()
        waitText("每日新卡额度"); capture("deck-settings-light")
        rule.onNodeWithText("每日新卡额度").performClick(); rule.onNodeWithText("每日新卡额度").assertExists()
        // Hide the keyboard before testing outside dismissal.
        androidx.test.espresso.Espresso.closeSoftKeyboard()
        outsideTap(); rule.waitUntil { rule.onAllNodesWithText("每日新卡额度").fetchSemanticsNodes().isEmpty() }
        rule.onNodeWithTag("deck-settings-1").performClick(); waitText("每日新卡额度")
        rule.onNodeWithText("每日新卡额度").performTextReplacement("25"); androidx.test.espresso.Espresso.closeSoftKeyboard()
        outsideTap(); waitText("放弃未保存的修改？"); rule.onNodeWithText("继续编辑").performClick(); rule.onNodeWithText("25").assertExists()
        rule.onNodeWithText("每日新卡额度").assertIsDisplayed()
        assertEquals(0,requests.count { it=="POST /api/decks/1/settings" })
    }
    @Test fun loadingSettingsCanBeDismissedWithoutWaitingForNetwork() {
        settingsGate=CountDownLatch(1)
        rule.setContent { FlashNextTheme(false) { FlashNext(model,false) } }
        waitText("Native test"); rule.onNodeWithTag("deck-settings-1").performClick(); waitText("返回")
        rule.waitUntil { requests.contains("GET /api/decks/1/settings") }
        try {
            outsideTap()
            rule.waitUntil(5000) { rule.onAllNodesWithText("返回").fetchSemanticsNodes().isEmpty() }
        } finally { settingsGate?.countDown() }
        assertEquals(0,requests.count { it=="POST /api/decks/1/settings" })
    }
    @Test fun oneSaveWritesTimezoneToNewServerThenChangesAddress() {
        MockWebServer().use { destination ->
            destination.enqueue(MockResponse().setBody("""{"data":{"timezone":"UTC"}}"""))
            destination.enqueue(MockResponse().setBody("""{"data":[]}""")); destination.start()
            openAppSettings()
            rule.onAllNodesWithText("保存").assertCountEquals(1)
            listOf("保存服务器","学习时区","所有牌组共享").forEach { rule.onAllNodesWithText(it,substring=true).assertCountEquals(0) }
            val address=destination.url("/").toString().trimEnd('/')
            rule.onNodeWithText("服务器地址").performTextReplacement(address)
            rule.onNodeWithText("时区").performTextReplacement("UTC")
            androidx.test.espresso.Espresso.closeSoftKeyboard()
            rule.onNodeWithText("保存").performClick()
            rule.waitUntil(10_000) { model.api.baseUrl==address }
            val request=destination.takeRequest(5,TimeUnit.SECONDS)!!
            assertEquals("POST",request.method); assertEquals("/api/settings",request.path)
            assertEquals("UTC",JSONObject(request.body.readUtf8()).getString("timezone"))
            assertEquals(0,requests.count { it=="POST /api/settings" })
        }
    }
    @Test fun failedCombinedSaveRetainsDraftAndOriginalServer() {
        MockWebServer().use { destination ->
            destination.enqueue(MockResponse().setResponseCode(503)); destination.start()
            openAppSettings()
            val original=model.api.baseUrl; val address=destination.url("/").toString().trimEnd('/')
            rule.onNodeWithText("服务器地址").performTextReplacement(address)
            rule.onNodeWithText("时区").performTextReplacement("UTC")
            androidx.test.espresso.Espresso.closeSoftKeyboard()
            rule.onNodeWithText("保存").performClick()
            rule.waitUntil(10_000) { rule.onAllNodesWithText("保存").fetchSemanticsNodes().isNotEmpty() && runCatching { rule.onNodeWithText("保存").assertIsEnabled(); true }.getOrDefault(false) }
            assertNotNull(destination.takeRequest(5,TimeUnit.SECONDS))
            assertEquals(original,model.api.baseUrl)
            rule.onNodeWithText(address).assertExists(); rule.onNodeWithText("UTC").assertExists()
            assertEquals(0,requests.count { it=="POST /api/settings" })
        }
    }
    @Test fun serverOnlySaveDoesNotOverwriteDestinationTimezone() {
        MockWebServer().use { destination ->
            destination.enqueue(MockResponse().setBody("""{"data":[]}""")); destination.start()
            openAppSettings()
            val address=destination.url("/").toString().trimEnd('/')
            rule.onNodeWithText("服务器地址").performTextReplacement(address)
            androidx.test.espresso.Espresso.closeSoftKeyboard()
            rule.onNodeWithText("保存").performClick()
            rule.waitUntil(10_000) { model.api.baseUrl==address }
            val request=destination.takeRequest(5,TimeUnit.SECONDS)!!
            assertEquals("GET",request.method); assertEquals("/api/decks",request.path)
            assertNull(destination.takeRequest(300,TimeUnit.MILLISECONDS))
        }
    }
    private fun openAppSettings() {
        rule.setContent { FlashNextTheme(false) { FlashNext(model,false) } }
        waitText("Native test"); rule.onNodeWithContentDescription("设置").performClick()
        waitText("Asia/Shanghai")
        rule.onNodeWithText("时区").assertIsEnabled()
        capture("app-settings-light")
    }
    @Test fun reviewActionsFitSmallScreenWithLargeTextAndKeepUndoInToolbar() {
        rule.setContent {
            val density=LocalDensity.current.density
            CompositionLocalProvider(LocalDensity provides Density(density,2f)) {
                FlashNextTheme(true) { Box(Modifier.requiredWidth(320.dp).fillMaxHeight()) { FlashNext(model,true) } }
            }
        }
        waitText("Native test")
        rule.onNodeWithContentDescription("设置").assertIsDisplayed()
        rule.onNodeWithTag("deck-1").performClick(); waitText("native question")
        rule.onNodeWithContentDescription("返回").assertIsDisplayed()
        rule.onNodeWithContentDescription("撤销上一次").assertIsNotEnabled()
        rule.onNodeWithTag("reveal").performClick(); waitText("native answer")
        rule.waitUntil { rule.onNodeWithTag("rating-4").isEnabled() }
        (1..4).forEach { rule.onNodeWithTag("rating-$it").assertIsDisplayed().assertIsEnabled() }
        val cardBounds=rule.onNodeWithTag("review-card").fetchSemanticsNode().boundsInRoot
        val actionsBounds=rule.onNodeWithTag("rating-buttons").fetchSemanticsNode().boundsInRoot
        assertTrue("The card must keep usable space above the actions",cardBounds.height>200)
        assertTrue("Rating actions must stay below card content",actionsBounds.top>=cardBounds.bottom)
        capture("review-dark-large-text")
        rule.onNodeWithContentDescription("返回").performClick(); waitText("Native test")
    }
    private fun capture(name: String) {
        if(InstrumentationRegistry.getArguments().getString("captureUi")!="true") return
        val directory=File(InstrumentationRegistry.getInstrumentation().targetContext.getExternalFilesDir(null),"ui-qa").apply { mkdirs() }
        rule.waitForIdle()
        InstrumentationRegistry.getInstrumentation().waitForIdleSync()
        SystemClock.sleep(200)
        File(directory,"$name.png").outputStream().use { InstrumentationRegistry.getInstrumentation().uiAutomation.takeScreenshot().compress(Bitmap.CompressFormat.PNG,100,it) }
    }
    private fun outsideTap() {
        val ui=InstrumentationRegistry.getInstrumentation().uiAutomation
        val bounds=rule.onNodeWithTag("settings-panel").fetchSemanticsNode().boundsInWindow
        val y=bounds.top/2f
        val time=SystemClock.uptimeMillis()
        listOf(MotionEvent.ACTION_DOWN,MotionEvent.ACTION_UP).forEach { action ->
            val event=MotionEvent.obtain(time,SystemClock.uptimeMillis(),action,bounds.center.x,y,0); ui.injectInputEvent(event,true); event.recycle()
        }
    }
}

private fun SemanticsNodeInteraction.isEnabled(): Boolean = runCatching { assertIsEnabled(); true }.getOrDefault(false)
