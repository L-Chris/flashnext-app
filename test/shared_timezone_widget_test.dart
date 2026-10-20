import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/features/settings/shared_timezone_section.dart';
import 'package:flashnext_app/features/settings/settings_screen.dart';
import 'package:flashnext_app/core/providers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimezoneApi extends ApiClient {
  TimezoneApi(super.server);
  String timezone = 'Asia/Shanghai';
  bool fail = false;
  Completer<String>? delayedRead;
  @override
  Future<String> sharedTimezone() async => delayedRead?.future ?? timezone;
  @override
  Future<String> saveSharedTimezone(String value) async {
    if (fail) throw ApiException('invalid timezone');
    return timezone = value;
  }
}

void main() {
  testWidgets('global settings opens as a modal with the shared timezone', (
    tester,
  ) async {
    final api = TimezoneApi('https://a.test');
    addTearDown(api.dispose);
    SharedPreferences.setMockInitialValues({kBaseUrlPrefKey: api.baseUrl});
    PackageInfo.setMockInitialValues(
      appName: 'FlashNext',
      packageName: 'test',
      version: '0.1.0',
      buildNumber: '4',
      buildSignature: '',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(api)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSettings(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('学习时区'), findsOneWidget);
    expect(find.text('Asia/Shanghai'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  Widget host(TimezoneApi api) => ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SharedTimezoneSection(key: ValueKey(api.baseUrl), api: api),
      ),
    ),
  );

  testWidgets(
    'shared timezone persists on reopen; failed save preserves draft',
    (tester) async {
      final api = TimezoneApi('https://a.test');
      addTearDown(api.dispose);
      await tester.pumpWidget(host(api));
      await tester.pumpAndSettle();
      expect(find.text('Asia/Shanghai'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'UTC');
      await tester.pump();
      await tester.tap(find.text('保存时区'));
      await tester.pumpAndSettle();
      expect(api.timezone, 'UTC');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(host(api));
      await tester.pumpAndSettle();
      expect(find.text('UTC'), findsOneWidget);
      api.fail = true;
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.pump();
      await tester.tap(find.text('保存时区'));
      await tester.pumpAndSettle();
      expect(find.text('invalid'), findsOneWidget);
      expect(api.timezone, 'UTC');
    },
  );

  testWidgets('switching server discards stale timezone response', (
    tester,
  ) async {
    final a = TimezoneApi('https://a.test')..delayedRead = Completer<String>();
    final b = TimezoneApi('https://b.test')..timezone = 'Asia/Tokyo';
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    await tester.pumpWidget(host(a));
    await tester.pump();
    await tester.pumpWidget(host(b));
    await tester.pumpAndSettle();
    a.delayedRead!.complete('UTC');
    await tester.pumpAndSettle();
    expect(find.text('Asia/Tokyo'), findsOneWidget);
    expect(find.text('UTC'), findsNothing);
  });
}
