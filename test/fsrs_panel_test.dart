import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/features/decks/fsrs_panel.dart';
import 'package:flashnext_app/models/study.dart';

class TrainingApi extends ApiClient {
  TrainingApi() : super('https://training.test');
  OptimizeJob job = const OptimizeJob();
  int starts = 0, polls = 0, paramsReads = 0;
  @override
  Future<FsrsParams> fsrsParams(int id) async {
    expectSync(id, 41);
    paramsReads++;
    return const FsrsParams(
      w: [1, 2],
      reviewCount: 1200,
      minReviews: 1100,
      timezone: 'Asia/Shanghai',
    );
  }

  @override
  Future<OptimizeJob> optimizeStatus(int id) async {
    expectSync(id, 41);
    polls++;
    return job;
  }

  @override
  Future<OptimizeJob> startOptimize(int id) async {
    expectSync(id, 41);
    starts++;
    return job = const OptimizeJob(running: true);
  }
}

void main() {
  testWidgets(
    'training polls this deck, pauses in background and refreshes completed parameters',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final api = TrainingApi();
      addTearDown(api.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: FsrsPanel(api: api, deckId: 41)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1200 / 训练门槛 1100'), findsOneWidget);
      await tester.tap(find.text('训练本牌组参数'));
      await tester.pumpAndSettle();
      expect(api.starts, 1);
      expect(find.textContaining('训练中'), findsOneWidget);
      final polls = api.polls;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 10));
      expect(api.polls, polls);
      api.job = const OptimizeJob(
        finishedAt: '2026-10-20T00:00:00Z',
        result: {'saved': true},
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(api.polls, greaterThan(polls));
      expect(api.paramsReads, greaterThan(1));
      expect(find.textContaining('参数已保存'), findsOneWidget);
      expect(api.starts, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}
