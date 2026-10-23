package com.rethinkos.flashnext_app

import android.content.Context
import android.net.Uri
import androidx.media3.common.util.UnstableApi
import androidx.media3.common.C
import androidx.media3.database.StandaloneDatabaseProvider
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DataSpec
import androidx.media3.datasource.cache.CacheDataSource
import androidx.media3.datasource.cache.CacheWriter
import androidx.media3.datasource.cache.ContentMetadata
import androidx.media3.datasource.cache.ContentMetadataMutations
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.datasource.cache.SimpleCache
import androidx.media3.datasource.okhttp.OkHttpDataSource
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import okhttp3.Call
import okhttp3.OkHttpClient
import okhttp3.Request

/** One store per application process/directory. Player lifetimes never own the disk cache. */
@androidx.annotation.OptIn(UnstableApi::class)
class AudioStore(context: Context,
    private val directory: File=File(context.cacheDir,"study-audio-v1"),
    private val capacity: Long=AUDIO_CACHE_BYTES) {
    private val app=context.applicationContext
    private val mutex=Mutex()
    private var initialized=false
    private var disk: SimpleCache?=null
    private var database: StandaloneDatabaseProvider?=null
    private val client=OkHttpClient.Builder().connectTimeout(8,TimeUnit.SECONDS).readTimeout(15,TimeUnit.SECONDS)
        .callTimeout(30,TimeUnit.SECONDS).followRedirects(false).retryOnConnectionFailure(true).build()

    suspend fun cache(): SimpleCache? = withContext(Dispatchers.IO) {
        mutex.withLock {
            if(!initialized) {
                initialized=true
                var candidate: SimpleCache?=null
                try {
                    val provider=StandaloneDatabaseProvider(app).also { database=it }
                    candidate=SimpleCache(directory,LeastRecentlyUsedCacheEvictor(capacity),provider)
                    candidate.checkInitialization(); disk=candidate
                } catch(e: Exception) { runCatching { candidate?.release() }; runCatching { database?.close() }; database=null }
            }
            disk
        }
    }
    fun upstream(calls: Call.Factory=client): DataSource.Factory = OkHttpDataSource.Factory(calls).setUserAgent("FlashNext-Audio")
    fun cached(cache: SimpleCache, calls: Call.Factory=client): CacheDataSource.Factory = CacheDataSource.Factory()
        .setCache(cache).setUpstreamDataSourceFactory(upstream(calls)).setFlags(CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR)
    suspend fun factory(bypass: Boolean=false, tracks: List<AudioTrack> = emptyList()): DataSource.Factory {
        if(bypass) return upstream()
        val available=cache() ?: return upstream()
        return try {
            withContext(Dispatchers.IO) { tracks.forEach { rememberLength(available,it) } }
            cached(available)
        } catch(e: CancellationException) { throw e }
        catch(_: Exception) { upstream() }
    }
    suspend fun evict(key: String) = withContext(Dispatchers.IO) { runCatching { cache()?.removeResource(key) }; Unit }

    fun transfer(cache: SimpleCache, track: AudioTrack): AudioTransfer {
        val calls=AudioCalls(client)
        val spec=DataSpec.Builder().setUri(Uri.parse(track.url)).setKey(track.key).setLength(track.bytes).build()
        return AudioTransfer(CacheWriter(cached(cache,calls).createDataSource(),spec,null,null),calls) {
            // A bounded CacheWriter request need not record EOF. Preserve the known complete length,
            // so extractors probing the end do not issue an unnecessary network request.
            rememberLength(cache,track)
        }
    }
    private fun rememberLength(cache: SimpleCache, track: AudioTrack) {
        if(track.bytes>0 && cache.isCached(track.key,0,track.bytes) && ContentMetadata.getContentLength(cache.getContentMetadata(track.key))==C.LENGTH_UNSET.toLong()) {
            val changes=ContentMetadataMutations()
            ContentMetadataMutations.setContentLength(changes,track.bytes)
            cache.applyContentMetadataMutations(track.key,changes)
        }
    }

    /** Only isolated test stores are closed; production shares the cache until process termination. */
    internal suspend fun close(delete: Boolean=false) = withContext(Dispatchers.IO) {
        mutex.withLock {
            disk?.release(); disk=null; initialized=true
            if(delete) SimpleCache.delete(directory,database)
            database?.close(); database=null
        }
        client.dispatcher.cancelAll(); client.connectionPool.evictAll()
    }
}

internal class AudioCalls(private val client: OkHttpClient): Call.Factory {
    private val canceled=AtomicBoolean(false)
    private val calls=ConcurrentHashMap.newKeySet<Call>()
    override fun newCall(request: Request): Call = client.newCall(request).also {
        calls.add(it); if(canceled.get()) it.cancel()
    }
    fun cancel() { canceled.set(true); calls.forEach { it.cancel() }; calls.clear() }
}

@androidx.annotation.OptIn(UnstableApi::class)
class AudioTransfer internal constructor(private val writer: CacheWriter, private val calls: AudioCalls, private val completed: ()->Unit) {
    fun run() { try { writer.cache(); completed() } finally { calls.cancel() } }
    fun cancel() { writer.cancel(); calls.cancel() }
}

@androidx.annotation.OptIn(UnstableApi::class)
object AudioStores {
    private var shared: AudioStore?=null
    @Synchronized fun get(context: Context): AudioStore = shared ?: AudioStore(context.applicationContext).also { shared=it }
}
