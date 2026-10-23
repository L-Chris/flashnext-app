package com.rethinkos.flashnext_app

import org.json.JSONObject
import java.net.URI

const val RELEASE_REPOSITORY = "L-Chris/flashnext-app"
const val MAX_UPDATE_BYTES = 100L * 1024 * 1024
data class Update(val version: String, val available: Boolean, val url: String,
    val size: Long = 0, val sha256: String? = null, val checksumsUrl: String = "",
    val assetId: Long = 0, val checksumsAssetId: Long = 0) {
    val fileName get() = url.substringAfterLast('/')
    fun json() = JSONObject().put("version",version).put("url",url).put("size",size)
        .put("sha256",sha256 ?: JSONObject.NULL).put("checksumsUrl",checksumsUrl)
        .put("assetId",assetId).put("checksumsAssetId",checksumsAssetId)
}
fun newerVersion(candidate: String, current: String): Boolean {
    val next=parseVersion(candidate) ?: return false; val installed=parseVersion(current) ?: return false
    return next.zip(installed).firstOrNull { (a,b) -> a!=b }?.let { it.first>it.second } ?: false
}
fun parseVersion(value: String): List<Int>? = Regex("^[vV]?(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(?:\\+[0-9]+)?$").matchEntire(value.trim())?.groupValues?.drop(1)?.map { it.toIntOrNull() ?: return null }
fun parseUpdate(body: JSONObject, current: String, abis: List<String>): Update? {
    if(body.optBoolean("draft") || body.optBoolean("prerelease")) return null
    val tag = body.text("tag_name"); val version = parseVersion(tag) ?: return null
    val currentVersion = parseVersion(current) ?: error("当前版本格式错误")
    val page = URI(body.text("html_url"))
    require(page.scheme == "https" && page.host == "github.com" && page.port == -1 && page.rawUserInfo == null && page.path == "/L-Chris/flashnext-app/releases/tag/$tag" && page.rawQuery == null && page.rawFragment == null) { "发布地址无效" }
    val normalized = version.joinToString(".")
    val prefix = "FlashNext-$normalized-android"
    val names = abis.map { "$prefix-$it.apk" } + "$prefix.apk"
    val assets = body.rows("assets")
    val name = names.firstOrNull { name -> assets.any { it.text("name") == name && it.text("state") == "uploaded" && it.optLong("size") in 1..MAX_UPDATE_BYTES } }
        ?: error("新版本安装包尚未就绪")
    val available = version.zip(currentVersion).firstOrNull { (a,b) -> a != b }?.let { it.first > it.second } ?: false
    val asset=assets.first { it.text("name")==name }
    val digest=asset.text("digest").takeIf { it.matches(Regex("sha256:[0-9a-fA-F]{64}")) }?.substringAfter(':')?.lowercase()
    return Update(normalized, available, "https://github.com/$RELEASE_REPOSITORY/releases/download/$tag/$name",asset.optLong("size"),digest,
        "https://github.com/$RELEASE_REPOSITORY/releases/download/$tag/SHA256SUMS.txt",asset.optLong("id").coerceAtLeast(0),
        assets.firstOrNull { it.text("name")=="SHA256SUMS.txt" && it.text("state")=="uploaded" }?.optLong("id")?.coerceAtLeast(0) ?: 0)
}
