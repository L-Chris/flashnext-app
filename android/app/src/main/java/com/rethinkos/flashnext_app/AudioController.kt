package com.rethinkos.flashnext_app

import android.content.Context
import android.media.AudioManager
import android.os.SystemClock
import android.util.Log
import androidx.media3.common.*
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import java.util.UUID
import java.util.concurrent.atomic.AtomicReference
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

data class AudioState(val playing: Boolean = false, val error: String? = null, val loading: Boolean = false)

/** All controller/player methods run on Main; disk and prefetch work runs on IO. */
@androidx.annotation.OptIn(UnstableApi::class)
class AudioController(private val context: Context, private val store: AudioStore=AudioStores.get(context),
    private val createPlayer: (Context)->ExoPlayer={ ExoPlayer.Builder(it).build() }) {
    private val scope=CoroutineScope(SupervisorJob()+Dispatchers.Main.immediate)
    private var player: ExoPlayer?=null
    private var listener: Player.Listener?=null
    private var playback: Job?=null
    private var prefetch: Job?=null
    private val transfer=AtomicReference<AudioTransfer?>(null)
    private val prefetchGate=Mutex()
    private var plan=emptyList<AudioTrack>()
    private var generation=0L
    private var session=UUID.randomUUID().toString()
    private var closed=false
    private val mutable=MutableStateFlow(AudioState())
    val state=mutable.asStateFlow()

    fun warm(api: HttpStudyApi, media: List<Media>) {
        if(closed) return
        val next=runCatching { audioPrefetchPlan(media.map { audioTrack(api,it,session) }) }.getOrDefault(emptyList())
        if(next==plan) return
        plan=next
        val previous=cancelPrefetch()
        startPrefetch(previous)
    }
    private fun cancelPrefetch(): Job? {
        transfer.getAndSet(null)?.cancel()
        return prefetch.also { prefetch=null; it?.cancel() }
    }
    private fun startPrefetch(previous: Job?=null) {
        if(closed || plan.isEmpty() || mutable.value.playing || mutable.value.loading || prefetch?.isActive==true) return
        val tracks=plan
        prefetch=scope.launch {
            try {
                previous?.join()
                prefetchGate.withLock {
                    val cache=store.cache() ?: return@withLock
                    for(track in tracks) {
                        ensureActive()
                        if(cache.isCached(track.key,0,track.bytes)) continue
                        withContext(Dispatchers.IO) {
                            val next=store.transfer(cache,track)
                            transfer.set(next)
                            try { ensureActive(); next.run() }
                            catch(e: CancellationException) { throw e }
                            catch(_: Exception) { /* Speculative failures never affect the review screen. */ }
                            finally { next.cancel(); transfer.compareAndSet(next,null) }
                        }
                    }
                }
            } catch(e: CancellationException) { throw e }
            catch(_: Exception) { /* A broken cache must not break the study session. */ }
        }
    }
    fun play(api: HttpStudyApi, media: List<Media>) {
        if(closed) return
        stopPlayback()
        if(media.isEmpty()) return
        try { launchPlayback(media.map { audioTrack(api,it,session) }) }
        catch(_: Exception) { mutable.value=AudioState(error="无法加载音频") }
    }
    private fun launchPlayback(tracks: List<AudioTrack>, bypass: Boolean=false, damagedKey: String?=null,
        requestedAt: Long=SystemClock.elapsedRealtime()) {
        val token=generation
        val previous=cancelPrefetch()
        mutable.value=AudioState(loading=true)
        playback=scope.launch {
            try {
                previous?.join()
                prefetchGate.withLock { /* Wait asynchronously for canceled writers to release their spans. */ }
                if(damagedKey!=null) store.evict(damagedKey)
                val factory=DefaultMediaSourceFactory(store.factory(bypass,tracks))
                ensureActive()
                if(token!=generation) return@launch
                val p=player ?: createPlayer(context).also {
                    player=it; it.volume=1f
                    it.setAudioAttributes(AudioAttributes.Builder().setUsage(C.USAGE_MEDIA).setContentType(C.AUDIO_CONTENT_TYPE_SPEECH).build(),true)
                    it.setHandleAudioBecomingNoisy(true)
                }
                var reported=false
                val events=object: Player.Listener {
                    fun current()=token==generation && player===p
                    override fun onPlaybackSuppressionReasonChanged(reason: Int) {
                        if(current() && reason==Player.PLAYBACK_SUPPRESSION_REASON_TRANSIENT_AUDIO_FOCUS_LOSS) stop()
                    }
                    override fun onPlayWhenReadyChanged(ready: Boolean,reason: Int) {
                        if(current() && !ready && reason in listOf(Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_FOCUS_LOSS,Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_BECOMING_NOISY)) stop()
                    }
                    override fun onIsPlayingChanged(playing: Boolean) {
                        if(!current()) return
                        mutable.value=mutable.value.copy(playing=playing)
                        if(BuildConfig.DEBUG && playing && !reported) {
                            reported=true
                            Log.d("StudyAudio","generation=$token; readyMs=${SystemClock.elapsedRealtime()-requestedAt}")
                        }
                    }
                    override fun onPlayerError(error: PlaybackException) {
                        if(!current()) return
                        val index=p.currentMediaItemIndex.coerceIn(0,tracks.lastIndex)
                        val recoverable=error.errorCode in 3000..4999 || generateSequence<Throwable>(error) { it.cause }
                            .any { it is androidx.media3.datasource.cache.Cache.CacheException || it is androidx.media3.datasource.FileDataSource.FileDataSourceException }
                        stopPlayback()
                        if(!bypass && recoverable) launchPlayback(tracks.drop(index),true,tracks[index].key,requestedAt)
                        else { mutable.value=AudioState(error="音频播放失败，可点击重新播放"); startPrefetch() }
                    }
                    override fun onPlaybackStateChanged(playbackState: Int) {
                        if(!current()) return
                        if(playbackState==Player.STATE_ENDED) stop()
                        else mutable.value=mutable.value.copy(loading=playbackState==Player.STATE_BUFFERING)
                    }
                }
                listener=events; p.addListener(events)
                if(BuildConfig.DEBUG) {
                    val manager=context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                    val outputs=manager.getDevices(AudioManager.GET_DEVICES_OUTPUTS).joinToString(",") { it.type.toString() }
                    Log.d("StudyAudio","playerVolume=${p.volume}; mediaVolume=${manager.getStreamVolume(AudioManager.STREAM_MUSIC)}/${manager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)}; mediaMuted=${manager.isStreamMute(AudioManager.STREAM_MUSIC)}; mode=${manager.mode}; availableOutputs=$outputs; files=${tracks.size}")
                }
                p.setMediaSources(tracks.map { track -> factory.createMediaSource(MediaItem.Builder().setUri(track.url)
                    .setMediaId("$token:${track.key}").setCustomCacheKey(track.key).build()) })
                p.prepare(); p.play()
            } catch(e: CancellationException) { throw e }
            catch(_: Exception) {
                if(token==generation) { stopPlayback(); mutable.value=AudioState(error="无法加载音频") }
            }
        }
    }
    private fun stopPlayback() {
        generation++; playback?.cancel(); playback=null
        player?.let { p -> listener?.let { p.removeListener(it) }; listener=null; p.pause(); p.stop(); p.clearMediaItems() }
        mutable.value=AudioState()
    }
    fun stop() { stopPlayback(); startPrefetch() }
    fun suspendPlayback() {
        plan=emptyList(); cancelPrefetch(); stopPlayback()
        player?.release(); player=null
    }
    fun endSession() { suspendPlayback(); session=UUID.randomUUID().toString() }
    fun close() { closed=true; suspendPlayback(); scope.cancel() }
    internal suspend fun awaitClosed() { scope.coroutineContext[Job]?.join() }
}
