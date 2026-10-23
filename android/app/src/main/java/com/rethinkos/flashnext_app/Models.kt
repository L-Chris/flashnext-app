package com.rethinkos.flashnext_app

import org.json.JSONArray
import org.json.JSONObject

fun JSONObject.text(key: String, fallback: String = "") = if (isNull(key)) fallback else optString(key, fallback)
fun JSONObject.nullInt(key: String): Int? = if (isNull(key)) null else optInt(key)
fun JSONObject.rows(key: String): List<JSONObject> = optJSONArray(key).objects()
fun JSONArray?.objects(): List<JSONObject> = if (this == null) emptyList() else (0 until length()).mapNotNull { optJSONObject(it) }
fun jsonList(value: String): List<String> = runCatching { JSONArray(value).let { a -> (0 until a.length()).mapNotNull { a.opt(it) as? String } } }.getOrDefault(emptyList())

data class Deck(val id: Int, val name: String, val description: String = "", val dueCount: Int = 0, val intraday: Int = 0, val fresh: Int = 0) {
    companion object { fun parse(j: JSONObject) = Deck(j.optInt("id"), j.text("name"), j.text("description"), j.optInt("dueCount"), j.optJSONObject("counts")?.optInt("intraday") ?: 0, j.optJSONObject("counts")?.optInt("fresh") ?: 0) }
}
data class Media(val id: String, val side: String, val position: Int, val url: String,
    val bytes: Long = 0, val sha256: String? = null)
data class Pronunciation(val ipa: String, val accent: String, val pos: String, val status: String, val usage: String)
data class Sense(val examples: String, val details: String, val zh: String)
data class Word(val language: String, val reading: String, val pos: String, val phonetic: String,
    val translation: String, val pronunciations: List<Pronunciation>, val senses: List<Sense>) {
    companion object { fun parse(j: JSONObject) = Word(j.text("language", "en"), j.text("reading"), j.text("pos"),
        j.text("phonetic"), j.text("translation"), j.rows("pronunciations").map {
            Pronunciation(it.text("displayIpa"), it.text("accent"), it.text("pos"), it.text("status"), it.text("usage"))
        }, j.rows("senses").take(3).map { Sense(it.text("examples", "[]"), it.text("exampleDetails", "[]"), it.text("zh", "[]")) }) }
}
data class Presentation(val autoplay: Boolean = false, val revealMs: Int? = null, val version: Int = 0)
data class StudyCard(val id: Int, val front: String = "", val back: String = "", val format: String = "plain",
    val state: Int = 0, val interval: Int = 0, val due: String = "", val presentation: Presentation = Presentation(),
    val media: List<Media> = emptyList(), val word: Word? = null) {
    val intraday get() = interval == 0 && state in listOf(1, 3)
    fun media(back: Boolean) = media.filter { it.side == if (back) "back" else "front" }.sortedWith(compareBy({ it.position }, { it.id }))
    companion object { fun parse(j: JSONObject): StudyCard {
        val p = j.optJSONObject("presentation") ?: JSONObject()
        return StudyCard(j.optInt("id"), j.text("front"), j.text("back"), j.text("contentFormat", "plain"),
            j.optInt("state"), j.optInt("interval"), j.text("due"),
            Presentation(p.optBoolean("audioAutoplay"), p.nullInt("answerRevealAfterMs"), p.optInt("settingsVersion")),
            j.rows("media").map { Media(it.text("mediaId"), it.text("side", "front"), it.optInt("position"), it.text("url"),
                it.optLong("bytes"), it.text("sha256").ifBlank { it.optJSONObject("playback")?.text("sha256").orEmpty() }.takeIf { hash -> hash.isNotBlank() }) },
            j.optJSONObject("word")?.let(Word::parse))
    } }
}
data class DeckSettings(val newPerDay: Int = 20, val reviewPerDay: Int = 500, val rolloverHour: Int = 4,
    val autoplay: Boolean = false, val immediate: Boolean = false, val revealSeconds: Int? = null) {
    fun json() = JSONObject().put("newPerDay", newPerDay).put("reviewPerDay", reviewPerDay)
        .put("rolloverHour", rolloverHour).put("audioAutoplay", autoplay)
        .put("showNewCardAnswerImmediately", immediate).put("autoRevealAnswerSeconds", revealSeconds ?: JSONObject.NULL)
    fun changesFrom(old: DeckSettings): JSONObject {
        val a = json(); val b = old.json(); val changes = JSONObject()
        a.keys().forEach { if (a.get(it) != b.get(it)) changes.put(it, a.get(it)) }
        return changes
    }
    companion object { fun parse(j: JSONObject) = DeckSettings(j.optInt("newPerDay", 20), j.optInt("reviewPerDay", 500),
        j.optInt("rolloverHour", 4), j.optBoolean("audioAutoplay"), j.optBoolean("showNewCardAnswerImmediately"), j.nullInt("autoRevealAnswerSeconds")) }
}
data class Preview(val front: String, val back: String, val css: String, val valid: Boolean) {
    companion object { fun parse(j: JSONObject): Preview {
        val f = j.getJSONObject("front"); val b = j.getJSONObject("back")
        return Preview(f.text("html"), b.text("html"), j.optJSONObject("renderer")?.text("cssUrl", "/api/content/assets/katex.min.css") ?: "/api/content/assets/katex.min.css",
            j.optBoolean("valid") && f.rows("errors").isEmpty() && b.rows("errors").isEmpty())
    } }
}

