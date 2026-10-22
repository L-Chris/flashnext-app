import 'dart:async';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/core/providers.dart';
import 'package:flashnext_app/features/decks/decks_screen.dart';
import 'package:flashnext_app/features/review/review_card_frame.dart';
import 'package:flashnext_app/features/review/review_screen.dart';
import 'package:flashnext_app/models/deck.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flashnext_app/models/study.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenApi extends ApiClient {
  ScreenApi() : super('https://review.test');
  int dueCalls = 0, reviewCalls = 0, deckCalls = 0;
  Completer<Card>? score;
  final pending = [
    for (var id = 1; id <= 2; id++)
      Card(
        id: id,
        deckId: 10,
        front: 'question $id',
        back: 'answer $id',
        presentation: const CardPresentation(answerRevealAfterMs: 0),
      ),
  ];
  @override
  Future<DueQueue> due(int deckId, {CancelToken? cancelToken}) async {
    dueCalls++;
    return DueQueue(
      cards: pending.toList(),
      usage: const Usage(newRemaining: 5, reviewRemaining: 99),
      counts: const QueueCounts(hiddenByLimit: 7),
    );
  }

  @override
  Future<List<Deck>> decks() async {
    deckCalls++;
    return const [Deck(id: 10, name: 'Test deck', dueCount: 2)];
  }

  @override
  Future<Card> review(int id, int rating, {int durationMs = 0}) async {
    reviewCalls++;
    final result =
        await (score?.future ??
            Future.value(Card(id: id, state: 2, interval: 1)));
    pending.removeWhere((card) => card.id == id);
    return result;
  }
}

void main() {
  testWidgets(
    'no quota or bottom loading bar; pending score stays locked; cached next card needs no GET',
    (tester) async {
      final api = ScreenApi()..score = Completer<Card>();
      addTearDown(api.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: MaterialApp(
            home: Consumer(
              builder: (_, ref, _) {
                ref.watch(decksProvider);
                return const ReviewScreen(deckId: 10, deckName: 'Test deck');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('新卡剩余'), findsNothing);
      expect(find.textContaining('复习剩余'), findsNothing);
      expect(find.textContaining('已达限额'), findsNothing);
      await tester.tap(find.text('良好'));
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('question 1'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '良好'))
            .onPressed,
        isNull,
      );
      expect(api.reviewCalls, 1);
      api.score!.complete(const Card(id: 1, state: 2, interval: 1));
      await tester.pumpAndSettle();
      expect(find.text('question 2'), findsOneWidget);
      expect(api.dueCalls, 1);
      expect(api.deckCalls, 1);
    },
  );

  testWidgets(
    'homepage counts refresh once on return, not after every rating',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final api = ScreenApi();
      addTearDown(api.dispose);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const DecksScreen()),
          GoRoute(
            path: '/review/:id',
            builder: (_, _) =>
                const ReviewScreen(deckId: 10, deckName: 'Test deck'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [apiClientProvider.overrideWithValue(api)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.deckCalls, 1);
      await tester.tap(find.text('Test deck'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('良好'));
      await tester.pumpAndSettle();
      expect(api.deckCalls, 1);
      expect(api.dueCalls, 1);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(api.deckCalls, 2);
    },
  );

  testWidgets(
    'an opaque card background cannot erase any rounded border corner',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
                .copyWith(outlineVariant: Colors.red),
          ),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: ReviewCardFrame(child: ColoredBox(color: Colors.blue)),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          for (final (x, y) in [(5, 5), (194, 5), (5, 194), (194, 194)]) {
            final offset = (y * image.width + x) * 4;
            // A hidden border would leave only the blue child's zero red channel.
            expect(
              bytes!.getUint8(offset),
              greaterThan(50),
              reason: 'corner $x,$y',
            );
          }
        } finally {
          image.dispose();
        }
      });
    },
  );
}
