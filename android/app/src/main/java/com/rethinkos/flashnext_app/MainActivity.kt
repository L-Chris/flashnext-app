package com.rethinkos.flashnext_app

import android.os.Bundle
import android.media.AudioManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.Color
import androidx.annotation.DrawableRes
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.json.JSONArray

class MainActivity : ComponentActivity() {
    private val model: AppViewModel by viewModels()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState); enableEdgeToEdge()
        volumeControlStream = AudioManager.STREAM_MUSIC
        setContent {
            val dark = isSystemInDarkTheme()
            FlashNextTheme(dark) {
                Surface(Modifier.fillMaxSize()) { FlashNext(model, dark) }
            }
        }
    }
    override fun onStart() { super.onStart(); model.session?.foreground(true); if(model.session==null) model.updater.check(automatic=true) }
    override fun onStop() { model.session?.foreground(false); model.audio.suspendPlayback(); super.onStop() }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable fun AppIconButton(@DrawableRes icon: Int, label: String, onClick: () -> Unit, enabled: Boolean=true, modifier: Modifier=Modifier) {
    TooltipBox(positionProvider=TooltipDefaults.rememberPlainTooltipPositionProvider(),
        tooltip={ PlainTooltip { Text(label) } }, state=rememberTooltipState()) {
        IconButton(onClick=onClick, enabled=enabled, modifier=modifier) { Icon(painterResource(icon),contentDescription=label) }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable fun FlashNext(model: AppViewModel, dark: Boolean) {
    val home by model.home.collectAsStateWithLifecycle()
    var session by remember { mutableStateOf(model.session) }
    var settings by remember { mutableStateOf(false) }
    var deckSettings by remember { mutableStateOf<Deck?>(null) }
    fun leave() { model.leaveReview(); session = null }
    BackHandler(session != null) { leave() }
    Scaffold(topBar = {
        TopAppBar(title = { Row(verticalAlignment=Alignment.CenterVertically, horizontalArrangement=Arrangement.spacedBy(8.dp)) {
            if(session == null) Image(painterResource(R.drawable.brand_logo),contentDescription=null,modifier=Modifier.size(32.dp))
            Text(if(session != null) model.deck?.name ?: "复习" else "FlashNext")
        } },
            navigationIcon = { if (session != null) AppIconButton(R.drawable.ic_arrow_back,"返回",::leave) },
            actions = {
                val active=session
                if(active==null) {
                    AppIconButton(R.drawable.ic_refresh,"刷新",model::refresh,enabled=!home.loading)
                    AppIconButton(R.drawable.ic_settings,"设置",{ settings=true })
                } else {
                    val review by active.state.collectAsStateWithLifecycle()
                    AppIconButton(R.drawable.ic_undo,"撤销上一次",active::undo,enabled=review.canUndo && !review.busy,modifier=Modifier.testTag("undo"))
                }
            })
    }) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            val active = session
            if (active != null) ReviewScreen(active, model.api, model.audio, dark)
            else when {
                home.loading && home.decks.isEmpty() -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
                home.error != null && home.decks.isEmpty() -> Column(Modifier.align(Alignment.Center).padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(painterResource(R.drawable.ic_cloud_off),null,Modifier.size(48.dp),tint=MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.height(12.dp)); Text(home.error!!,textAlign=TextAlign.Center)
                    Spacer(Modifier.height(12.dp)); Button(onClick = model::refresh) { Text("重试") }; TextButton(onClick = { settings = true }) { Text("服务器设置") }
                }
                else -> PullToRefreshBox(isRefreshing=home.loading, onRefresh=model::refresh) {
                    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(12.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    home.error?.let { item { Text(it, color = MaterialTheme.colorScheme.error) } }
                    if (home.decks.isEmpty()) item { Box(Modifier.fillParentMaxSize(),contentAlignment=Alignment.Center) { Text("还没有牌组") } }
                    items(home.decks, key = { it.id }) { deck ->
                        Card(onClick = { session = model.enterReview(deck) }, modifier = Modifier.fillMaxWidth().testTag("deck-${deck.id}"),shape=RoundedCornerShape(12.dp),
                            colors=CardDefaults.cardColors(containerColor=MaterialTheme.colorScheme.surfaceContainerLow),elevation=CardDefaults.cardElevation(defaultElevation=1.dp)) {
                            Row(Modifier.fillMaxWidth().padding(start=16.dp,end=8.dp,top=8.dp,bottom=8.dp).heightIn(min=56.dp), verticalAlignment = Alignment.CenterVertically) {
                                Column(Modifier.weight(1f)) {
                                    Text(deck.name, style = MaterialTheme.typography.titleMedium)
                                    Text("待复习 ${deck.dueCount} · 日内 ${deck.intraday} · 新卡 ${deck.fresh}", color = MaterialTheme.colorScheme.onSurfaceVariant,style=MaterialTheme.typography.bodyMedium)
                                }
                                if(deck.dueCount>0) SuggestionChip(onClick={ session=model.enterReview(deck) },label={Text("${deck.dueCount}")},modifier=Modifier.padding(start=8.dp))
                                else Icon(painterResource(R.drawable.ic_check_circle_outline),"已完成",Modifier.padding(start=8.dp))
                                AppIconButton(R.drawable.ic_settings_outline,"${deck.name}的学习设置",{ deckSettings=deck },modifier=Modifier.testTag("deck-settings-${deck.id}"))
                            }
                        }
                    }
                    }
                }
            }
        }
    }
    if(settings) AppSettings(model, onDismiss = { settings = false })
    deckSettings?.let { deck -> DeckSettingsDialog(model.api, deck, onDismiss = { deckSettings = null }, onSaved = model::refresh) }
    UpdateHost(model.updater)
}

