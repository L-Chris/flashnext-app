import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/core/providers.dart';
import 'package:flashnext_app/features/review/review_audio.dart';
import 'package:flashnext_app/main.dart';
import 'package:flashnext_app/models/study.dart';

/// All state-changing requests go to this in-memory loopback service.
/// Only content preview and KaTeX resources may be read from the production server.
class StudyTestServer {
  late HttpServer server;
  final upstream = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'STUDY_UPSTREAM',
        defaultValue: 'https://mem.home.rethinkos.com',
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  final reviewed = <int>{};
  final writes = <String>[];
  final mediaReads = <String>[];
  final settings = <int, Map<String, dynamic>>{};
  String get url => 'http://127.0.0.1:${server.port}';
  bool failMedia = false;
  bool failPreview = false;
  int styleReads = 0;
  int fontReads = 0;

  Map<String, dynamic> config(int id) => settings.putIfAbsent(
    id,
    () => {
      'deckId': id,
      'newPerDay': 20,
      'reviewPerDay': 500,
      'timezone': 'Asia/Shanghai',
      'rolloverHour': 4,
      'version': 1,
      'audioAutoplay': id == 42,
      'showNewCardAnswerImmediately': id == 42,
      'autoRevealAnswerSeconds': id == 41 ? 2 : null,
    },
  );

  Map<String, dynamic> card(int id) => {
    'id': id,
    'deckId': id,
    'front': id == 42
        ? '学生'
        : id == 43
        ? r'矩阵 \(\begin{pmatrix}1&2\\3&4\end{pmatrix}\) 与 \[\sqrt{4}\]，价格 $5'
        : 'derive',
    'back': id == 42
        ? 'がくせい\n名词\n学生'
        : id == 43
        ? r'$$x=\frac{1}{2}$$ 和 `\(code\)`'
        : '/dɪˈraɪv/\nv. 源自；获得',
    'contentFormat': id == 43 ? 'markdown_math' : 'plain',
    'word': id == 42
        ? {
            'id': id,
            'language': 'ja',
            'headword': '学生',
            'reading': 'がくせい',
            'romaji': 'gakusei',
            'pos': '名词',
            'translation': '学生',
          }
        : null,
    'media': id == 42
        ? [
            for (var position = 0; position < 2; position++)
              {
                'mediaId': 'synthetic-$position',
                'id': 'synthetic-$position',
                'side': 'back',
                'position': position,
                'url': '/api/media/synthetic-$position/content',
                'mimeType': 'audio/wav',
              },
          ]
        : [],
    'presentation': {
      'audioAutoplay': config(id)['audioAutoplay'],
      'answerRevealAfterMs': id == 42
          ? 0
          : config(id)['autoRevealAnswerSeconds'] == null
          ? null
          : (config(id)['autoRevealAnswerSeconds'] as int) * 1000,
      'settingsVersion': config(id)['version'],
    },
  };

