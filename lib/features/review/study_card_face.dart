import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/network/api_client.dart';
import '../../models/due_queue.dart';
import '../../models/study.dart';
import 'plain_card_face.dart';

String mathDocument({
  required String server,
  required ContentPreview preview,
  required bool revealed,
  required bool dark,
  required double fontSize,
  required String nonce,
}) {
  const escape = HtmlEscape(HtmlEscapeMode.attribute);
  final base = Uri.parse(server);
  final css = base.resolve(preview.renderer.cssUrl);
  if (css.origin != base.origin ||
      !['https', 'http'].contains(css.scheme) ||
      css.userInfo.isNotEmpty) {
    throw const FormatException('公式样式地址不属于当前服务器');
  }
  final origin = escape.convert(base.origin);
  return '''<!doctype html><html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline' $origin; font-src $origin; script-src 'nonce-${escape.convert(nonce)}'; base-uri 'none'; form-action 'none'">
<link rel="stylesheet" href="${escape.convert(css.toString())}">
<style>html{color-scheme:${dark ? 'dark' : 'light'};font-size:${fontSize}px}
body{margin:0;padding:20px;box-sizing:border-box;background:${dark ? '#15121c' : '#fff'};color:${dark ? '#eee' : '#202027'};font-family:system-ui,sans-serif;line-height:1.6;overflow-wrap:anywhere}
*,*:before,*:after{box-sizing:border-box} h1,h2,h3{font-size:1.4em} hr{margin:24px 0;opacity:.25}
.katex-display,pre{overflow-x:auto;overflow-y:hidden;max-width:100%;padding:8px 0} table{display:block;max-width:100%;overflow:auto} a{color:inherit} code{white-space:pre-wrap}
</style></head><body>${preview.front.html}${revealed ? '<hr>${preview.back.html}' : ''}
<script nonce="${escape.convert(nonce)}">
window.addEventListener('load', async () => {
  try {
    await document.fonts.ready;
    if (Array.from(document.fonts).some(font => font.status === 'error')) throw new Error('font');
    await new Promise(requestAnimationFrame);
    await new Promise(requestAnimationFrame);
    StudyReady.postMessage(${jsonEncode(nonce)});
  } catch (_) { StudyReady.postMessage(${jsonEncode('$nonce:error')}); }
}, {once: true});
</script></body></html>''';
}

class StudyCardFace extends StatefulWidget {
  const StudyCardFace({
    required this.api,
    required this.card,
    required this.visit,
    required this.revealed,
    required this.onReady,
    required this.onUnavailable,
    super.key,
  });
  final ApiClient api;
  final Card card;
  final String visit;
  final bool revealed;
  final void Function(String visit, bool back, {bool automaticAllowed}) onReady;
  final void Function(String visit) onUnavailable;
  @override
  State<StudyCardFace> createState() => _StudyCardFaceState();
}

class _StudyCardFaceState extends State<StudyCardFace> {
  WebViewController? _web;
  CancelToken? _request;
  Timer? _renderTimeout;
  bool _loading = true;
  String? _error;
  int _revision = 0;
  (Brightness, double)? _style;

