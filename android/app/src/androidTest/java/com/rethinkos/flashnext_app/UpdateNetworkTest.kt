package com.rethinkos.flashnext_app

import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import androidx.test.platform.app.InstrumentationRegistry
import java.io.File
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import org.junit.Assume
import org.junit.Assert.assertEquals
import org.junit.Test

/** Explicit read-only smoke test; requires no foreground activity, installation or server writes. */
class UpdateNetworkTest {
    @Test fun realReleaseNetworkDownloadWhenRequested() = runBlocking {
        val instrumentation=InstrumentationRegistry.getInstrumentation()
        val arguments=InstrumentationRegistry.getArguments()
        Assume.assumeTrue("Explicit read-only network opt-in required",arguments.getString("networkUpdate")=="true")
        val legacy=arguments.getString("legacyNetworking")=="true"
        val source=if(legacy) GitHubUpdateSource(OkHttpClient.Builder().retryOnConnectionFailure(false).followRedirects(false)
            .connectTimeout(10,TimeUnit.SECONDS).readTimeout(25,TimeUnit.SECONDS).callTimeout(60,TimeUnit.SECONDS).build(),
            policy=TransferPolicy(attempts=1,timeoutMillis=60_000)) else GitHubUpdateSource()
        val directory=File(instrumentation.targetContext.cacheDir,"network-update-test").apply { mkdirs() }
        val started=SystemClock.elapsedRealtime()
        try {
            Log.i("FlashNextUpdateTest","CHECKING legacyNetworking=$legacy")
            val latest=source.latest() ?: error("No public release available")
            val update=if(legacy) latest.copy(assetId=0,checksumsAssetId=0) else latest
            val result=source.download(update,directory,status={ Log.i("FlashNextUpdateTest","${it.phase} host=${it.host} attempt=${it.attempt}") }) { _,_ -> }
            assertEquals(update.size,result.file.length()); assertEquals(result.update.sha256,sha256(result.file))
            val report="Downloaded ${result.file.length()} verified bytes in ${SystemClock.elapsedRealtime()-started}ms; legacyNetworking=$legacy\n"
            instrumentation.sendStatus(0,Bundle().apply { putString("stream",report) })
        } finally { source.close(); directory.listFiles()?.forEach { it.delete() }; directory.delete() }
    }
}
