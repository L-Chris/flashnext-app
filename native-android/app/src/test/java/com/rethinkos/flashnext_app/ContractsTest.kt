package com.rethinkos.flashnext_app

import kotlinx.coroutines.test.runTest
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.json.JSONObject
import org.junit.Assert.*
import org.junit.Test

class ContractsTest {
    @Test fun `nullable delay is explicit while unchanged settings are omitted`() {
        val saved=DeckSettings(revealSeconds=5)
        val patch=saved.copy(revealSeconds=null).changesFrom(saved)
        assertEquals(setOf("autoRevealAnswerSeconds"),patch.keys().asSequence().toSet()); assertTrue(patch.isNull("autoRevealAnswerSeconds"))
        assertEquals(0,saved.changesFrom(saved).length())
        assertEquals(0,StudyCard.parse(JSONObject("""{"id":1,"presentation":{"answerRevealAfterMs":0}}""")).presentation.revealMs)
        assertNull(StudyCard.parse(JSONObject("""{"id":1}""")).presentation.revealMs)
    }
    @Test fun `envelopes including deployed double encoded responses remain compatible`() = runTest {
        val server=MockWebServer(); server.start()
        val api=HttpStudyApi(server.url("/").toString().trimEnd('/'))
        try {
            val body="""{"message":"ok","data":[{"id":1,"name":"English"}]}"""
            server.enqueue(MockResponse().setBody(JSONObject.quote(body)))
            assertEquals("English",api.decks().single().name)
            server.enqueue(MockResponse().setBody("""{"data":{"deckId":1,"autoRevealAnswerSeconds":null}}"""))
            api.saveSettings(1,DeckSettings().changesFrom(DeckSettings(revealSeconds=3)))
            server.takeRequest(); val post=server.takeRequest()
            assertEquals("POST",post.method); assertEquals("/api/decks/1/settings",post.path)
            assertTrue(JSONObject(post.body.readUtf8()).isNull("autoRevealAnswerSeconds"))
            server.enqueue(MockResponse().setResponseCode(503))
            runCatching { api.review(1,3,150) }; assertEquals(3,server.requestCount)
        } finally { api.close(); server.shutdown() }
    }
    @Test fun `preview cache is keyed by complete content and only caches valid renders`() = runTest {
        val server=MockWebServer(); server.start(); val api=HttpStudyApi(server.url("/").toString().trimEnd('/'))
        try {
            val ok="""{"data":{"front":{"html":"<p>x</p>","errors":[]},"back":{"html":"<p>y</p>","errors":[]},"valid":true}}"""
            server.enqueue(MockResponse().setBody(ok)); val card=StudyCard(1,front="x",back="y",format="markdown_math")
            api.preview(card); api.preview(card.copy(id=2)); assertEquals(1,server.requestCount)
            server.enqueue(MockResponse().setBody(ok.replace("true","false"))); api.preview(card.copy(back="invalid"))
            server.enqueue(MockResponse().setBody(ok)); api.preview(card.copy(back="invalid")); assertEquals(3,server.requestCount)
        } finally { api.close(); server.shutdown() }
    }
    @Test fun `untrusted URLs and malformed versions cannot become update downloads`() {
        val body=JSONObject("""{"tag_name":"v0.3.0","html_url":"https://github.com/L-Chris/flashnext-app/releases/tag/v0.3.0","assets":[{"name":"FlashNext-0.3.0-android.apk","state":"uploaded","size":100,"browser_download_url":"https://evil.example/steal"}]}""")
        val next=parseUpdate(body,"0.2.0",listOf("arm64-v8a"))!!
        assertTrue(next.available); assertEquals("https://github.com/L-Chris/flashnext-app/releases/download/v0.3.0/FlashNext-0.3.0-android.apk",next.url)
        assertFalse(parseUpdate(body,"0.4.0",emptyList())!!.available)
        assertNull(parseUpdate(JSONObject(body.toString()).put("prerelease",true),"0.2.0",emptyList()))
        assertNull(parseUpdate(JSONObject(body.toString()).put("tag_name","v0.3.0-rc1"),"0.2.0",emptyList()))
        assertNull(parseVersion("v0.03.0"))
        assertTrue(runCatching { parseUpdate(body.put("html_url","https://github.com.evil.example/L-Chris/flashnext-app/releases/tag/v0.3.0"),"0.2.0",emptyList()) }.isFailure)
        assertFalse(sameOrigin(DEFAULT_SERVER,"https://evil.example/font.woff2")); assertFalse(sameOrigin(DEFAULT_SERVER,"https://x@mem.home.rethinkos.com/font"))
        assertEquals(DEFAULT_SERVER,normalizeServer(" $DEFAULT_SERVER/ "))
    }
    @Test fun `pronunciation grouping preserves whole label sets accents and preferred sound`() {
        fun p(ipa: String,pos: String,usage: String,accent: String="UK")=Pronunciation(ipa,accent,pos,"accepted",usage)
        val items=listOf(p("red","verb","过去式"),p("ri:d","verb","阅读"),p("ri:d","noun","读物"),p("reed","verb","阅读"),p("ri:d","verb","阅读","US"))
        val groups=presentPronunciations(items,"ri:d")
        assertEquals(listOf("/ri:d/"),groups.groups.first().ipas)
        assertEquals(2,groups.groups.first().labels.size)
        assertEquals(4,groups.groups.size); assertEquals("英",groups.groups.first().accentLabel)
        val alternatives=presentPronunciations(listOf(p("a","noun","名词读法"),p("b","noun","名词读法")),"a")
        assertEquals(listOf("/a/","/b/"),alternatives.groups.single().ipas); assertEquals(listOf("n."),alternatives.groups.single().labels)
        assertEquals("[r]",phonetic(" [r] ")); assertEquals("/a.b/",phonetic("a.b"))
    }
    @Test fun `custom and Japanese backs retain original content and dictionary newlines normalize`() {
        val word=Word("en","","noun","a","n. 一\\n v. 二",emptyList(),emptyList())
        val generated=StudyCard(1,back="/a/\nn. 一\n v. 二",word=word)
        assertTrue(generatedBack(generated)); assertFalse(generatedBack(generated.copy(back="my notes")))
        val japanese=word.copy(language="ja",reading="あ",pos="名詞",translation="一")
        assertTrue(generatedBack(StudyCard(2,back="あ\n名詞\n一",word=japanese)))
        assertFalse(generatedBack(StudyCard(2,back="custom",word=japanese)))
        val notes=listOf(Pronunciation("a","UK","noun","accepted","一；二"),Pronunciation("b","UK","verb","accepted","三"))
        assertTrue(notesCoverMeanings("n. 一、二\nv. 三",notes)); assertFalse(notesCoverMeanings("n. 一、四",notes)); assertFalse(notesCoverMeanings("n. 一",notes.take(1)))
    }
}
