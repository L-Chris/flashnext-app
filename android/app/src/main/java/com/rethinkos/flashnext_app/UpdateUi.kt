package com.rethinkos.flashnext_app

import android.content.ClipData
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import androidx.lifecycle.*
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import java.io.File
import kotlinx.coroutines.CancellationException

fun canInstallUpdates(context: Context) = Build.VERSION.SDK_INT<26 || context.packageManager.canRequestPackageInstalls()
fun updateInstallIntent(context: Context,file: File): Intent {
    val uri=FileProvider.getUriForFile(context,"${context.packageName}.updates",file)
    return Intent(Intent.ACTION_VIEW).setDataAndType(uri,"application/vnd.android.package-archive")
        .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION).apply { clipData=ClipData.newRawUri("FlashNext update",uri) }
}
@Composable fun UpdateHost(updater: AppUpdater) {
    val state by updater.state.collectAsStateWithLifecycle()
    val context=LocalContext.current
    val owner=LocalLifecycleOwner.current
    val lifecycle by owner.lifecycle.currentStateFlow.collectAsState()
    fun permissionReturned() {
        if(!updater.state.value.awaitingPermission) return
        updater.awaitingPermission(false)
        if(canInstallUpdates(context)) updater.requestInstall()
        else updater.installError(IllegalStateException("未允许安装更新，请重试"))
    }
    val permission=rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { permissionReturned() }
    val installer=rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) { updater.installerReturned() }
    DisposableEffect(owner,updater) {
        val observer=LifecycleEventObserver { _,event -> if(event==Lifecycle.Event.ON_RESUME) permissionReturned() }
        owner.lifecycle.addObserver(observer)
        onDispose { owner.lifecycle.removeObserver(observer) }
    }
    LaunchedEffect(updater,lifecycle) {
        if(!lifecycle.isAtLeast(Lifecycle.State.RESUMED)) return@LaunchedEffect
        updater.state.collect { current ->
        if(!current.installRequested) return@collect
        updater.consumeInstallRequest()
        val file=try { updater.verifiedInstallerFile() }
        catch(e: CancellationException) { throw e }
        catch(e: Exception) { updater.invalidateDownload(e); return@collect }
        try {
            if(Build.VERSION.SDK_INT>=26 && !canInstallUpdates(context)) {
                updater.awaitingPermission(true)
                permission.launch(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,Uri.parse("package:${context.packageName}")))
            } else installer.launch(updateInstallIntent(context,file))
        } catch(e: Exception) { updater.awaitingPermission(false); updater.installError(IllegalStateException("无法打开安装程序",e)) }
        }
    }
    if(state.dialog && state.info!=null) {
        val downloading=state.stage==UpdateStage.DOWNLOADING
        val verifying=state.stage==UpdateStage.VERIFYING
        AlertDialog(onDismissRequest=updater::hideDialog,
            title={ Text(when { downloading -> "下载更新"; verifying -> "校验安装包"; else -> "新版本 ${state.info!!.version}" }) },
            text={ Column(verticalArrangement=Arrangement.spacedBy(12.dp)) {
                when {
                    downloading -> { LinearProgressIndicator(progress={ if(state.total>0) state.bytes.toFloat()/state.total else 0f },modifier=Modifier.fillMaxWidth()); Text("${if(state.total>0) state.bytes*100/state.total else 0}%") }
                    verifying -> CircularProgressIndicator()
                    else -> Text(state.message ?: "下载完成后将打开安装界面")
                }
            } },
            confirmButton={ if(!verifying) TextButton(onClick={ when {
                downloading -> updater.cancelDownload()
                state.downloaded!=null -> updater.requestInstall()
                else -> updater.download()
            } }) { Text(when { downloading -> "取消下载"; state.downloaded!=null -> "安装"; state.stage==UpdateStage.ERROR -> "重新下载"; else -> "立即更新" }) } },
            dismissButton={ TextButton(onClick=updater::hideDialog) { Text(if(downloading || verifying) "隐藏" else "稍后") } })
    }
}
@Composable fun UpdateSettings(updater: AppUpdater) {
    val state by updater.state.collectAsStateWithLifecycle()
    Text("FlashNext ${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})")
    Row(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
        TextButton(enabled=!state.busy,onClick={ updater.check() }) { Text(if(state.stage==UpdateStage.CHECKING) "检查中…" else "检查更新") }
        if(state.info!=null) TextButton(onClick={ if(state.downloaded!=null) updater.requestInstall() else updater.showDialog() }) {
            Text(when { state.stage==UpdateStage.DOWNLOADING -> "下载中 ${if(state.total>0) state.bytes*100/state.total else 0}%"; state.stage==UpdateStage.VERIFYING -> "校验中…"; state.downloaded!=null -> "安装更新"; else -> "更新至 ${state.info!!.version}" })
        }
    }
    if(state.info==null) state.message?.let { Text(it,style=MaterialTheme.typography.bodySmall) }
}
