import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/models/due_queue.dart';

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.reply);
  final Object Function(RequestOptions) reply;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions request,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(request);
    return ResponseBody.fromString(
      jsonEncode({'data': reply(request)}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'shared timezone uses one global endpoint, not per-deck patches',
    () async {
      var timezone = 'Asia/Shanghai';
      final adapter = RecordingAdapter((request) {
        if (request.method == 'POST') {
          timezone = request.data['timezone'] as String;
        }
        return {'timezone': timezone};
      });
      final api = ApiClient(
        'https://a.test',
        dio: Dio(BaseOptions(baseUrl: 'https://a.test/api'))
          ..httpClientAdapter = adapter,
      );
      addTearDown(api.dispose);
      expect(await api.sharedTimezone(), 'Asia/Shanghai');
      expect(await api.saveSharedTimezone('UTC'), 'UTC');
      expect(adapter.requests.every((r) => r.path == '/settings'), isTrue);
      expect(adapter.requests.last.data, {'timezone': 'UTC'});
    },
  );
  final settings = (jsonDecode(
    File('docs/handoff/fixtures/deck-settings.json').readAsStringSync(),
  ) as Map)['data'];
  final preview = (jsonDecode(
    File('docs/handoff/fixtures/content-preview.json').readAsStringSync(),
  ) as Map)['response']['data'];
  test(
    'settings patches keep null; FSRS routes always include the deck',
    () async {
      final adapter = RecordingAdapter((request) {
        if (request.path.endsWith('/settings')) return settings;
        if (request.path.endsWith('/params')) {
          return {
            'w': [1.0],
            'reviewCount': 2,
            'minReviews': 1500,
          };
        }
        if (request.method == 'POST') {
          return {
            'started': true,
            'job': {'running': true},
          };
        }
        return {'running': false};
      });
      final api = ApiClient(
        'https://a.test',
        dio: Dio(BaseOptions(baseUrl: 'https://a.test/api'))
          ..httpClientAdapter = adapter,
      );
      addTearDown(api.dispose);
      await api.deckSettings(41);
      await api.saveDeckSettings(41, {
        'autoRevealAnswerSeconds': null,
        'newPerDay': 0,
      });
      expect(adapter.requests.last.data, {
        'autoRevealAnswerSeconds': null,
        'newPerDay': 0,
      });
      final params = await api.fsrsParams(41);
      expect(params.minReviews, 1500);
      expect((await api.startOptimize(41)).running, isTrue);
      await api.optimizeStatus(41);
      expect(
        adapter.requests.every((r) => r.path.startsWith('/decks/41/')),
        isTrue,
      );
      expect(adapter.requests.where((r) => r.method == 'POST').length, 2);
    },
  );

  test('paginated cards unwraps data.cards', () async {
    final adapter = RecordingAdapter(
      (_) => {
        'cards': [
          {'id': 1, 'front': 'q'},
        ],
        'total': 1,
      },
    );
    final api = ApiClient(
      'https://a.test',
      dio: Dio()..httpClientAdapter = adapter,
    );
    addTearDown(api.dispose);
    expect((await api.cards(1)).single.front, 'q');
  });

  test(
    'preview cache uses original content and is isolated per server',
    () async {
      final adapterA = RecordingAdapter((_) => preview);
      final adapterB = RecordingAdapter((_) => preview);
      final a = ApiClient(
        'https://a.test',
        dio: Dio()..httpClientAdapter = adapterA,
      );
      final b = ApiClient(
        'https://b.test',
        dio: Dio()..httpClientAdapter = adapterB,
      );
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      const card = Card(
        contentFormat: 'markdown_math',
        front: r'\(x\)',
        back: r'$$x$$',
      );
      await a.preview(card);
      await a.preview(card);
      await b.preview(card);
      expect(adapterA.requests.length, 1);
      expect(adapterB.requests.length, 1);
      await a.preview(card.copyWith(back: r'$$y$$'));
      expect(adapterA.requests.length, 2);
      for (var i = 0; i < 22; i++) {
        await a.preview(card.copyWith(front: '$i'));
      }
      await a.preview(card);
      expect(
        adapterA.requests.length,
        25,
      ); // bounded LRU evicted the first entry
    },
  );

  test(
    'review and undo POST failures are never automatically retried',
    () async {
      final dio = Dio();
      var requests = 0;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );
      final api = ApiClient('https://a.test', dio: dio);
      addTearDown(api.dispose);
      await expectLater(api.review(1, 3), throwsA(isA<DioException>()));
      await expectLater(api.undo(1), throwsA(isA<DioException>()));
      expect(requests, 2);
    },
  );
}