fun normalizeDictionary(text: String) = text.replace(Regex("\\\\+r\\\\+n|\\\\+[nr]|\\r\\n?"), "\n")
fun generatedBack(card: StudyCard): Boolean {
    val w = card.word ?: return false
    if (card.format != "plain") return false
    if (w.language == "ja") return card.back == listOf(w.reading, w.pos, w.translation).filter { it.isNotEmpty() }.joinToString("\n")
    val lines = normalizeDictionary(card.back).lines().toMutableList()
    if (lines.firstOrNull()?.matches(Regex("^/[^\\n]+/$")) == true) lines.removeAt(0)
    return lines.joinToString("\n") == normalizeDictionary(w.translation)
}
fun phonetic(value: String): String {
    val s = value.trim(); if (s.isEmpty()) return ""
    return if (s.startsWith('[') && s.endsWith(']')) s else "/${s.trim('/')}/"
}
private val posLabels = mapOf("noun" to "n.", "verb" to "v.", "adj" to "adj.", "adv" to "adv.", "prep" to "prep.", "pron" to "pron.", "intj" to "int.", "conj" to "conj.", "det" to "det.", "num" to "数词", "name" to "专名", "particle" to "小品词", "phrase" to "短语", "postp" to "后置词", "prep_phrase" to "介词短语")
private val etymology = Regex("^词源 .*? · ")
private val genericUsage = Regex("^(?:名词|动词|形容词|副词|介词|代词|感叹词|连词|限定词|数词|专名)读法$")
data class PronunciationGroup(val accent: String, val ipas: List<String>, val labels: List<String>) {
    val accentLabel get() = when(accent.uppercase()) { "UK" -> "英"; "US" -> "美"; else -> accent }
}
data class Pronunciations(val groups: List<PronunciationGroup>, val showLabels: Boolean)
fun presentPronunciations(items: List<Pronunciation>, fallback: String): Pronunciations {
    val sounds = linkedMapOf<Pair<String, String>, MutableSet<String>>()
    items.filter { it.status == "accepted" && it.ipa.isNotBlank() }.forEach {
        val usage = it.usage.replace(etymology, "").trim()
        val label = listOf(posLabels[it.pos] ?: it.pos, if (genericUsage.matches(usage)) "" else usage).filter { s -> s.isNotEmpty() }.joinToString(" ")
        sounds.getOrPut(it.accent to phonetic(it.ipa)) { linkedSetOf() }.add(label)
    }
    val groups = linkedMapOf<Pair<String, List<String>>, MutableList<String>>()
    sounds.entries.sortedBy { if (it.key.second == phonetic(fallback)) 0 else 1 }.forEach { (sound, labels) ->
        groups.getOrPut(sound.first to labels.filter { it.isNotEmpty() }.sorted()) { mutableListOf() }.add(sound.second)
    }
    return Pronunciations(groups.map { (k, v) -> PronunciationGroup(k.first, v, k.second) }, sounds.size > 1)
}
fun notesCoverMeanings(meanings: String, items: List<Pronunciation>): Boolean {
    val accepted = items.filter { it.status == "accepted" && it.ipa.isNotBlank() }
    if (accepted.map { it.accent to phonetic(it.ipa) }.distinct().size < 2 || meanings.isBlank()) return false
    val positions = mapOf("n" to "noun", "v" to "verb", "adj" to "adj", "adv" to "adv", "prep" to "prep", "pron" to "pron", "conj" to "conj", "det" to "det", "int" to "intj", "num" to "num")
    fun terms(s: String) = s.split(Regex("[,，、;；]")).map { it.replace(Regex("\\s+"), "") }.filter { it.isNotEmpty() }
    val covered = accepted.groupBy { it.pos }.mapValues { (_, values) -> values.flatMap { terms(it.usage.replace(etymology, "").replace(Regex("^.*[：:]"), "")) }.filter { it.contains(Regex("[\\p{IsHan}]")) }.toSet() }
    return meanings.lines().filter { it.isNotBlank() }.all { line ->
        val m = Regex("^([a-z]+)\\.\\s*(.+)$").matchEntire(line.trim()) ?: return@all false
        val glosses = terms(m.groupValues[2]); val pos = positions[m.groupValues[1]]
        pos != null && glosses.isNotEmpty() && glosses.all { covered[pos]?.contains(it) == true }
    }
}
