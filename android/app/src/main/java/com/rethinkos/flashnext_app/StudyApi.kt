package com.rethinkos.flashnext_app

import java.net.URI
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONTokener

const val DEFAULT_SERVER = "https://mem.home.rethinkos.com"
fun normalizeServer(value: String): String {
    val s = value.trim().trimEnd('/')
    val u = runCatching { URI(s) }.getOrElse { error("服务器地址无效") }
    require(u.scheme in listOf("https", "http") && !u.host.isNullOrEmpty() && u.rawUserInfo == null && u.rawQuery == null && u.rawFragment == null && u.path.orEmpty().isEmpty()) { "请输入完整服务器地址，例如 https://mem.home.rethinkos.com" }
    return s
}
fun sameOrigin(base: String, address: String): Boolean = runCatching {
    val a = URI(base); val b = a.resolve(address)
    fun port(u: URI) = if (u.port != -1) u.port else if (u.scheme == "https") 443 else 80
    a.scheme == b.scheme && a.host.equals(b.host, true) && port(a) == port(b) && b.rawUserInfo == null
}.getOrDefault(false)

interface StudyApi {
    val baseUrl: String
    suspend fun due(deck: Int): List<StudyCard>
    suspend fun review(id: Int, rating: Int, duration: Long): StudyCard
    suspend fun undo(id: Int): StudyCard
}
class HttpStudyApi(override val baseUrl: String, val client: OkHttpClient = OkHttpClient.Builder()
    .connectTimeout(8, TimeUnit.SECONDS).readTimeout(20, TimeUnit.SECONDS).callTimeout(30, TimeUnit.SECONDS)
    .retryOnConnectionFailure(false).followRedirects(false).build()) : StudyApi {
    private val previews = LinkedHashMap<String, Preview>(20, .75f, true)
    suspend fun request(path: String, body: JSONObject? = null): Any = withContext(Dispatchers.IO) {
        val request = Request.Builder().url("$baseUrl/api$path").apply {
            if (body != null) post(body.toString().toRequestBody("application/json; charset=utf-8".toMediaType()))
        }.build()
        client.newCall(request).execute().use { r ->
            val raw = r.body?.string().orEmpty()
            check(r.isSuccessful) { "服务器错误 (${r.code})" }
            var json = JSONTokener(raw).nextValue()
            if (json is String) json = JSONTokener(json).nextValue()
            check(json is JSONObject && json.has("data")) { "服务器响应格式异常" }
            json.get("data")
        }
    }
    suspend fun decks() = (request("/decks") as JSONArray).objects().map(Deck::parse)
    override suspend fun due(deck: Int) = (request("/decks/$deck/cards/due") as JSONObject).rows("cards").map(StudyCard::parse)
    override suspend fun review(id: Int, rating: Int, duration: Long) = StudyCard.parse(request("/cards/$id/review", JSONObject().put("rating", rating).put("durationMs", duration)) as JSONObject)
    override suspend fun undo(id: Int) = StudyCard.parse(request("/cards/$id/undo", JSONObject()) as JSONObject)
    suspend fun settings(id: Int) = DeckSettings.parse(request("/decks/$id/settings") as JSONObject)
    suspend fun saveSettings(id: Int, changes: JSONObject) = DeckSettings.parse(request("/decks/$id/settings", changes) as JSONObject)
    suspend fun timezone() = (request("/settings") as JSONObject).text("timezone")
    suspend fun saveTimezone(value: String) = (request("/settings", JSONObject().put("timezone", value)) as JSONObject).text("timezone")
    suspend fun preview(card: StudyCard): Preview {
        val key = JSONArray(listOf(card.front, card.back, card.format)).toString()
        synchronized(previews) { previews[key]?.let { return it } }
        val value = Preview.parse(request("/content/preview", JSONObject().put("front", card.front).put("back", card.back).put("contentFormat", card.format)) as JSONObject)
        val size = (value.front + value.back).toByteArray().size
        if (value.valid && size <= 2 * 1024 * 1024) synchronized(previews) {
            previews[key] = value
            while (previews.size > 20 || previews.values.sumOf { (it.front + it.back).toByteArray().size } > 4 * 1024 * 1024) previews.remove(previews.keys.first())
        }
        return value
    }
    fun resolveResource(address: String): String {
        require(sameOrigin(baseUrl, address)) { "不允许跨站资源" }
        return URI(baseUrl).resolve(address).toString()
    }
    fun close() { client.dispatcher.cancelAll(); client.connectionPool.evictAll() }
}
fun Throwable.userMessage(): String = when(this) {
    is java.net.SocketTimeoutException -> "连接超时，请检查网络或服务器地址"
    is java.io.IOException -> "无法连接服务器，请检查网络或服务器地址"
    else -> message ?: "操作失败"
}
