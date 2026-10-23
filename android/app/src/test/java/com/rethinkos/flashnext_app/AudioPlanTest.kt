package com.rethinkos.flashnext_app

import org.json.JSONObject
import org.junit.Assert.*
import org.junit.Test

class AudioPlanTest {
    @Test fun `cache keys isolate servers versions and legacy sessions`() {
        val a=HttpStudyApi("https://one.example"); val b=HttpStudyApi("https://two.example")
        try {
            val media=Media("m","front",0,"/api/media/m/content",40,"a".repeat(64))
            val key=audioTrack(a,media,"first").key
            assertEquals(key,audioTrack(a,media,"second").key)
            assertNotEquals(key,audioTrack(b,media,"first").key)
            assertNotEquals(key,audioTrack(a,media.copy(sha256="b".repeat(64)),"first").key)
            val versioned=media.copy(sha256=null,url=media.url+"?playback=v1")
            assertEquals(audioTrack(a,versioned,"first").key,audioTrack(a,versioned,"second").key)
            assertNotEquals(audioTrack(a,versioned,"first").key,audioTrack(a,versioned.copy(url=media.url+"?playback=v2"),"first").key)
            assertNotEquals(audioTrack(a,media.copy(sha256=null),"first").key,audioTrack(a,media.copy(sha256=null),"second").key)
            assertTrue(runCatching { audioTrack(a,media.copy(url="https://evil.example/audio"),"first") }.isFailure)
        } finally { a.close(); b.close() }
    }
    @Test fun `preload candidates respect face ordering autoplay and byte limits`() {
        val front=Media("front","front",0,"/f"); val back=Media("back","back",0,"/b")
        val card=StudyCard(1,presentation=Presentation(autoplay=true),media=listOf(back,front))
        val next=StudyCard(2,presentation=Presentation(autoplay=true),media=listOf(Media("next","front",0,"/next")))
        assertEquals(listOf("front","back","next"),audioCandidates(card,next,false).map { it.id })
        assertEquals(listOf("back","front","next"),audioCandidates(card,next,true).map { it.id })
        assertTrue(audioCandidates(card.copy(presentation=Presentation()),next,false).isEmpty())
        val tracks=listOf(AudioTrack("a","a",AUDIO_PREFETCH_FILE_BYTES),AudioTrack("a","a",AUDIO_PREFETCH_FILE_BYTES),
            AudioTrack("large","large",AUDIO_PREFETCH_FILE_BYTES+1),AudioTrack("unknown","unknown",0),
            AudioTrack("b","b",AUDIO_PREFETCH_FILE_BYTES),AudioTrack("c","c",1))
        assertEquals(listOf("a","b"),audioPrefetchPlan(tracks).map { it.key })
    }
    @Test fun `media reads new selected hashes and existing playback hashes`() {
        fun parse(extra: String)=StudyCard.parse(JSONObject("""{"id":1,"media":[{"mediaId":"m","url":"/m","bytes":32,$extra}]}""")).media.single()
        assertEquals("a".repeat(64),parse("\"sha256\":\"${"a".repeat(64)}\"").sha256)
        assertEquals("b".repeat(64),parse("\"playback\":{\"sha256\":\"${"b".repeat(64)}\"}").sha256)
        assertEquals(32L,parse("\"side\":\"front\"").bytes)
        assertNull(parse("\"side\":\"front\"").sha256)
    }
}
