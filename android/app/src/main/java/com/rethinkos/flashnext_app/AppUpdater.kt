package com.rethinkos.flashnext_app

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.FileProvider
import java.io.File
import java.security.MessageDigest
import java.util.zip.ZipFile
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import org.json.JSONObject

enum class UpdateStage { IDLE, CHECKING, AVAILABLE, DOWNLOADING, VERIFYING, READY, ERROR }
data class UpdateState(val stage: UpdateStage=UpdateStage.IDLE, val info: Update?=null, val downloaded: File?=null,
    val bytes: Long=0, val total: Long=0, val dialog: Boolean=false, val installRequested: Boolean=false,
    val awaitingPermission: Boolean=false, val message: String?=null) {
    val busy get() = stage in listOf(UpdateStage.CHECKING,UpdateStage.DOWNLOADING,UpdateStage.VERIFYING)
}
fun interface ApkVerifier { fun verify(file: File, update: Update) }
@Suppress("DEPRECATION")
class AndroidApkVerifier(private val context: Context) : ApkVerifier {
    override fun verify(file: File,update: Update) {
        require(file.isFile && file.length()==update.size && update.sha256!=null && sha256(file)==update.sha256) { "安装包校验失败，请重新下载" }
        val flags=if(Build.VERSION.SDK_INT>=28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
        val manager=context.packageManager
        val archive=manager.getPackageArchiveInfo(file.absolutePath,flags) ?: error("安装包无法解析")
        val installed=manager.getPackageInfo(context.packageName,flags)
        require(archive.packageName==context.packageName && archive.versionName==update.version) { "安装包与当前应用不匹配" }
        fun version(p: PackageInfo) = if(Build.VERSION.SDK_INT>=28) p.longVersionCode else p.versionCode.toLong()
        require(version(archive)>version(installed)) { "安装包版本过旧" }
        fun signers(p: PackageInfo): Set<String> {
            val signatures=if(Build.VERSION.SDK_INT>=28) p.signingInfo?.apkContentsSigners else p.signatures
            return signatures.orEmpty().map { signature -> MessageDigest.getInstance("SHA-256").digest(signature.toByteArray()).joinToString("") { "%02x".format(it) } }.toSet()
        }
        val expected=signers(installed)
        require(expected.isNotEmpty() && signers(archive)==expected) { "安装包签名不匹配" }
        ZipFile(file).use { zip ->
            val nativeAbis=zip.entries().asSequence().map { it.name }.filter { it.startsWith("lib/") && it.endsWith(".so") }.map { it.split('/')[1] }.toSet()
            require(nativeAbis.isEmpty() || Build.SUPPORTED_ABIS.any { it in nativeAbis }) { "安装包不支持当前设备" }
        }
    }
}
class UpdateFileProvider : FileProvider()

/** Owned by the ViewModel, so dismissing settings never cancels a download. */
class AppUpdater(context: Context, private val scope: CoroutineScope,
    private val source: UpdateSource=GitHubUpdateSource(), private val verifier: ApkVerifier=AndroidApkVerifier(context),
    private val clock: () -> Long = System::currentTimeMillis) {
    private val preferences=context.getSharedPreferences("app_updates",Context.MODE_PRIVATE)
    private val directory=File(context.filesDir,"updates")
    private val target=File(directory,"verified.apk")
    private val mutable=MutableStateFlow(UpdateState())
    val state=mutable.asStateFlow()
    private var job: Job?=null
    private var operation=0
    init {
        directory.listFiles()?.filter { it.name.startsWith("download-") && it.name.endsWith(".part") }?.forEach { it.delete() }
        val restored=runCatching {
            val j=JSONObject(preferences.getString("downloaded",null) ?: return@runCatching null)
            val info=Update(j.text("version"),true,j.text("url"),j.optLong("size"),j.text("sha256").takeIf { it.isNotBlank() },j.text("checksumsUrl"))
            if(newerVersion(info.version,BuildConfig.VERSION_NAME) && trustedReleaseUrl(info.url) && info.size in 1..MAX_UPDATE_BYTES &&
                info.sha256?.matches(Regex("[0-9a-f]{64}"))==true && target.isFile)
                UpdateState(UpdateStage.READY,info,target,awaitingPermission=preferences.getBoolean("awaitingPermission",false)) else null
        }.getOrNull()
        if(restored!=null) mutable.value=restored
        else { preferences.edit().remove("downloaded").remove("awaitingPermission").apply(); target.delete() }
    }
    fun check(automatic: Boolean=false) {
        if(state.value.busy || automatic && state.value.downloaded!=null) return
        if(automatic && clock()-preferences.getLong("lastAttempt",0)<6*60*60*1000) return
        preferences.edit().putLong("lastAttempt",clock()).apply()
        val previous=state.value
        val generation=++operation
        mutable.value=previous.copy(stage=UpdateStage.CHECKING,message=null)
        job=scope.launch {
            try {
                val next=source.latest()?.takeIf { it.available }
                if(generation!=operation) return@launch
                mutable.value=if(next==null) UpdateState(message=if(automatic) null else "已是最新版本")
                    else UpdateState(UpdateStage.AVAILABLE,next,dialog=true)
            } catch(e: CancellationException) { throw e }
            catch(e: Exception) { mutable.value=previous.copy(message=if(automatic) previous.message else e.userMessage()) }
        }
    }
    fun showDialog() { mutable.update { it.copy(dialog=true) } }
    fun hideDialog() { mutable.update { it.copy(dialog=false) } }
    fun download() {
        val info=state.value.info ?: return
        if(state.value.busy) return
        val generation=++operation
        mutable.update { it.copy(stage=UpdateStage.DOWNLOADING,downloaded=null,bytes=0,total=info.size,message=null) }
        job=scope.launch {
            var pending: File?=null
            try {
                val result=source.download(info,directory) { bytes,total -> if(generation==operation) mutable.update { it.copy(bytes=bytes,total=total) } }
                pending=result.file
                mutable.update { it.copy(stage=UpdateStage.VERIFYING) }
                withContext(Dispatchers.IO) {
                    verifier.verify(result.file,result.update)
                    ensureActive()
                    require(result.file.renameTo(target)) { "无法保存安装包" }
                }
                preferences.edit().putString("downloaded",result.update.json().toString()).apply()
                mutable.value=UpdateState(UpdateStage.READY,result.update,target,dialog=false,installRequested=true)
            } catch(e: CancellationException) { pending?.delete(); throw e }
            catch(e: Exception) { pending?.delete(); mutable.update { it.copy(stage=UpdateStage.ERROR,message=e.userMessage()) } }
        }
    }
    fun cancelDownload() {
        if(state.value.stage !in listOf(UpdateStage.DOWNLOADING,UpdateStage.VERIFYING)) return
        operation++; job?.cancel(); source.cancel()
        mutable.update { it.copy(stage=UpdateStage.AVAILABLE,bytes=0,message=null) }
    }
    fun requestInstall() { if(state.value.downloaded!=null) mutable.update { it.copy(installRequested=true,dialog=false,message=null) } }
    fun consumeInstallRequest() { mutable.update { it.copy(installRequested=false) } }
    suspend fun verifiedInstallerFile(): File {
        val s=state.value; val file=s.downloaded ?: error("请重新下载安装包")
        withContext(Dispatchers.IO) { verifier.verify(file,s.info ?: error("安装包信息丢失")) }
        return file
    }
    fun awaitingPermission(value: Boolean) {
        preferences.edit().putBoolean("awaitingPermission",value).apply()
        mutable.update { it.copy(awaitingPermission=value) }
    }
    fun installError(error: Throwable) { mutable.update { it.copy(stage=UpdateStage.ERROR,installRequested=false,message=error.userMessage(),dialog=true) } }
    fun invalidateDownload(error: Throwable) {
        target.delete(); preferences.edit().remove("downloaded").remove("awaitingPermission").apply()
        mutable.update { it.copy(downloaded=null,awaitingPermission=false) }; installError(error)
    }
    fun installerReturned() { mutable.update { it.copy(installRequested=false) } }
    fun close() { job?.cancel(); source.close() }
}
