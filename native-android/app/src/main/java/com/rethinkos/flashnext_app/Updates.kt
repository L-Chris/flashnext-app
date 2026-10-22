package com.rethinkos.flashnext_app

import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.Request
import org.json.JSONObject
import java.net.URI

data class Update(val version: String, val available: Boolean, val url: String)
fun parseVersion(value: String): List<Int>? = Regex("^[vV]?([0-9]+)\\.([0-9]+)\\.([0-9]+)(?:\\+[0-9]+)?$").matchEntire(value.trim())?.groupValues?.drop(1)?.map { it.toIntOrNull() ?: return null }
fun parseUpdate(body: JSONObject, current: String, abis: List<String>): Update? {
    if(body.optBoolean("draft") || body.optBoolean("prerelease")) return null
    val tag = body.text("tag_name"); val version = parseVersion(tag) ?: return null
    val currentVersion = parseVersion(current) ?: error("当前版本格式错误")
    val page = URI(body.text("html_url"))
    require(page.scheme == "https" && page.host == "github.com" && page.port == -1 && page.rawUserInfo == null && page.path == "/L-Chris/flashnext-app/releases/tag/$tag" && page.rawQuery == null && page.rawFragment == null) { "发布地址无效" }
    val normalized = version.joinToString(".")
    val prefix = "FlashNext-$normalized-android"
    val names = listOf("$prefix.apk") + abis.map { "$prefix-$it.apk" }
    val assets = body.rows("assets")
    val name = names.firstOrNull { name -> assets.any { it.text("name") == name && it.text("state") == "uploaded" && it.optLong("size") > 0 } }
        ?: error("新版本安装包尚未就绪")
    val available = version.zip(currentVersion).firstOrNull { (a,b) -> a != b }?.let { it.first > it.second } ?: false
    return Update(normalized, available, "https://github.com/L-Chris/flashnext-app/releases/download/$tag/$name")
}
suspend fun checkUpdate(api: HttpStudyApi): Update? = withContext(Dispatchers.IO) {
    val request = Request.Builder().url("https://api.github.com/repos/L-Chris/flashnext-app/releases/latest")
        .header("Accept", "application/vnd.github+json").header("User-Agent", "FlashNext-Android").build()
    api.client.newCall(request).execute().use { r ->
        if(r.code == 404) return@withContext null
        check(r.isSuccessful) { if(r.code in listOf(403,429)) "检查过于频繁，请稍后再试" else "无法连接 GitHub (${r.code})" }
        parseUpdate(JSONObject(r.body!!.string()), BuildConfig.VERSION_NAME, Build.SUPPORTED_ABIS.toList())
    }
}
