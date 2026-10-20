import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/core/providers.dart';
import 'package:flashnext_app/features/decks/deck_settings_sheet.dart';
import 'package:flashnext_app/models/study.dart';

class SettingsApi extends ApiClient {
  SettingsApi(super.server);
  final values = <int, DeckSettings>{};
  Map<String, dynamic>? patch;
  bool fail = false;
  @override
  Future<DeckSettings> deckSettings(int id) async => values.putIfAbsent(
    id,
    () => DeckSettings(deckId: id, autoRevealAnswerSeconds: 10),
  );
  @override
  Future<DeckSettings> saveDeckSettings(
    int id,
    Map<String, dynamic> changes,
  ) async {
    patch = changes;
    if (fail) throw ApiException('mock save failed');
    return values[id] = DeckSettings.fromJson({
      ...values[id]!.toJson(),
      ...changes,
      'version': 2,
    });
  }

  @override
  Future<FsrsParams> fsrsParams(int id) async =>
      const FsrsParams(w: [1.2], reviewCount: 2, minReviews: 100);
  @override
  Future<OptimizeJob> optimizeStatus(int id) async => const OptimizeJob();
}

void main() {
  testWidgets(
    'explicit save sends null, reopening reads saved server settings',
    (tester) async {
      final api = SettingsApi('https://a.test');
      addTearDown(api.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDeckSettings(context, 41, 'A'),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final toggle = find.widgetWithText(SwitchListTile, '延迟自动显示答案');
      await tester.scrollUntilVisible(
        toggle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(toggle);
      await tester.pump();
      await tester.tap(find.text('保存设置'));
      await tester.pumpAndSettle();
      expect(api.patch, {'autoRevealAnswerSeconds': null});
      expect(api.values[41]!.autoRevealAnswerSeconds, isNull);
      await tester.tap(find.text('返回'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        toggle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    },
  );

  testWidgets('dirty exit asks before discarding; failed saves retain draft', (
    tester,
  ) async {
    final api = SettingsApi('https://a.test')..fail = true;
    addTearDown(api.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(api)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDeckSettings(context, 41, 'A'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.pump();
    await tester.tap(find.text('保存设置'));
    await tester.pumpAndSettle();
    expect(api.patch, {'newPerDay': 0});
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();
    expect(find.text('放弃未保存的修改？'), findsOneWidget);
    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('A · 设置'), findsOneWidget);
  });

  test('server and deck keys isolate settings', () async {
    final a = SettingsApi('https://a.test');
    final b = SettingsApi('https://b.test');
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(a)],
    );
    addTearDown(container.dispose);
    const aKey = (server: 'https://a.test', deckId: 1);
    const otherKey = (server: 'https://a.test', deckId: 2);
    final first = await container.read(deckSettingsProvider(aKey).future);
    final other = await container.read(deckSettingsProvider(otherKey).future);
    expect(first.deckId, 1);
    expect(other.deckId, 2);
    await a.saveDeckSettings(1, {'newPerDay': 0});
    expect((await a.deckSettings(2)).newPerDay, 20);
    container.updateOverrides([apiClientProvider.overrideWithValue(b)]);
    final secondServer = await container.read(
      deckSettingsProvider((server: b.baseUrl, deckId: 1)).future,
    );
    expect(secondServer.newPerDay, 20);
  });
}
