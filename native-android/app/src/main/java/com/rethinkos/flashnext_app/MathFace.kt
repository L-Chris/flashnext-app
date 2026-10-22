package com.rethinkos.flashnext_app

import android.annotation.SuppressLint
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.webkit.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import java.util.UUID
import kotlinx.coroutines.*
import org.json.JSONObject

private fun htmlAttribute(s: String) = s.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace("'", "&#39;")
fun mathDocument(api: HttpStudyApi, preview: Preview, dark: Boolean, font: Float, nonce: String, back: Boolean): String {
    val css = api.resolveResource(preview.css); val origin = htmlAttribute(api.baseUrl)
    return """<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline' $origin; font-src $origin; script-src 'nonce-$nonce'; base-uri 'none'; form-action 'none'">
<link rel="stylesheet" href="${htmlAttribute(css)}"><style>
html{color-scheme:${if(dark) "dark" else "light"};font-size:${font}px}body{margin:0;padding:24px;background:${if(dark) "#1c1b20" else "#fff"};color:${if(dark) "#eee" else "#202027"};font-family:system-ui,sans-serif;line-height:1.6;overflow-wrap:anywhere}
*,*:before,*:after{box-sizing:border-box}h1,h2,h3{font-size:1.4em}hr{margin:24px 0;opacity:.25}.katex-display,pre{overflow-x:auto;overflow-y:hidden;max-width:100%;padding:8px 0}table{display:block;max-width:100%;overflow:auto}a{color:inherit}code{white-space:pre-wrap}[hidden]{display:none!important}
</style></head><body><section>${preview.front}</section><section id="answer" ${if(back) "" else "hidden"}><hr>${preview.back}</section>
<script nonce="$nonce">
let revision=0;window.studySide=async function(back){const rev=++revision;document.getElementById('answer').hidden=!back;
try{await new Promise(requestAnimationFrame);await document.fonts.ready;
if(Array.from(document.fonts).some(f=>f.status==='error'))throw Error('font');
await new Promise(requestAnimationFrame);await new Promise(requestAnimationFrame);
if(rev===revision)StudyReady.ready(${JSONObject.quote(nonce)},back,true);
}catch(_){if(rev===revision)StudyReady.ready(${JSONObject.quote(nonce)},back,false);}};
window.addEventListener('load',()=>window.studySide($back),{once:true});
</script></body></html>"""
}
class ReadyBridge(private val callback: (String, Boolean, Boolean) -> Unit) {
    @JavascriptInterface fun ready(nonce: String, back: Boolean, success: Boolean) = callback(nonce, back, success)
}

@SuppressLint("SetJavaScriptEnabled")
@Composable fun MathFace(api: HttpStudyApi, card: StudyCard, session: ReviewSession, state: ReviewState, dark: Boolean) {
    var preview by remember { mutableStateOf<Preview?>(null) }
    var error by remember { mutableStateOf<String?>(null) }
    var retry by remember { mutableIntStateOf(0) }
    var loaded by remember { mutableStateOf(false) }
    var web by remember { mutableStateOf<WebView?>(null) }
    val font = 18f * LocalDensity.current.fontScale
    val nonce = remember(retry, dark, font) { UUID.randomUUID().toString() }
    val currentBack by rememberUpdatedState(state.revealed)
    val main = remember { Handler(Looper.getMainLooper()) }
    fun fail(message: String) { if (error == null) { error = message; loaded = false; session.contentUnavailable(state.visit) } }
    LaunchedEffect(retry) {
        error = null; preview = null; session.contentUnavailable(state.visit)
        try { val p = api.preview(card); check(p.valid) { "公式内容无法渲染" }; api.resolveResource(p.css); preview = p }
        catch(e: CancellationException) { throw e } catch(e: Exception) { fail(e.userMessage()) }
    }
    LaunchedEffect(error, state.revealed) {
        if (error != null) { withFrameNanos { }; session.contentReady(state.visit, state.revealed, false) }
    }
    LaunchedEffect(nonce, preview, state.revealed, error) {
        if (error == null && preview != null) {
            loaded = false; session.contentUnavailable(state.visit)
            web?.evaluateJavascript("window.studySide && window.studySide(${state.revealed});", null)
            delay(20_000)
            if (!loaded) fail("公式字体或样式加载超时")
        }
    }
    Column(Modifier.fillMaxSize()) {
        if (error != null) {
            Text("$error，已显示原文。", Modifier.padding(12.dp), color = MaterialTheme.colorScheme.error)
            TextButton(onClick = { retry++ }) { Text("重试公式渲染") }
            Box(Modifier.weight(1f)) { PlainFace(card, state.revealed) }
        } else if (preview != null) {
            val p = preview!!
            key(nonce) {
                Box(Modifier.weight(1f)) {
                    AndroidView(modifier = Modifier.fillMaxSize(), factory = { context ->
                        WebView(context).apply {
                            web = this
                            setBackgroundColor(if (dark) Color.rgb(28,27,32) else Color.WHITE)
                            settings.javaScriptEnabled = true
                            settings.allowFileAccess = false; settings.allowContentAccess = false
                            settings.domStorageEnabled = false; settings.setSupportMultipleWindows(false)
                            settings.mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
                            addJavascriptInterface(ReadyBridge { received, side, success -> main.post {
                                if (web === this && received == nonce && side == currentBack && error == null) {
                                    if (success) { loaded = true; session.contentReady(state.visit, side) }
                                    else fail("公式字体加载失败")
                                }
                            } }, "StudyReady")
                            webViewClient = object : WebViewClient() {
                                override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest) = true
                                override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? {
                                    if (!sameOrigin(api.baseUrl, request.url.toString())) return WebResourceResponse("text/plain", "utf-8", "".byteInputStream())
                                    return null
                                }
                                override fun onReceivedError(view: WebView, request: WebResourceRequest, e: WebResourceError) { main.post { if (web === view) fail("公式资源加载失败") } }
                                override fun onReceivedHttpError(view: WebView, request: WebResourceRequest, response: WebResourceResponse) { main.post { if (web === view) fail("公式资源加载失败 (${response.statusCode})") } }
                                override fun onPageFinished(view: WebView, url: String) { view.evaluateJavascript("window.studySide && window.studySide($currentBack)", null) }
                            }
                            loadDataWithBaseURL(api.baseUrl + "/", mathDocument(api, p, dark, font, nonce, currentBack), "text/html", "utf-8", null)
                        }
                    })
                    if (!loaded) Surface(Modifier.fillMaxSize()) { Box(contentAlignment = androidx.compose.ui.Alignment.Center) { CircularProgressIndicator() } }
                }
            }
        } else Box(Modifier.weight(1f).fillMaxWidth(), contentAlignment = androidx.compose.ui.Alignment.Center) { CircularProgressIndicator() }
    }
    DisposableEffect(nonce) { onDispose { val old = web; web = null; old?.stopLoading(); old?.removeJavascriptInterface("StudyReady"); old?.destroy() } }
}
