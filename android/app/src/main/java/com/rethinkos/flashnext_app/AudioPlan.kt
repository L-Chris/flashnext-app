package com.rethinkos.flashnext_app

import java.security.MessageDigest
import okhttp3.HttpUrl.Companion.toHttpUrl

const val AUDIO_CACHE_BYTES = 128L * 1024 * 1024
const val AUDIO_PREFETCH_FILE_BYTES = 1024L * 1024
const val AUDIO_PREFETCH_BATCH_BYTES = 2L * 1024 * 1024

data class AudioTrack(val url: String, val key: String, val bytes: Long)

/** A complete URL isolates servers and playback versions; unversioned legacy URLs expire with the session. */
fun audioTrack(api: HttpStudyApi, media: Media, session: String): AudioTrack {
    val url=api.resolveResource(media.url).toHttpUrl()
    val hash=media.sha256?.lowercase()?.takeIf { it.matches(Regex("[0-9a-f]{64}")) }
    val version=hash ?: if(!url.queryParameter("playback").isNullOrBlank()) "versioned" else "session:$session"
    val key=MessageDigest.getInstance("SHA-256").digest("$url\n$version".toByteArray(Charsets.UTF_8))
        .joinToString("") { "%02x".format(it) }
    return AudioTrack(url.toString(),"study-audio-v1:$key",media.bytes)
}

fun audioCandidates(card: StudyCard?, next: StudyCard?, back: Boolean): List<Media> {
    if(card==null || !card.presentation.autoplay) return emptyList()
    return card.media(back)+card.media(!back)+(if(next?.presentation?.autoplay==true) next.media(false) else emptyList())
}

fun audioPrefetchPlan(tracks: List<AudioTrack>): List<AudioTrack> {
    var remaining=AUDIO_PREFETCH_BATCH_BYTES
    return tracks.distinctBy { it.key }.filter {
        if(it.bytes !in 1..AUDIO_PREFETCH_FILE_BYTES || it.bytes>remaining) false
        else { remaining-=it.bytes; true }
    }
}