  bool _current(int revision) => mounted && revision == _revision;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final style = (
      Theme.of(context).brightness,
      MediaQuery.textScalerOf(context).scale(18),
    );
    if (_style != style) {
      _style = style;
      if (_error == null) _schedule();
    }
  }

  @override
  void didUpdateWidget(StudyCardFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visit == widget.visit &&
        oldWidget.revealed != widget.revealed &&
        _error != null) {
      final revision = ++_revision;
      _request?.cancel();
      _renderTimeout?.cancel();
      // A failed renderer must never delay a manual answer with another request.
      _ready(revision, automaticAllowed: false);
      return;
    }
    if (oldWidget.visit != widget.visit ||
        oldWidget.revealed != widget.revealed ||
        oldWidget.card.front != widget.card.front ||
        oldWidget.card.back != widget.card.back) {
      _schedule();
    }
  }

  void _schedule() {
    final revision = ++_revision;
    _request?.cancel();
    _renderTimeout?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_current(revision)) unawaited(_prepare(revision));
    });
  }

  void _ready(int revision, {bool automaticAllowed = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_current(revision)) {
        widget.onReady(
          widget.visit,
          widget.revealed,
          automaticAllowed: automaticAllowed,
        );
      }
    });
  }

  void _fail(int revision, String message) {
    if (!_current(revision)) return;
    _renderTimeout?.cancel();
    setState(() {
      _error = message;
      _loading = false;
      _web = null;
    });
    widget.onUnavailable(widget.visit);
    _ready(revision, automaticAllowed: false);
  }

  Future<void> _prepare(int revision) async {
    if (widget.card.contentFormat != 'markdown_math') {
      setState(() => _loading = false);
      _ready(revision);
      return;
    }
    widget.onUnavailable(widget.visit);
    setState(() {
      _loading = true;
      _error = null;
      _web = null;
    });
    _request = CancelToken();
    try {
      final preview = await widget.api.preview(
        widget.card,
        cancelToken: _request,
      );
      if (!_current(revision)) return;
      if (!preview.valid ||
          preview.front.errors.isNotEmpty ||
          preview.back.errors.isNotEmpty) {
        final diagnostics = [...preview.front.errors, ...preview.back.errors];
        _fail(
          revision,
          diagnostics.isEmpty
              ? '公式渲染失败'
              : '第 ${diagnostics.first.line} 行第 ${diagnostics.first.column} 列：${diagnostics.first.message}',
        );
        return;
      }
      final style = _style!;
      final random = Random.secure();
      final nonce = base64Url.encode(
        List.generate(24, (_) => random.nextInt(256)),
      );
      final html = mathDocument(
        server: widget.api.baseUrl,
        preview: preview,
        revealed: widget.revealed,
        dark: style.$1 == Brightness.dark,
        fontSize: style.$2,
        nonce: nonce,
      );
      final web = WebViewController();
      // CSP permits only our nonce-protected readiness script, never card scripts.
      await web.setJavaScriptMode(JavaScriptMode.unrestricted);
      await web.addJavaScriptChannel(
        'StudyReady',
        onMessageReceived: (message) {
          if (!_current(revision) || _web != web || _error != null) return;
          if (message.message == '$nonce:error') {
            _fail(revision, '公式字体加载失败，请重试');
          } else if (message.message == nonce) {
            _renderTimeout?.cancel();
            setState(() => _loading = false);
            _ready(revision);
          }
        },
      );
      await web.setBackgroundColor(
        style.$1 == Brightness.dark ? const Color(0xFF15121C) : Colors.white,
      );
      await web.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => NavigationDecision.prevent,
          onHttpError: (_) => _fail(revision, '公式字体或样式加载失败'),
          onWebResourceError: (_) => _fail(revision, '公式资源加载失败，请检查网络'),
        ),
      );
      if (!_current(revision)) return;
      setState(() => _web = web);
      _renderTimeout = Timer(
        const Duration(seconds: 20),
        () => _fail(revision, '公式资源加载超时'),
      );
      await web.loadHtmlString(html, baseUrl: widget.api.baseUrl);
    } catch (error) {
      if (error is DioException && CancelToken.isCancel(error)) return;
      assert(() {
        debugPrint('Study renderer: $error');
        return true;
      }());
      if (_current(revision)) _fail(revision, '内容加载失败，请检查网络后重试');
    }
  }

  @override
  void dispose() {
    _revision++;
    _renderTimeout?.cancel();
    _request?.cancel();
    // webview_flutter releases its platform view when the widget is removed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.card.contentFormat != 'markdown_math') {
      return PlainCardFace(card: widget.card, revealed: widget.revealed);
    }
    return Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text('$_error。已显示原文，自动显示与自动播放已暂停。'),
                TextButton(onPressed: _schedule, child: const Text('重试公式渲染')),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              if (_error != null)
                PlainCardFace(card: widget.card, revealed: widget.revealed)
              else if (_web != null)
                WebViewWidget(controller: _web!),
              if (_loading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
