package com.rethinkos.flashnext_app

import android.os.Bundle
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
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.json.JSONArray

class MainActivity : ComponentActivity() {
    private val model: AppViewModel by viewModels()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState); enableEdgeToEdge()
        setContent {
            val dark = isSystemInDarkTheme()
            MaterialTheme(colorScheme = if(dark) darkColorScheme() else lightColorScheme()) {
                Surface(Modifier.fillMaxSize()) { FlashNext(model, dark) }
            }
        }
    }
    override fun onStart() { super.onStart(); model.session?.foreground(true) }
    override fun onStop() { model.session?.foreground(false); model.audio.stop(); super.onStop() }
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
            navigationIcon = { if (session != null) TextButton(onClick = { leave() }) { Text("返回") } },
            actions = { if (session == null) { TextButton(onClick = model::refresh, enabled = !home.loading) { Text("刷新") }; TextButton(onClick = { settings = true }) { Text("设置") } } })
    }) { padding ->
        Box(Modifier.padding(padding).fillMaxSize()) {
            val active = session
            if (active != null) ReviewScreen(active, model.api, model.audio, dark)
            else when {
                home.loading && home.decks.isEmpty() -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
                home.error != null && home.decks.isEmpty() -> Column(Modifier.align(Alignment.Center).padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(home.error!!); Button(onClick = model::refresh) { Text("重试") }; TextButton(onClick = { settings = true }) { Text("服务器设置") }
                }
                else -> PullToRefreshBox(isRefreshing=home.loading, onRefresh=model::refresh) {
                    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    home.error?.let { item { Text(it, color = MaterialTheme.colorScheme.error) } }
                    if (home.decks.isEmpty()) item { Text("暂无牌组") }
                    items(home.decks, key = { it.id }) { deck ->
                        OutlinedCard(onClick = { session = model.enterReview(deck) }, modifier = Modifier.fillMaxWidth().testTag("deck-${deck.id}")) {
                            Row(Modifier.padding(20.dp), verticalAlignment = Alignment.CenterVertically) {
                                Column(Modifier.weight(1f)) {
                                    Text(deck.name, style = MaterialTheme.typography.titleLarge)
                                    if (deck.description.isNotBlank()) Text(deck.description, style = MaterialTheme.typography.bodyMedium)
                                    Text("待复习 ${deck.dueCount} · 日内 ${deck.intraday} · 新卡 ${deck.fresh}", color = MaterialTheme.colorScheme.primary, modifier = Modifier.padding(top = 8.dp))
                                }
                                TextButton(onClick = { deckSettings = deck }) { Text("牌组设置") }
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
}

@Composable fun ReviewScreen(session: ReviewSession, api: HttpStudyApi, audio: AudioController, dark: Boolean) {
    val s by session.state.collectAsStateWithLifecycle()
    val a by audio.state.collectAsStateWithLifecycle()
    Column(Modifier.fillMaxSize().padding(horizontal = 16.dp, vertical = 8.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) { TextButton(onClick = session::undo, enabled = s.canUndo && !s.busy) { Text("撤销") } }
        s.notice?.let { Text(it, color = MaterialTheme.colorScheme.error) }
        val card = s.card
        if (card != null) {
            val border = MaterialTheme.colorScheme.outline
            Box(Modifier.weight(1f).fillMaxWidth().clip(RoundedCornerShape(20.dp))
                .background(MaterialTheme.colorScheme.surface)
                .drawWithContent { drawContent(); val width = 1.dp.toPx(); drawRoundRect(border,
                    topLeft = androidx.compose.ui.geometry.Offset(width/2, width/2),
                    size = androidx.compose.ui.geometry.Size(size.width-width, size.height-width),
                    cornerRadius = androidx.compose.ui.geometry.CornerRadius(20.dp.toPx()), style = Stroke(width)) }) {
                key(s.visit) {
                    if (card.format == "markdown_math") MathFace(api, card, session, s, dark)
                    else {
                        PlainFace(card, s.revealed)
                        LaunchedEffect(s.revealed) { withFrameNanos { }; session.contentReady(s.visit, s.revealed) }
                    }
                }
            }
            val media = card.media(s.revealed)
            if(media.isNotEmpty()) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    OutlinedButton(enabled = !s.busy && s.foreground, onClick = { if(a.playing) audio.stop() else audio.play(api, media) }) { Text(if(a.playing) "停止音频" else "播放音频") }
                    a.error?.let { Text(it, Modifier.padding(start=8.dp), color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall) }
                }
            }
            if (!s.revealed) Button(session::reveal, Modifier.fillMaxWidth().testTag("reveal"), enabled = !s.busy && s.foreground) { Text("显示答案") }
            else Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                listOf("重来", "困难", "良好", "简单").forEachIndexed { i, label ->
                    FilledTonalButton(onClick = { session.rate(i+1) }, enabled = s.canRate, modifier = Modifier.weight(1f).testTag("rating-${i+1}"), contentPadding = PaddingValues(horizontal=4.dp, vertical=12.dp)) { Text(label) }
                }
            }
        } else Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
            when {
                s.busy -> CircularProgressIndicator()
                s.error != null -> Column(horizontalAlignment = Alignment.CenterHorizontally) { Text(s.error!!); Button(session::load) { Text("重试") } }
                s.loaded -> Text("本次学习完成", style = MaterialTheme.typography.headlineSmall)
            }
        }
    }
}

@Composable fun PlainFace(card: StudyCard, revealed: Boolean) {
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(24.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text(card.front, Modifier.fillMaxWidth(), style = MaterialTheme.typography.headlineMedium, textAlign = TextAlign.Center)
        if (revealed) {
            HorizontalDivider(Modifier.padding(vertical=12.dp))
            val word = card.word
            if (!generatedBack(card) || word == null) Text(card.back, fontSize = 18.sp)
            else {
                if (word.language == "ja") {
                    if(word.reading.isNotBlank()) Text(word.reading, Modifier.fillMaxWidth(), style = MaterialTheme.typography.titleLarge, textAlign = TextAlign.Center)
                    if(word.pos.isNotBlank()) Text(word.pos, style = MaterialTheme.typography.labelLarge)
                    Text(word.translation, fontSize=18.sp)
                } else {
                    val lines = normalizeDictionary(card.back).lines()
                    val initial = lines.firstOrNull()?.takeIf { it.matches(Regex("^/[^\\n]+/$")) }
                    val pronunciations = presentPronunciations(word.pronunciations, initial ?: word.phonetic)
                    if(pronunciations.groups.isEmpty()) {
                        val fallback = phonetic(initial ?: word.phonetic)
                        if(fallback.isNotBlank()) Text(fallback, fontSize=20.sp)
                    } else pronunciations.groups.forEach { group ->
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(listOf(group.accentLabel, group.ipas.joinToString(" 或 ")).filter { it.isNotEmpty() }.joinToString(" "), fontSize=20.sp)
                            if(pronunciations.showLabels && group.labels.isNotEmpty()) Text(group.labels.joinToString("；"), color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                    if(!notesCoverMeanings(normalizeDictionary(word.translation), word.pronunciations)) Text(normalizeDictionary(word.translation), fontSize=18.sp)
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
