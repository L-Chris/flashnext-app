package com.rethinkos.flashnext_app

import java.time.Instant
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

data class ReviewState(val card: StudyCard? = null, val busy: Boolean = false, val revealed: Boolean = false,
    val ready: Boolean = false, val foreground: Boolean = true, val loaded: Boolean = false,
    val visit: Int = 0, val canUndo: Boolean = false, val error: String? = null, val notice: String? = null,
    val countdownSeconds: Int? = null) {
    val canRate get() = card != null && revealed && ready && !busy && foreground
}
/** A server snapshot is consumed locally; FSRS and learning deadlines remain server-authoritative. */
class ReviewSession(val api: StudyApi, val deck: Int, parent: CoroutineScope,
    private val clock: () -> Long = { System.nanoTime() / 1_000_000 },
    private val wallClock: () -> Long = { System.currentTimeMillis() },
    private val stopAudio: () -> Unit = {},
    private val autoplay: (List<Media>) -> Unit = {},
    private val warmAudio: (List<Media>) -> Unit = {}) {
    private val job = SupervisorJob(parent.coroutineContext[Job])
    private val scope = CoroutineScope(parent.coroutineContext + job)
    private val mutable = MutableStateFlow(ReviewState())
    val state = mutable.asStateFlow()
    private var queue = emptyList<StudyCard>()
    private var lastRated: Int? = null
    private val learningDue = mutableMapOf<Int, Long>()
    private var loadedAt: Long? = null
    private var batch = 0
    private var refreshOnAdvance = false
    private var studied = 0L
    private var durationSince: Long? = null
    private var remaining: Long? = null
    private var countdownSince: Long? = null
    private var ticker: Job? = null
    private var automaticAllowed = true
    private var autoplayApplied = false
    private var closed = false
    val durationMs get() = studied + (durationSince?.let { clock() - it } ?: 0)
    private fun update(change: (ReviewState) -> ReviewState) { if (!closed) mutable.value = change(mutable.value) }
    private fun freeze() {
        durationSince?.let { studied += clock() - it }; durationSince = null
        countdownSince?.let { start -> remaining = remaining?.let { (it - (clock() - start)).coerceAtLeast(0) } }
        countdownSince = null; ticker?.cancel(); ticker = null
        update { it.copy(countdownSeconds=null) }
    }
    private fun resume() {
        val s = state.value
        if (!s.foreground || !s.ready || s.busy || s.card == null) return
        if (durationSince == null) durationSince = clock()
        if (s.revealed || !automaticAllowed || remaining == null) return
        countdownSince = clock()
        update { it.copy(countdownSeconds=((remaining!!+999)/1000).toInt()) }
        ticker?.cancel()
        ticker = scope.launch {
            while (isActive) {
                delay(50)
                val left=(remaining ?: Long.MAX_VALUE) - (clock() - (countdownSince ?: clock()))
                if (left<=0) { reveal(); break }
                update { it.copy(countdownSeconds=((left+999)/1000).toInt()) }
            }
        }
    }
    private fun begin(card: StudyCard?) {
        freeze(); stopAudio(); studied = 0
        automaticAllowed = true; autoplayApplied = false
        remaining = card?.presentation?.revealMs?.takeIf { it > 0 }?.toLong()
        update { it.copy(card = card, visit = it.visit + 1, ready = false, revealed = card?.presentation?.revealMs == 0) }
        warm()
    }
    private fun warm() {
        val s=state.value
        warmAudio(if(s.foreground) audioCandidates(s.card,queue.firstOrNull { it.id!=s.card?.id },s.revealed) else emptyList())
    }
    fun load() {
        if (state.value.busy || closed) return
        update { it.copy(busy = true, error = null, notice = null) }; begin(null)
        scope.launch { refresh() }
    }
    private suspend fun refresh(restored: StudyCard? = null) {
        try {
            val data = api.due(deck)
            if (closed) return
            queue = if (restored == null) data else listOf(restored) + data.filter { it.id != restored.id }
            loadedAt = clock(); batch = 20; refreshOnAdvance = false
            learningDue.entries.removeAll { it.value <= clock() }
            restored?.let { learningDue.remove(it.id) }
            queue.forEach { remember(it, true) }
            begin(queue.firstOrNull()); update { it.copy(loaded = true, busy = false, canUndo = lastRated != null) }
        } catch (e: CancellationException) { throw e
        } catch (e: Exception) {
            if (restored != null) { queue = listOf(restored); begin(restored)
                update { it.copy(loaded = true, busy = false, notice = "已撤销，队列刷新失败：${e.userMessage()}", canUndo = false) }
            } else update { it.copy(busy = false, error = e.userMessage(), canUndo = lastRated != null) }
        }
    }
    private fun dueMillis(card: StudyCard) = runCatching { Instant.parse(card.due).toEpochMilli() }.getOrNull()
    private fun remember(card: StudyCard, onlyFuture: Boolean = false) {
        if (!card.intraday) return
        val due = dueMillis(card) ?: run { refreshOnAdvance = true; return }
        val delay = due - wallClock()
        if (!onlyFuture || delay > 0) learningDue[card.id] = clock() + delay
    }
    private fun needsRefresh(): Boolean {
        val next = queue.firstOrNull() ?: return true
        if (batch <= 0 || refreshOnAdvance || loadedAt == null || clock() - loadedAt!! >= 120_000 || learningDue.values.any { it <= clock() }) return true
        return next.intraday && (dueMillis(next)?.let { it > wallClock() } ?: true)
    }
    fun contentUnavailable(visit: Int) {
        if (closed || visit != state.value.visit) return
        freeze(); stopAudio(); update { it.copy(ready = false) }
    }
    fun contentReady(visit: Int, back: Boolean, automatic: Boolean = true) {
        val s = state.value
        if (closed || s.visit != visit || s.revealed != back || s.ready || s.card == null) return
        automaticAllowed = automatic
        update { it.copy(ready = true) }; resume()
        val play = automatic && !autoplayApplied
        if (automatic) autoplayApplied = true
        if (play && s.foreground && !s.busy && s.card.presentation.autoplay) autoplay(s.card.media(back))
    }
    fun reveal() {
        val s = state.value
        if (closed || s.busy || !s.foreground || s.revealed || s.card == null) return
        freeze(); stopAudio(); remaining = null; autoplayApplied = false
        update { it.copy(revealed = true, ready = false) }
        warm()
    }
    fun foreground(value: Boolean) {
        if (closed || value == state.value.foreground) return
        update { it.copy(foreground = value) }
        if (!value) { refreshOnAdvance = true; warmAudio(emptyList()); freeze(); stopAudio() } else { warm(); resume() }
    }
    fun rate(rating: Int) {
        val s = state.value
        if (!s.canRate || rating !in 1..4 || closed) return
        val current = s.card!!
        warmAudio(emptyList()); freeze(); stopAudio(); update { it.copy(busy = true, notice = null) }
        scope.launch {
            try {
                val rated = api.review(current.id, rating, durationMs)
                if (closed) return@launch
                lastRated = rated.id; learningDue.remove(current.id); remember(rated); batch--
                queue = queue.filter { it.id != current.id }
                if (rated.presentation.version != current.presentation.version) refreshOnAdvance = true
                if (needsRefresh()) { begin(null); refresh() }
                else { begin(queue.first()); update { it.copy(busy = false, canUndo = true) } }
            } catch (e: CancellationException) { throw e
            } catch (e: Exception) {
                update { it.copy(busy = false, notice = "评分失败，请确认网络后再操作：${e.userMessage()}") }; warm(); resume()
            }
        }
    }
    fun undo() {
        val id = lastRated ?: return
        if (closed || state.value.busy) return
        warmAudio(emptyList()); freeze(); stopAudio(); update { it.copy(busy = true, error = null, notice = null) }
        scope.launch {
            try {
                val restored = api.undo(id)
                if (closed) return@launch
                lastRated = null; begin(null); refresh(restored)
            } catch (e: CancellationException) { throw e
            } catch (e: Exception) { update { it.copy(busy = false, notice = "撤销失败：${e.userMessage()}") }; warm(); resume() }
        }
    }
    fun close() { warmAudio(emptyList()); freeze(); stopAudio(); closed = true; job.cancel() }
}
