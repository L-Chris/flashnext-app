package com.rethinkos.flashnext_app

import android.content.Context
import androidx.media3.common.*
import androidx.media3.exoplayer.ExoPlayer
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

data class AudioState(val playing: Boolean = false, val error: String? = null, val loading: Boolean = false)
class AudioController(private val context: Context) {
    private var player: ExoPlayer? = null
    private val mutable = MutableStateFlow(AudioState())
    val state = mutable.asStateFlow()
    fun play(api: HttpStudyApi, media: List<Media>) {
        stop()
        if (media.isEmpty()) return
        try {
            val urls = media.map { api.resolveResource(it.url) }
            val p = ExoPlayer.Builder(context).build()
            player = p
            p.setAudioAttributes(AudioAttributes.Builder().setUsage(C.USAGE_MEDIA).setContentType(C.AUDIO_CONTENT_TYPE_SPEECH).build(), true)
            p.setHandleAudioBecomingNoisy(true)
            p.addListener(object : Player.Listener {
                override fun onPlaybackSuppressionReasonChanged(playbackSuppressionReason: Int) {
                    if (player === p && playbackSuppressionReason == Player.PLAYBACK_SUPPRESSION_REASON_TRANSIENT_AUDIO_FOCUS_LOSS) stop()
                }
                override fun onPlayWhenReadyChanged(playWhenReady: Boolean, reason: Int) {
                    if (player === p && !playWhenReady && reason in listOf(Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_FOCUS_LOSS, Player.PLAY_WHEN_READY_CHANGE_REASON_AUDIO_BECOMING_NOISY)) stop()
                }
                override fun onIsPlayingChanged(isPlaying: Boolean) {
                    if (player === p) mutable.value = mutable.value.copy(playing = isPlaying)
                }
                override fun onPlayerError(error: PlaybackException) {
                    if (player === p) { stop(); mutable.value = AudioState(error = "音频播放失败，可点击重新播放") }
                }
                override fun onPlaybackStateChanged(playbackState: Int) {
                    if (player === p) {
                        if(playbackState == Player.STATE_ENDED) stop()
                        else mutable.value=mutable.value.copy(loading=playbackState==Player.STATE_BUFFERING)
                    }
                }
            })
            mutable.value=AudioState(loading=true)
            p.setMediaItems(urls.map { MediaItem.fromUri(it) }); p.prepare(); p.play()
        } catch (_: Exception) { stop(); mutable.value = AudioState(error = "无法加载音频") }
    }
    fun stop() { val old = player; player = null; old?.release(); mutable.value = AudioState() }
}
