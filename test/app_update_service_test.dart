import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/update/app_update_service.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.status, this.body);
  final int status;
  final Object body;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> release({String tag = 'v1.1.0'}) => {
  'tag_name': tag,
  'html_url': 'https://github.com/L-Chris/flashnext-app/releases/tag/$tag',
  'draft': false,
  'prerelease': false,
  'assets': [
    {
      'name': 'FlashNext-${tag.substring(1)}-android.apk',
      'state': 'uploaded',
      'size': 1024,
    },
  ],
};

void main() {
  AppUpdateService service(
    Object body, {
    int status = 200,
    String? architecture,
  }) {
    final dio = Dio()..httpClientAdapter = FakeAdapter(status, body);
    final client = AppUpdateService(dio: dio, architecture: architecture);
    addTearDown(client.dispose);
    return client;
  }

  test('finds a newer release with a ready Android asset', () async {
    final result = await service(release()).check('1.0.0');
    expect(result!.available, isTrue);
    expect(result.version, '1.1.0');
    expect(result.releasePage.host, 'github.com');
  });

  test('prefers a matching split APK over universal downloads', () async {
    final body = release();
    (body['assets'] as List).add({
      'name': 'FlashNext-1.1.0-android-arm64-v8a.apk',
      'state': 'uploaded',
      'size': 1024,
    });
    final result = await service(
      body,
      architecture: 'arm64-v8a',
    ).check('1.0.0');
    expect(
      result!.downloadUrl!.path,
      endsWith('/FlashNext-1.1.0-android-arm64-v8a.apk'),
    );
    expect(result.architecture, 'arm64-v8a');
  });

  test('old universal releases still work on arm64 phones', () async {
    final result = await service(
      release(),
      architecture: 'arm64-v8a',
    ).check('1.0.0');
    expect(result!.downloadUrl!.path, endsWith('/FlashNext-1.1.0-android.apk'));
  });

  test('does not offer an APK for the wrong architecture', () async {
    final body = release()
      ..['assets'] = [
        {
          'name': 'FlashNext-1.1.0-android-x86_64.apk',
          'state': 'uploaded',
          'size': 1024,
        },
      ];
    await expectLater(
      service(body, architecture: 'arm64-v8a').check('1.0.0'),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('compares numeric versions, not strings', () async {
    expect(
      (await service(release(tag: 'v1.10.0')).check('1.9.0'))!.available,
      isTrue,
    );
  });

  test('same version with build metadata does not prompt', () async {
    expect((await service(release()).check('1.1.0+9'))!.available, isFalse);
  });

  test('never offers a downgrade', () async {
    expect((await service(release()).check('2.0.0'))!.available, isFalse);
  });

  test('stable version replaces prerelease', () async {
    expect((await service(release()).check('1.1.0-beta.1'))!.available, isTrue);
  });

  test('404 means no published stable release', () async {
    expect(await service({}, status: 404).check('1.0.0'), isNull);
  });

  for (final flag in ['draft', 'prerelease']) {
    test('ignores $flag releases', () async {
      expect(await service(release()..[flag] = true).check('1.0.0'), isNull);
    });
  }

  test('ignores prerelease tags even if mislabeled', () async {
    expect(await service(release(tag: 'v1.2.0-beta.1')).check('1.0.0'), isNull);
  });

  test('rejects missing APK instead of offering an unusable update', () async {
    await expectLater(
      service(release()..['assets'] = []).check('1.0.0'),
      throwsA(isA<AppUpdateException>()),
    );
  });

  for (final url in [
    'http://github.com/L-Chris/flashnext-app/releases/tag/v1.1.0',
    'https://example.com/download',
    'https://github.com/other/app/releases/tag/v1.1.0',
  ]) {
    test('rejects untrusted release URL $url', () async {
      await expectLater(
        service(release()..['html_url'] = url).check('1.0.0'),
        throwsA(isA<AppUpdateException>()),
      );
    });
  }

  test('reports rate limiting as retryable', () async {
    await expectLater(
      service({}, status: 403).check('1.0.0'),
      throwsA(
        isA<AppUpdateException>().having(
          (e) => e.message,
          'message',
          contains('稍后'),
        ),
      ),
    );
  });

  test('reports malformed response', () async {
    await expectLater(
      service(['invalid']).check('1.0.0'),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('rejects nonversion tags', () async {
    await expectLater(
      service(release(tag: 'vrelease')).check('1.0.0'),
      throwsFormatException,
    );
  });
}