  Uint8List wav() {
    const samples = 2205;
    final bytes = Uint8List(44 + samples * 2);
    final data = ByteData.sublistView(bytes);
    void word(int offset, String value) =>
        bytes.setRange(offset, offset + value.length, ascii.encode(value));
    word(0, 'RIFF');
    data.setUint32(4, bytes.length - 8, Endian.little);
    word(8, 'WAVE');
    word(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, 22050, Endian.little);
    data.setUint32(28, 44100, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    word(36, 'data');
    data.setUint32(40, samples * 2, Endian.little);
    return bytes;
  }

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final path = request.uri.path;
      try {
        if (path.startsWith('/api/content/assets/')) {
          if (path.endsWith('.css')) {
            styleReads++;
          } else {
            fontReads++;
          }
          final response = await upstream.get<List<int>>(
            path,
            options: Options(responseType: ResponseType.bytes),
          );
          request.response.headers.set(
            'Content-Type',
            response.headers.value('content-type') ??
                'application/octet-stream',
          );
          request.response.add(response.data!);
        } else if (path.startsWith('/api/media/')) {
          mediaReads.add(path);
          if (failMedia) {
            request.response.statusCode = 404;
          } else {
            final bytes = wav();
            request.response.headers.set('Content-Type', 'audio/wav');
            request.response.headers.set('Accept-Ranges', 'bytes');
            request.response.contentLength = bytes.length;
            if (request.method != 'HEAD') request.response.add(bytes);
          }
        } else {
          final rawBody = request.method == 'POST'
              ? await utf8.decoder.bind(request).join()
              : '';
          final body = rawBody.trim().isEmpty
              ? <String, dynamic>{}
              : jsonDecode(rawBody) as Map<String, dynamic>;
          Object value;
          final segments = path.split('/');
          if (path == '/api/decks') {
            value = [
              for (final id in [41, 42, 43])
                {
                  'id': id,
                  'name': {41: '英语测试', 42: '日语测试', 43: '数学测试'}[id],
                  'dueCount': 1,
                },
            ];
          } else if (path == '/api/content/preview') {
            if (failPreview) throw StateError('mock offline');
            // This endpoint is explicitly read-only: source text only, no IDs or mutation.
            final response = await upstream.post<dynamic>(
              '/api/content/preview',
              data: body,
            );
            final decoded = response.data is String
                ? jsonDecode(response.data as String)
                : response.data;
            value = decoded['data'] as Object;
          } else if (segments.length >= 5 && segments[2] == 'decks') {
            final id = int.parse(segments[3]);
            if (path.endsWith('/settings')) {
              if (request.method == 'POST') {
                writes.add(path);
                config(id).addAll(body);
                config(id)['version'] = 2;
              }
              value = config(id);
            } else if (path.endsWith('/due')) {
              value = {
                'cards': reviewed.contains(id) ? [] : [card(id)],
                'usage': {'newRemaining': 20, 'reviewRemaining': 500},
              };
            } else if (path.endsWith('/params')) {
              value = {
                'w': [1.0, 2.0],
                'source': 'default',
                'reviewCount': 0,
                'minReviews': 1000,
              };
            } else {
              value = {'running': false};
            }
          } else if (segments[2] == 'cards') {
            final id = int.parse(segments[3]);
            writes.add(path);
            if (path.endsWith('/review')) {
              reviewed.add(id);
            } else {
              reviewed.remove(id);
            }
            value = card(id);
          } else {
            throw StateError('Unexpected mock route $path');
          }
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({'data': value}));
        }
      } catch (error) {
        debugPrint('Study mock route $path: $error');
        request.response.statusCode = 500;
        request.response.write(jsonEncode({'message': '$error'}));
      }
      await request.response.close();
    });
  }

  Future<void> close() async {
    upstream.close(force: true);
    await server.close(force: true);
  }
}

Future<void> until(
  WidgetTester tester,
  bool Function() predicate, {
  int seconds = 30,
}) async {
  for (var i = 0; i < seconds * 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
    try {
      if (predicate()) return;
    } on StateError {
      // The requested widget may not have been built during a route transition.
    }
  }
  fail(
    'Condition did not become true within $seconds seconds. Visible text: '
    '${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
  );
}

