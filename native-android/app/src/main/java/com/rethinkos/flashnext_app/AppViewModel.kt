package com.rethinkos.flashnext_app

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*

data class HomeState(val decks: List<Deck> = emptyList(), val loading: Boolean = false, val error: String? = null)
class AppViewModel(app: Application) : AndroidViewModel(app) {
    private val preferences = app.getSharedPreferences("flashnext", 0)
    private val legacy = app.getSharedPreferences("FlutterSharedPreferences", 0)
    var api = HttpStudyApi(runCatching { normalizeServer(preferences.getString("baseUrl", null)
        ?: legacy.getString("flutter.baseUrl", null) ?: DEFAULT_SERVER) }.getOrDefault(DEFAULT_SERVER))
        private set
    val audio = AudioController(app)
    private val mutable = MutableStateFlow(HomeState())
    val home = mutable.asStateFlow()
    var session: ReviewSession? = null; private set
    var deck: Deck? = null; private set
    private var loading: Job? = null
    init { refresh() }
    fun refresh() {
        loading?.cancel(); val source = api
        mutable.value = mutable.value.copy(loading = true, error = null)
        loading = viewModelScope.launch {
            try { val data = source.decks(); if (api === source) mutable.value = HomeState(data) }
            catch(e: CancellationException) { throw e }
            catch(e: Exception) { if (api === source) mutable.value = mutable.value.copy(loading = false, error = e.userMessage()) }
        }
    }
    fun server(value: String) {
        val url = normalizeServer(value)
        preferences.edit().putString("baseUrl", url).apply()
        leaveReview(false); api.close(); api = HttpStudyApi(url); refresh()
    }
    fun enterReview(value: Deck): ReviewSession {
        session?.close(); deck = value
        return ReviewSession(api, value.id, viewModelScope, stopAudio = audio::stop,
            autoplay = { audio.play(api, it) }).also { session = it; it.load() }
    }
    fun leaveReview(refresh: Boolean = true) { session?.close(); session = null; deck = null; if (refresh) refresh() }
    override fun onCleared() { session?.close(); audio.stop(); api.close() }
}
