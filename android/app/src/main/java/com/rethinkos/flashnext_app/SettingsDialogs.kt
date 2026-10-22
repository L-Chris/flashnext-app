package com.rethinkos.flashnext_app

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LocalLifecycleOwner
import kotlinx.coroutines.*
import org.json.JSONObject
import java.time.ZoneId

@Composable fun SettingsPanel(title: String, onDismiss: () -> Unit, content: @Composable ColumnScope.() -> Unit) {
    Dialog(onDismissRequest = onDismiss, properties = DialogProperties(usePlatformDefaultWidth = false)) {
        Surface(Modifier.widthIn(max=560.dp).fillMaxWidth(.94f).heightIn(max=760.dp), shape = MaterialTheme.shapes.extraLarge) {
            Column(Modifier.verticalScroll(rememberScrollState()).padding(24.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(title, style=MaterialTheme.typography.headlineSmall)
                content()
            }
        }
    }
}
@Composable fun DiscardDialog(onDiscard: () -> Unit, onKeep: () -> Unit) {
    AlertDialog(onDismissRequest = onKeep, title = { Text("放弃未保存的修改？") },
        confirmButton = { TextButton(onClick=onDiscard) { Text("放弃修改") } }, dismissButton = { TextButton(onClick=onKeep) { Text("继续编辑") } })
}
@Composable fun AppSettings(model: AppViewModel, onDismiss: () -> Unit) {
    val api = model.api; val scope = rememberCoroutineScope()
    var server by remember { mutableStateOf(api.baseUrl) }
    var savedZone by remember { mutableStateOf<String?>(null) }; var zone by remember { mutableStateOf("") }
    var busy by remember { mutableStateOf(false) }; var error by remember { mutableStateOf<String?>(null) }
    var message by remember { mutableStateOf<String?>(null) }; var discard by remember { mutableStateOf(false) }
    val dirty=server!=api.baseUrl || savedZone!=null && zone!=savedZone
    fun dismiss() { if(busy) return; if(server != api.baseUrl || savedZone != null && zone != savedZone) discard = true else onDismiss() }
    suspend fun loadZone() { error=null; try { val v = api.timezone(); savedZone = v; zone = v } catch(e: CancellationException) { throw e } catch(e: Exception) { error = e.userMessage() } }
    LaunchedEffect(api) { loadZone() }
    SettingsPanel("设置", ::dismiss) {
        OutlinedTextField(server, { server=it }, label = { Text("服务器地址") }, enabled = !busy, singleLine=true, modifier=Modifier.fillMaxWidth())
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            OutlinedButton(enabled = !busy, onClick = { scope.launch { busy = true; error = null; message = null
                try { val test = HttpStudyApi(normalizeServer(server)); try { test.decks(); message = "连接成功" } finally { test.close() } }
                catch(e: CancellationException) { throw e } catch(e: Exception) { error = e.userMessage() }; busy = false
            } }) { Text("测试连接") }
        }
        OutlinedTextField(zone, { zone=it }, label={Text("时区")}, placeholder={Text("Asia/Shanghai")}, enabled = !busy && savedZone!=null, singleLine=true, modifier=Modifier.fillMaxWidth())
        if(savedZone==null) TextButton(enabled = !busy, onClick = { scope.launch { loadZone() } }) { Text("重新加载时区") }
        Button(enabled = !busy && dirty, onClick = { scope.launch {
                busy = true; error = null; message = null
                try {
                    val address=normalizeServer(server)
                    if(savedZone!=null && zone!=savedZone) {
                        val timezone=zone.trim(); ZoneId.of(timezone)
                        val destination=if(address==api.baseUrl) api else HttpStudyApi(address)
                        try { val saved=destination.saveTimezone(timezone); savedZone=saved; zone=saved }
                        finally { if(destination!==api) destination.close() }
                    }
                    if(address!=api.baseUrl) model.server(address) else model.refresh()
                    onDismiss()
                }
                catch(e: CancellationException) { throw e } catch(e: Exception) { error = e.userMessage() }; busy = false
            } }) { Text(if(busy) "保存中…" else "保存") }
        HorizontalDivider()
        UpdateSettings(model.updater)
        error?.let { Text(it, color = MaterialTheme.colorScheme.error) }; message?.let { Text(it) }
        TextButton(onClick = ::dismiss, enabled = !busy) { Text("关闭") }
    }
    if(discard) DiscardDialog(onDiscard=onDismiss, onKeep={discard=false})
}