Future<void> tapText(WidgetTester tester, String text) async {
  await until(
    tester,
    () => find.text(text).hitTestable().evaluate().isNotEmpty,
  );
  await tester.tap(find.text(text).hitTestable());
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Android study settings, review/undo, native audio and math WebView',
    (tester) async {
      final backend = StudyTestServer();
      await backend.start();
      addTearDown(backend.close);
      final api = ApiClient(backend.url, logRequests: false);
      addTearDown(api.dispose);
      SharedPreferences.setMockInitialValues({kBaseUrlPrefKey: backend.url});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: const FlashNextApp(),
        ),
      );
      await until(tester, () => find.text('英语测试').evaluate().isNotEmpty);
      await tester.tap(find.byTooltip('英语测试的学习设置'));
      await until(tester, () => find.text('每日新卡额度').evaluate().isNotEmpty);
      expect(find.text('显示答案'), findsNothing); // gear did not enter review
      final toggle = find.widgetWithText(SwitchListTile, '延迟自动显示答案');
      await tester.scrollUntilVisible(
        toggle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(toggle);
      await tester.pump();
      await tester.tap(find.text('保存设置'));
      await until(
        tester,
        () =>
            backend.config(41)['autoRevealAnswerSeconds'] == null &&
            find.text('牌组设置已保存').evaluate().isNotEmpty,
      );
      await tester.tap(find.text('返回'));
      await tester.pumpAndSettle();
      await until(tester, () => find.text('英语测试 · 设置').evaluate().isEmpty);
      await tester.tap(find.text('英语测试'));
      await until(tester, () => find.text('显示答案').evaluate().isNotEmpty);
      await tapText(tester, '显示答案');
      await until(
        tester,
        () =>
            tester
                .widget<FilledButton>(find.widgetWithText(FilledButton, '良好'))
                .onPressed !=
            null,
      );
      await tester.tap(find.text('良好'));
      await until(
        tester,
        () => find.text('太棒了！当前没有需要复习的卡片').evaluate().isNotEmpty,
      );
      await tester.tap(find.byTooltip('撤销上一次'));
      debugPrint('STUDY QA undo tapped; writes so far: ${backend.writes}');
      await until(tester, () => find.text('显示答案').evaluate().isNotEmpty);
      expect(backend.writes.where((p) => p.endsWith('/review')).length, 1);
      expect(backend.writes.where((p) => p.endsWith('/undo')).length, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('日语测试'));
      await until(tester, () => find.text('がくせい').evaluate().isNotEmpty);
      expect(find.text('显示答案'), findsNothing);
      await until(
        tester,
        () => backend.mediaReads.any((p) => p.contains('synthetic-1')),
      );
      expect(
        backend.mediaReads.every((p) => p.startsWith('/api/media/')),
        isTrue,
      );
      // No review is submitted by autoplay.
      expect(backend.writes.where((p) => p == '/api/cards/42/review'), isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();

      backend.failMedia = true;
      final nativeAudio = ReviewAudio(server: backend.url);
      await nativeAudio.play('broken', const [
        CardMedia(mediaId: 'missing', url: '/api/media/missing/content'),
      ]);
      expect(nativeAudio.error, isNotNull);
      nativeAudio.dispose();
      backend.failMedia = false;

      await tester.tap(find.text('数学测试'));
      await until(
        tester,
        () => find.byType(WebViewWidget).evaluate().isNotEmpty,
        seconds: 60,
      );
      await until(tester, () => backend.fontReads > 0, seconds: 60);
      expect(backend.styleReads, greaterThan(0));
      await until(
        tester,
        () => find.byType(CircularProgressIndicator).evaluate().isEmpty,
        seconds: 60,
      );
      expect(find.textContaining('已显示原文'), findsNothing);
      debugPrint('STUDY QA math front rendered with fonts');
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tapText(tester, '显示答案');
      await until(
        tester,
        () =>
            tester
                .widget<FilledButton>(find.widgetWithText(FilledButton, '良好'))
                .onPressed !=
            null,
        seconds: 60,
      );
      expect(find.textContaining('已显示原文'), findsNothing);
      debugPrint('STUDY QA math back rendered');
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(backend.writes.where((p) => p == '/api/cards/43/review'), isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();

      backend.failPreview = true;
      // Different content prevents reuse of a successful preview cache.
      final failingApi = ApiClient(backend.url, logRequests: false);
      // A new provider scope gets an empty render cache without changing production data.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(failingApi)],
          child: const FlashNextApp(),
        ),
      );
      await until(tester, () => find.text('数学测试').evaluate().isNotEmpty);
      await tester.tap(find.text('数学测试'));
      await until(
        tester,
        () => find.textContaining('已显示原文').evaluate().isNotEmpty,
      );
      await tapText(tester, '显示答案');
      await until(
        tester,
        () =>
            tester
                .widget<FilledButton>(find.widgetWithText(FilledButton, '良好'))
                .onPressed !=
            null,
      );
      expect(find.text('重试公式渲染'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      failingApi.dispose();
    },
  );
}
