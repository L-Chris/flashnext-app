package com.rethinkos.flashnext_app

import android.app.Activity
import android.app.Instrumentation.ActivityResult
import android.content.Intent
import android.os.Build
import androidx.compose.material3.MaterialTheme
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.test.espresso.intent.Intents
import androidx.test.espresso.intent.matcher.IntentMatchers.*
import androidx.test.platform.app.InstrumentationRegistry
import java.io.File
import java.io.FileInputStream
import kotlinx.coroutines.*
import org.hamcrest.Matchers.allOf
import org.junit.*
import org.junit.Assert.*
import org.junit.runners.MethodSorters

/** All release metadata and downloads are local fixtures; no GitHub release is modified. */
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
class AppUpdaterTest {
    @get:Rule val rule=createComposeRule()
    private val instrumentation=InstrumentationRegistry.getInstrumentation()
    private val context=instrumentation.targetContext
    private val scope=CoroutineScope(SupervisorJob()+Dispatchers.Main.immediate)
    private val controllers=mutableListOf<AppUpdater>()
    private var intents=false
    private val apkType="application/vnd.android.package-archive"

    @Before fun setup() { clear() }
    @After fun cleanup() {
        if(instrumentation.uiAutomation.rootInActiveWindow?.packageName?.toString()!=context.packageName) shell("input keyevent 4")
        rule.runOnUiThread { controllers.forEach { it.close() }; scope.cancel() }
        if(intents) Intents.release()
        clear()
    }
    private fun clear() {
        context.getSharedPreferences("app_updates",0).edit().clear().commit()
        File(context.filesDir,"updates").listFiles()?.forEach { it.delete() }
    }
    private fun shell(command: String): String = instrumentation.uiAutomation.executeShellCommand(command).use { descriptor ->
        FileInputStream(descriptor.fileDescriptor).bufferedReader().readText()
    }
    private fun controller(source: UpdateSource,clock: () -> Long=System::currentTimeMillis): AppUpdater {
        lateinit var updater: AppUpdater
        rule.runOnUiThread { updater=AppUpdater(context,scope,source,clock=clock); controllers.add(updater) }
        return updater
    }
    private fun fixture(): File {
        val path=InstrumentationRegistry.getArguments().getString("updateApk")
        Assume.assumeTrue("Provide updateApk pointing to a newer APK signed like the test client",path!=null)
        return fixtureFile(path!!)
    }
    private fun fixtureFile(path: String): File = if(path.contains('/')) File(path) else {
        File(context.cacheDir,"update-test-$path").also { destination ->
            instrumentation.context.assets.open(path).use { input -> destination.outputStream().use { input.copyTo(it) } }
        }
    }.also { assertTrue("Missing fixture $path",it.isFile) }
    private fun info(file: File,version: String=context.packageManager.getPackageArchiveInfo(file.absolutePath,0)?.versionName
        ?: error("Cannot read fixture version")) = Update(version,true,
        "https://github.com/$RELEASE_REPOSITORY/releases/download/v$version/FlashNext-$version-android-x86_64.apk",
        file.length(),sha256(file))
    private class LocalSource(val update: Update?,val apk: File?=null): UpdateSource {
        var checks=0; var downloads=0
        override suspend fun latest(): Update? { checks++; return update }
        override suspend fun download(update: Update,directory: File,progress: (Long,Long)->Unit): DownloadedUpdate = withContext(Dispatchers.IO) {
            downloads++; directory.mkdirs()
            val target=File.createTempFile("download-",".part",directory)
            apk!!.copyTo(target,overwrite=true); progress(target.length(),target.length())
            DownloadedUpdate(target,update)
        }
    }
    private fun begin(updater: AppUpdater) {
        rule.setContent { MaterialTheme { UpdateHost(updater) } }
        rule.runOnUiThread { updater.check() }
        rule.waitUntil(10_000) { updater.state.value.stage==UpdateStage.AVAILABLE }
        rule.onNodeWithText("立即更新").performClick()
    }
    @Test fun automaticChecksAreThrottledButManualChecksBypassLimit() {
        var now=100_000_000L
        val source=LocalSource(null); val updater=controller(source) { now }
        rule.runOnUiThread { updater.check(automatic=true) }
        rule.waitUntil { source.checks==1 && !updater.state.value.busy }
        rule.runOnUiThread { updater.check(automatic=true) }; assertEquals(1,source.checks)
        rule.runOnUiThread { updater.check() }; rule.waitUntil { source.checks==2 && !updater.state.value.busy }
        now+=6*60*60*1000
        rule.runOnUiThread { updater.check(automatic=true) }; rule.waitUntil { source.checks==3 }
    }
    @Test fun verifiedDownloadSurvivesControllerRecreationAndDetectsTampering() {
        val apk=fixture(); val source=LocalSource(info(apk),apk); val updater=controller(source)
        rule.runOnUiThread { updater.check() }; rule.waitUntil { updater.state.value.stage==UpdateStage.AVAILABLE }
        rule.runOnUiThread { updater.download() }
        rule.waitUntil(20_000) { updater.state.value.stage in listOf(UpdateStage.READY,UpdateStage.ERROR) }
        assertEquals(updater.state.value.message,UpdateStage.READY,updater.state.value.stage)
        rule.runOnUiThread { updater.close() }
        val restored=controller(LocalSource(null))
        assertEquals(UpdateStage.READY,restored.state.value.stage)
        runBlocking { assertEquals(restored.state.value.downloaded,restored.verifiedInstallerFile()) }
        assertEquals(1,source.downloads)
        restored.state.value.downloaded!!.appendBytes(byteArrayOf(0))
        assertTrue(runCatching { runBlocking { restored.verifiedInstallerFile() } }.isFailure)
    }
    @Test fun archiveVerifierRejectsWrongSignerAndInstalledVersion() {
        val apk=fixture(); AndroidApkVerifier(context).verify(apk,info(apk))
        val current=File(context.applicationInfo.sourceDir)
        assertTrue(runCatching { AndroidApkVerifier(context).verify(current,info(current,BuildConfig.VERSION_NAME)) }.isFailure)
        val wrongPath=InstrumentationRegistry.getArguments().getString("updateWrongSigner")
        Assume.assumeTrue("Provide updateWrongSigner for certificate rejection",wrongPath!=null)
        val wrong=fixtureFile(wrongPath!!)
        val error=runCatching { AndroidApkVerifier(context).verify(wrong,info(wrong)) }.exceptionOrNull()
        assertNotNull(error); assertEquals("安装包签名不匹配",error!!.message)
    }
    @Test fun aPermissionGrantResumesInstallerWithoutRedownload() {
        val apk=fixture(); val source=LocalSource(info(apk),apk); val updater=controller(source)
        assertFalse("Reset REQUEST_INSTALL_PACKAGES to deny before starting instrumentation",canInstallUpdates(context))
        Intents.init(); intents=true
        Intents.intending(allOf(hasAction(Intent.ACTION_VIEW),hasType(apkType))).respondWith(ActivityResult(Activity.RESULT_CANCELED,null))
        begin(updater)
        rule.waitUntil(20_000) { updater.state.value.awaitingPermission }
        rule.waitUntil(10_000) { instrumentation.uiAutomation.rootInActiveWindow?.packageName?.toString()=="com.android.settings" }
        shell("appops set ${context.packageName} REQUEST_INSTALL_PACKAGES allow")
        shell("input keyevent 4")
        rule.waitUntil(20_000) { !updater.state.value.awaitingPermission && Intents.getIntents().any { it.type==apkType } }
        Intents.intended(allOf(hasAction(Intent.ACTION_VIEW),hasType(apkType)))
        val install=Intents.getIntents().single { it.type==apkType }
        assertEquals("content",install.data!!.scheme)
        assertEquals("${context.packageName}.updates",install.data!!.authority)
        assertTrue(install.flags and Intent.FLAG_GRANT_READ_URI_PERMISSION!=0)
        assertEquals(1,source.downloads); assertNotNull(updater.state.value.downloaded)
    }
    @Test fun completedDownloadOpensRealAndroidInstaller() {
        val apk=fixture(); val source=LocalSource(info(apk),apk); val updater=controller(source)
        shell("appops set ${context.packageName} REQUEST_INSTALL_PACKAGES allow")
        begin(updater)
        rule.waitUntil(30_000) { instrumentation.uiAutomation.rootInActiveWindow?.packageName?.toString()?.contains("packageinstaller")==true }
        assertEquals(UpdateStage.READY,updater.state.value.stage)
        assertEquals(1,source.downloads)
        shell("input keyevent 4")
        val installed=context.packageManager.getPackageInfo(context.packageName,0)
        @Suppress("DEPRECATION") val code=if(Build.VERSION.SDK_INT>=28) installed.longVersionCode.toInt() else installed.versionCode
        assertEquals(BuildConfig.VERSION_CODE,code)
    }
}
