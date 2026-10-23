package com.rethinkos.flashnext_app

import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.Assert.*
import org.junit.Test
import java.time.Instant

@OptIn(ExperimentalCoroutinesApi::class)
class ReviewSessionTest {
    private class FakeApi : StudyApi {
        override val baseUrl = DEFAULT_SERVER
        var cards = (1..30).map { StudyCard(it) }
        var gets = 0; var posts = 0; var rated: StudyCard? = null; var reviewFailure = false; var failQueue = false
        var duration = -1L
        override suspend fun due(deck: Int): List<StudyCard> { gets++; if(failQueue) error("offline"); return cards }
        override suspend fun review(id: Int, rating: Int, duration: Long): StudyCard {
            posts++; if(reviewFailure) error("offline"); this.duration=duration
            val original = cards.first { it.id == id }; cards = cards.filter { it.id != id }
            return rated ?: original.copy(state=2,interval=1)
        }
        override suspend fun undo(id: Int): StudyCard = StudyCard(id).also { cards=listOf(it)+cards.filter { c -> c.id!=id } }
    }
    private fun ready(session: ReviewSession) { val s=session.state.value; session.contentReady(s.visit,s.revealed) }
    private fun answer(session: ReviewSession) { ready(session); session.reveal(); ready(session); session.rate(3) }
    @Test fun `preloading starts before rendering follows faces and cancels in background or on close`() = runTest {
        val api=FakeApi().apply { cards=(1..2).map { id -> StudyCard(id,presentation=Presentation(autoplay=true),
            media=listOf(Media("$id-front","front",0,"/$id/f"),Media("$id-back","back",0,"/$id/b"))) } }
        val warmed=mutableListOf<List<String>>(); var played=0
        val s=ReviewSession(api,1,backgroundScope,autoplay={played++},warmAudio={ warmed.add(it.map { m -> m.id }) })
        s.load(); runCurrent()
        assertEquals(listOf("1-front","1-back","2-front"),warmed.last()); assertEquals(0,played)
        ready(s); assertEquals(1,played)
        s.reveal(); assertEquals(listOf("1-back","1-front","2-front"),warmed.last())
        s.foreground(false); assertTrue(warmed.last().isEmpty())
        s.foreground(true); assertEquals("1-back",warmed.last().first()); assertEquals(1,played)
        s.close(); assertTrue(warmed.last().isEmpty())
    }
    @Test fun `twenty confirmations consume snapshot without per-card requests`() = runTest {
        val api=FakeApi(); val s=ReviewSession(api,1,backgroundScope,clock={testScheduler.currentTime})
        s.load(); runCurrent()
        repeat(19) { answer(s); runCurrent() }
        assertEquals(1,api.gets); assertEquals(20,s.state.value.card!!.id)
        answer(s); runCurrent(); assertEquals(2,api.gets); assertEquals(20,api.posts)
        s.close()
    }
    @Test fun `positive delay starts after ready pauses in background and manual flip cancels it`() = runTest {
        val api=FakeApi().apply { cards=listOf(StudyCard(1,presentation=Presentation(revealMs=1000))) }
        val s=ReviewSession(api,1,backgroundScope,clock={testScheduler.currentTime})
        s.load(); runCurrent(); advanceTimeBy(2000); assertFalse(s.state.value.revealed)
        ready(s); assertEquals(1,s.state.value.countdownSeconds)
        advanceTimeBy(400); s.foreground(false); assertNull(s.state.value.countdownSeconds)
        advanceTimeBy(5000); assertEquals(400,s.durationMs)
        s.foreground(true); advanceTimeBy(550); assertFalse(s.state.value.revealed)
        advanceTimeBy(100); runCurrent(); assertTrue(s.state.value.revealed); assertFalse(s.state.value.ready); assertNull(s.state.value.countdownSeconds)
        ready(s); assertTrue(s.state.value.canRate); s.close()
    }
    @Test fun `zero immediate back never autoplays front and old callbacks cannot mark a new visit ready`() = runTest {
        val api=FakeApi().apply { cards=listOf(StudyCard(1,presentation=Presentation(true,0),media=listOf(Media("a","front",0,"/a"),Media("b","back",0,"/b"))),StudyCard(2)) }
        val played=mutableListOf<List<Media>>(); val s=ReviewSession(api,1,backgroundScope,autoplay={played.add(it)})
        s.load(); runCurrent(); val old=s.state.value.visit
        s.contentReady(old,false); assertFalse(s.state.value.ready); ready(s)
        assertEquals(listOf("b"),played.single().map { it.id })
        s.rate(4); runCurrent(); s.contentReady(old,true); assertFalse(s.state.value.ready); s.close()
    }
    @Test fun `renderer fallback disables auto reveal and autoplay but allows manual rating`() = runTest {
        val api=FakeApi().apply { cards=listOf(StudyCard(1,presentation=Presentation(true,100))) }
        var plays=0; val s=ReviewSession(api,1,backgroundScope,clock={testScheduler.currentTime},autoplay={plays++})
        s.load(); runCurrent(); s.contentReady(s.state.value.visit,false,false); advanceTimeBy(1000)
        assertFalse(s.state.value.revealed); s.reveal(); s.contentReady(s.state.value.visit,true,false)
        assertTrue(s.state.value.canRate); assertEquals(0,plays); s.close()
    }
    @Test fun `due learning deadline triggers server reconciliation without reinserting immediately`() = runTest {
        val api=FakeApi(); val wall=Instant.parse("2026-10-22T00:00:00Z").toEpochMilli()
        api.rated=StudyCard(1,state=1,interval=0,due=Instant.ofEpochMilli(wall+60_000).toString())
        val s=ReviewSession(api,1,backgroundScope,clock={testScheduler.currentTime},wallClock={wall+testScheduler.currentTime})
        s.load(); runCurrent(); answer(s); runCurrent(); assertEquals(2,s.state.value.card!!.id); assertEquals(1,api.gets)
        advanceTimeBy(60_000); answer(s); runCurrent(); assertEquals(2,api.gets); s.close()
    }
    @Test fun `expiry background and changed settings invalidate snapshots`() = runTest {
        val api=FakeApi(); val s=ReviewSession(api,1,backgroundScope,clock={testScheduler.currentTime})
        s.load(); runCurrent(); advanceTimeBy(120_000); answer(s); runCurrent(); assertEquals(2,api.gets)
        s.foreground(false); s.foreground(true); answer(s); runCurrent(); assertEquals(3,api.gets)
        api.rated=StudyCard(3,presentation=Presentation(version=2)); answer(s); runCurrent(); assertEquals(4,api.gets); s.close()
    }
    @Test fun `failed rating is not repeated and retains answer and undo survives completion`() = runTest {
        val api=FakeApi().apply { cards=listOf(StudyCard(1)); reviewFailure=true }
        val s=ReviewSession(api,1,backgroundScope)
        s.load(); runCurrent(); answer(s); runCurrent(); assertEquals(1,api.posts); assertEquals(1,s.state.value.card!!.id); assertTrue(s.state.value.revealed)
        api.reviewFailure=false; s.rate(4); runCurrent(); assertNull(s.state.value.card); assertTrue(s.state.value.canUndo)
        api.failQueue=true; s.undo(); runCurrent(); assertEquals(1,s.state.value.card!!.id); assertNotNull(s.state.value.notice); s.close()
    }
    @Test fun `duration begins once excludes loading background and rerender`() = runTest {
        val api=FakeApi(); val s=ReviewSession(api,1,backgroundScope,clock={testScheduler.currentTime})
        s.load(); runCurrent(); advanceTimeBy(100); ready(s); advanceTimeBy(200)
        s.contentUnavailable(s.state.value.visit); advanceTimeBy(500); ready(s); advanceTimeBy(300)
        s.reveal(); ready(s); s.rate(3); runCurrent(); assertEquals(500,api.duration); s.close()
    }
}