@Composable fun NumericField(value: String, onChange: (String) -> Unit, label: String, enabled: Boolean) {
    OutlinedTextField(value, onChange, label={Text(label)}, enabled=enabled, singleLine=true,
        keyboardOptions=KeyboardOptions(keyboardType=KeyboardType.Number), modifier=Modifier.fillMaxWidth())
}
@Composable fun Toggle(label: String, value: Boolean, enabled: Boolean, change: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement=Arrangement.SpaceBetween, verticalAlignment=androidx.compose.ui.Alignment.CenterVertically) {
        Text(label, Modifier.weight(1f)); Switch(value, change, enabled=enabled)
    }
}
@Composable fun DeckSettingsDialog(api: HttpStudyApi, deck: Deck, onDismiss: () -> Unit, onSaved: () -> Unit) {
    val scope = rememberCoroutineScope()
    var saved by remember { mutableStateOf<DeckSettings?>(null) }
    var fresh by remember { mutableStateOf("") }; var review by remember { mutableStateOf("") }; var rollover by remember { mutableStateOf("") }
    var autoplay by remember { mutableStateOf(false) }; var immediate by remember { mutableStateOf(false) }
    var delay by remember { mutableStateOf("") }; var automatic by remember { mutableStateOf(false) }
    var busy by remember { mutableStateOf(true) }; var error by remember { mutableStateOf<String?>(null) }; var discard by remember { mutableStateOf(false) }
    var saving by remember { mutableStateOf(false) }
    fun apply(s: DeckSettings) { saved=s; fresh=s.newPerDay.toString(); review=s.reviewPerDay.toString(); rollover=s.rolloverHour.toString(); autoplay=s.autoplay; immediate=s.immediate; automatic=s.revealSeconds!=null; delay=s.revealSeconds?.toString().orEmpty() }
    fun dirty(): Boolean = saved?.let { fresh != it.newPerDay.toString() || review != it.reviewPerDay.toString() || rollover != it.rolloverHour.toString() || autoplay != it.autoplay || immediate != it.immediate || automatic != (it.revealSeconds!=null) || automatic && delay != it.revealSeconds?.toString() } ?: false
    fun dismiss() { if(saving) return; if(dirty()) discard=true else onDismiss() }
    suspend fun load() { busy=true; error=null
        try { apply(api.settings(deck.id)) } catch(e: CancellationException) { throw e } catch(e: Exception) { error=e.userMessage() }; busy=false
    }
    LaunchedEffect(deck.id) { load() }
    SettingsPanel(deck.name, ::dismiss) {
        if(saved != null) {
            NumericField(fresh, {fresh=it}, "每日新卡", !busy)
            NumericField(review, {review=it}, "每日复习", !busy)
            NumericField(rollover, {rollover=it}, "日切时间（0–23 时）", !busy)
            Toggle("自动播放音频", autoplay, !busy) { autoplay=it }
            Toggle("新卡直接显示答案", immediate, !busy) { immediate=it }
            Toggle("定时显示答案", automatic, !busy) { automatic=it }
            if(automatic) NumericField(delay, {delay=it}, "显示答案延迟（1–3600 秒）", !busy)
            Button(enabled = !busy && dirty(), onClick = { scope.launch {
                busy=true; saving=true; error=null
                try {
                    fun number(s: String, range: IntRange, label: String): Int { val n=s.toIntOrNull(); require(n!=null && n in range) { "$label 超出范围" }; return n }
                    val draft = DeckSettings(number(fresh,0..100000,"每日新卡"),number(review,0..100000,"每日复习"),number(rollover,0..23,"日切时间"),autoplay,immediate,if(automatic) number(delay,1..3600,"显示答案延迟") else null)
                    apply(api.saveSettings(deck.id, draft.changesFrom(saved!!))); onSaved()
                } catch(e: CancellationException) { throw e } catch(e: Exception) { error=e.userMessage() }; busy=false; saving=false
            } }) { Text(if(busy) "保存中…" else "保存") }
            FsrsPanel(api, deck.id)
        } else if(busy) CircularProgressIndicator() else TextButton(onClick={scope.launch { load() }}) { Text("重新加载") }
        error?.let { Text(it, color=MaterialTheme.colorScheme.error) }
        TextButton(onClick=::dismiss, enabled=!saving) { Text("关闭") }
    }
    if(discard) DiscardDialog(onDiscard=onDismiss, onKeep={discard=false})
}

@Composable fun FsrsPanel(api: HttpStudyApi, deck: Int) {
    val scope=rememberCoroutineScope()
    val lifecycle by LocalLifecycleOwner.current.lifecycle.currentStateFlow.collectAsState()
    var params by remember { mutableStateOf<JSONObject?>(null) }; var job by remember { mutableStateOf<JSONObject?>(null) }
    var busy by remember { mutableStateOf(false) }; var error by remember { mutableStateOf<String?>(null) }; var expanded by remember { mutableStateOf(false) }
    suspend fun refresh(start: Boolean=false) {
        if(busy) return
        busy=true; error=null
        try {
            if(start) api.request("/decks/$deck/fsrs/optimize", JSONObject())
            params=api.request("/decks/$deck/fsrs/params") as JSONObject
            job=api.request("/decks/$deck/fsrs/optimize") as JSONObject
        } catch(e: CancellationException) { throw e } catch(e: Exception) { error=e.userMessage() }
        finally { busy=false }
    }
    LaunchedEffect(lifecycle) {
        if(lifecycle.isAtLeast(Lifecycle.State.RESUMED)) {
            refresh()
        }
    }
    // Starting a job also starts polling without depending on another lifecycle event.
    LaunchedEffect(job?.optBoolean("running"), lifecycle) {
        while(job?.optBoolean("running")==true && lifecycle.isAtLeast(Lifecycle.State.RESUMED) && error==null) { delay(2000); refresh() }
    }
    HorizontalDivider()
    Text("FSRS 参数与训练", style=MaterialTheme.typography.titleMedium)
    params?.let { p ->
        Text("参数来源：${p.text("source", "default")}")
        Text("更新时间：${p.text("updatedAt", "尚未训练")}")
        Text("本牌组复习日志：${p.optInt("reviewCount")} / ${p.optInt("minReviews",1000)}")
        TextButton(onClick={expanded=!expanded}) { Text(if(expanded) "收起参数" else "查看参数") }
        if(expanded) Text(p.optJSONArray("w")?.toString().orEmpty(), style=MaterialTheme.typography.bodySmall)
    }
    (error ?: job?.text("error")?.takeIf { it.isNotEmpty() })?.let { Text(it, color=MaterialTheme.colorScheme.error) }
    Row(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
        OutlinedButton(enabled=!busy, onClick={scope.launch { refresh() }}) { Text("刷新状态") }
        Button(enabled=!busy && params!=null && job?.optBoolean("running")!=true && params!!.optInt("reviewCount")>=params!!.optInt("minReviews",1000), onClick={scope.launch { refresh(true) }}) { Text(if(job?.optBoolean("running")==true) "训练中…" else "训练参数") }
    }
}