@Composable fun ReviewScreen(session: ReviewSession, api: HttpStudyApi, audio: AudioController, dark: Boolean) {
    val s by session.state.collectAsStateWithLifecycle()
    val a by audio.state.collectAsStateWithLifecycle()
    Column(Modifier.fillMaxSize().padding(16.dp)) {
        s.notice?.let { Text(it, color = MaterialTheme.colorScheme.error) }
        val card = s.card
        if (card != null) {
            val border = MaterialTheme.colorScheme.outlineVariant
            val media = card.media(s.revealed)
            Column(Modifier.weight(1f).fillMaxWidth().clip(RoundedCornerShape(16.dp)).testTag("review-card")
                .background(MaterialTheme.colorScheme.surface)
                .drawWithContent { drawContent(); val width = 1.25.dp.toPx(); drawRoundRect(border,
                    topLeft = androidx.compose.ui.geometry.Offset(width/2, width/2),
                    size = androidx.compose.ui.geometry.Size(size.width-width, size.height-width),
                    cornerRadius = androidx.compose.ui.geometry.CornerRadius(16.dp.toPx()), style = Stroke(width)) }) {
                Box(Modifier.weight(1f).fillMaxWidth()) {
                    key(s.visit) {
                        if (card.format == "markdown_math") MathFace(api, card, session, s, dark)
                        else {
                            PlainFace(card, s.revealed)
                            LaunchedEffect(s.revealed) { withFrameNanos { }; session.contentReady(s.visit, s.revealed) }
                        }
                    }
                }
                if(media.isNotEmpty()) Column(Modifier.fillMaxWidth().padding(start=16.dp,end=16.dp,bottom=12.dp),horizontalAlignment=Alignment.CenterHorizontally) {
                    IconButton(enabled = !s.busy && s.foreground && s.ready,
                        onClick = { if(a.playing || a.loading) audio.stop() else audio.play(api, media) },
                        modifier=Modifier.size(56.dp),colors=IconButtonDefaults.iconButtonColors(contentColor=MaterialTheme.colorScheme.primary)) {
                        Box(contentAlignment=Alignment.Center) {
                            if(a.loading) CircularProgressIndicator(Modifier.size(44.dp),strokeWidth=2.dp)
                            Icon(painterResource(if(a.playing || a.loading) R.drawable.ic_stop else R.drawable.ic_play_arrow),
                                if(a.loading) "停止加载音频" else if(a.playing) "停止音频" else "播放音频",Modifier.size(36.dp))
                        }
                    }
                    a.error?.let { Text(it,Modifier.fillMaxWidth(),color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall,textAlign=TextAlign.Center) }
                }
            }
            Spacer(Modifier.height(12.dp))
            if (!s.revealed) Button(session::reveal, Modifier.fillMaxWidth().heightIn(min=48.dp).testTag("reveal"), enabled = !s.busy && s.foreground) {
                Text(s.countdownSeconds?.let { "显示答案 · $it 秒" } ?: "显示答案")
            } else RatingButtons(s.canRate,session::rate)
        } else Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
            when {
                s.busy -> CircularProgressIndicator()
                s.error != null -> Column(horizontalAlignment = Alignment.CenterHorizontally) { Text(s.error!!); Button(session::load) { Text("重试") } }
                s.loaded -> Text("太棒了！当前没有需要复习的卡片",textAlign=TextAlign.Center)
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable fun RatingButtons(enabled: Boolean, rate: (Int) -> Unit) {
    FlowRow(Modifier.fillMaxWidth().testTag("rating-buttons"),horizontalArrangement=Arrangement.spacedBy(8.dp,Alignment.CenterHorizontally),verticalArrangement=Arrangement.spacedBy(8.dp)) {
        listOf("忘记" to Color(0xFFDC2626),"困难" to Color(0xFFD97706),"良好" to Color(0xFF059669),"简单" to Color(0xFF0284C7)).forEachIndexed { i,(label,color) ->
            Button(onClick={rate(i+1)},enabled=enabled,colors=ButtonDefaults.buttonColors(containerColor=color,contentColor=Color.White),
                shape=RoundedCornerShape(8.dp),
                modifier=Modifier.widthIn(min=72.dp).heightIn(min=52.dp).testTag("rating-${i+1}"),contentPadding=PaddingValues(horizontal=18.dp,vertical=10.dp)) { Text(label,maxLines=1) }
        }
    }
}

@Composable fun PlainFace(card: StudyCard, revealed: Boolean) {
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(24.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(card.front, Modifier.fillMaxWidth(), style = MaterialTheme.typography.headlineMedium, textAlign = TextAlign.Center)
        if (revealed) {
            HorizontalDivider(Modifier.padding(vertical=12.dp))
            val word = card.word
            if (!generatedBack(card) || word == null) Text(card.back, style=MaterialTheme.typography.bodyLarge)
            else {
                if (word.language == "ja") {
                    if(word.reading.isNotBlank()) Text(word.reading, Modifier.fillMaxWidth(), style = MaterialTheme.typography.titleLarge, textAlign = TextAlign.Center)
                    if(word.pos.isNotBlank()) Text(word.pos, style = MaterialTheme.typography.labelLarge)
                    Text(word.translation, style=MaterialTheme.typography.bodyLarge)
                } else {
                    val lines = normalizeDictionary(card.back).lines()
                    val initial = lines.firstOrNull()?.takeIf { it.matches(Regex("^/[^\\n]+/$")) }
                    val pronunciations = presentPronunciations(word.pronunciations, initial ?: word.phonetic)
                    if(pronunciations.groups.isEmpty()) {
                        val fallback = phonetic(initial ?: word.phonetic)
                        if(fallback.isNotBlank()) Text(fallback, style=MaterialTheme.typography.titleMedium)
                    } else pronunciations.groups.forEach { group ->
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(listOf(group.accentLabel, group.ipas.joinToString(" 或 ")).filter { it.isNotEmpty() }.joinToString(" "), style=MaterialTheme.typography.titleMedium)
                            if(pronunciations.showLabels && group.labels.isNotEmpty()) Text(group.labels.joinToString("；"), style=MaterialTheme.typography.bodyMedium)
                        }
                    }
                    if(!notesCoverMeanings(normalizeDictionary(word.translation), word.pronunciations)) Text(normalizeDictionary(word.translation), style=MaterialTheme.typography.bodyLarge)
                }
                word.senses.forEach { sense ->
                    val details = runCatching { JSONArray(sense.details).objects().take(2) }.getOrDefault(emptyList())
                    val examples = if(details.isNotEmpty()) details.map { listOf(it.text("ja"), it.text("zh", it.text("en"))).filter { s -> s.isNotEmpty() }.joinToString("\n") }
                        else jsonList(sense.examples).take(2)
                    examples.forEach { Text(it, Modifier.padding(top=8.dp)) }
                    val translations = jsonList(sense.zh)
                    if(examples.isNotEmpty() && translations.isNotEmpty()) Text("译词：${translations.joinToString("、")}", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}
