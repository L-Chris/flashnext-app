import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flashnext_app/models/study.dart';
import 'package:flashnext_app/features/review/review_session.dart';

class FakeStudyApi extends ApiClient {
  FakeStudyApi(this.data) : super('https://study.test');
  DueQueue data;
  Card restored = const Card(id: 1, deckId: 10);
  Completer<Card>? rating;
  Completer<DueQueue>? loading;
  int reviewCalls = 0, undoCalls = 0, dueCalls = 0;
  bool failReview = false, failDue = false;
  final results = <int, Card>{};
  int? submittedDuration;
  @override
  Future<DueQueue> due(int deckId, {CancelToken? cancelToken}) async {
    dueCalls++;
    if (failDue) throw ApiException('queue unavailable');
    return loading == null ? data : loading!.future;
  }

  @override
  Future<Card> review(int id, int ratingValue, {int durationMs = 0}) async {
    reviewCalls++;
    submittedDuration = durationMs;
    if (failReview) throw ApiException('offline');
    data = data.copyWith(cards: data.cards.where((c) => c.id != id).toList());
    return rating == null
        ? results[id] ?? Card(id: id, deckId: 10, state: 2, interval: 1)
        : rating!.future;
  }

  @override
  Future<Card> undo(int id) async {
    undoCalls++;
    return restored;
  }
}

Card sample({int? delay, bool audio = false}) => Card(
  id: 1,
  deckId: 10,
  front: 'question',
  back: 'answer',
  presentation: CardPresentation(
    answerRevealAfterMs: delay,
    audioAutoplay: audio,
  ),
  media: const [
    CardMedia(mediaId: 'a', side: 'front', url: '/api/media/a/content'),
    CardMedia(mediaId: 'b', side: 'back', url: '/api/media/b/content'),
  ],
);

void main() {
  final epoch = DateTime.utc(2026, 10, 22);
  List<Card> batch(int count) => [
    for (var id = 1; id <= count; id++) sample(delay: 0).copyWith(id: id),
  ];
  void answer(ReviewSession session, FakeAsync async, [int rating = 3]) {
    session.contentReady(session.visit, session.revealed);
    session.rate(rating);
    async.flushMicrotasks();
  }

  test(
    '20 successful ratings use one initial queue and one refill, not 21 queues',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: batch(25)));
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
      );
      session.load();
      async.flushMicrotasks();
      for (var i = 1; i <= 19; i++) {
        expect(session.card!.id, i);
        answer(session, async);
        expect(api.dueCalls, 1);
      }
      answer(session, async);
      expect(api.reviewCalls, 20);
      expect(api.dueCalls, 2);
      expect(session.card!.id, 21);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'new learning cards do not immediately repeat ahead of cached work',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: batch(3)));
      api.results[1] = sample(delay: 0).copyWith(
        state: 1,
        due: epoch.add(const Duration(minutes: 1)).toIso8601String(),
      );
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
        wallClock: () => epoch.add(async.elapsed),
      );
      session.load();
      async.flushMicrotasks();
      answer(session, async, 1);
      expect(session.card!.id, 2);
      expect(api.dueCalls, 1);
      // The server includes the requeued card once its actual delay has passed.
      api.data = DueQueue(cards: [api.results[1]!, batch(3).last]);
      async.elapse(const Duration(minutes: 1));
      answer(session, async);
      expect(api.dueCalls, 2);
      expect(session.card!.id, 1);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'learning cards from the initial snapshot gain priority when they become due',
    () => fakeAsync((async) {
      final learning = sample(delay: 0).copyWith(
        id: 4,
        state: 3,
        due: epoch.add(const Duration(seconds: 30)).toIso8601String(),
      );
      final api = FakeStudyApi(DueQueue(cards: [...batch(3), learning]));
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
        wallClock: () => epoch.add(async.elapsed),
      );
      session.load();
      async.flushMicrotasks();
      answer(session, async);
      api.data = DueQueue(cards: [learning, batch(3).last]);
      async.elapse(const Duration(seconds: 31));
      answer(session, async);
      expect(api.dueCalls, 2);
      expect(session.card!.id, 4);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'before learning ahead, refresh to apply the server window and ordering',
    () => fakeAsync((async) {
      final later = sample(delay: 0).copyWith(
        id: 2,
        state: 1,
        due: epoch.add(const Duration(minutes: 10)).toIso8601String(),
      );
      final earlier = sample(delay: 0).copyWith(
        state: 1,
        due: epoch.add(const Duration(minutes: 1)).toIso8601String(),
      );
      final api = FakeStudyApi(DueQueue(cards: [sample(delay: 0), later]))
        ..rating = Completer<Card>();
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
        wallClock: () => epoch.add(async.elapsed),
      );
      session.load();
      async.flushMicrotasks();
      answer(session, async);
      api.data = DueQueue(cards: [earlier, later]);
      api.rating!.complete(earlier);
      async.flushMicrotasks();
      expect(api.dueCalls, 2);
      expect(session.card!.id, 1);
      session.dispose();
      api.dispose();
    }),
  );

  for (final reason in ['age', 'foreground', 'settings']) {
    test(
      'refresh snapshot after $reason changes',
      () => fakeAsync((async) {
        final api = FakeStudyApi(DueQueue(cards: batch(3)));
        final session = ReviewSession(
          api: api,
          deckId: 10,
          clock: () => async.elapsed,
        );
        session.load();
        async.flushMicrotasks();
        if (reason == 'age') async.elapse(ReviewSession.cacheLifetime);
        if (reason == 'foreground') {
          session.setForeground(false);
          session.setForeground(true);
        }
        if (reason == 'settings') {
          api.results[1] = const Card(
            id: 1,
            presentation: CardPresentation(settingsVersion: 2),
          );
        }
        answer(session, async);
        expect(api.dueCalls, 2);
        expect(session.card!.id, 2);
        session.dispose();
        api.dispose();
      }),
    );
  }

  test(
    'failed score keeps current card and batch; retry is explicit',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: batch(3)))..failReview = true;
      final session = ReviewSession(api: api, deckId: 10);
      session.load();
      async.flushMicrotasks();
      answer(session, async);
      expect(session.card!.id, 1);
      expect(session.canRate, isTrue);
      expect(api.reviewCalls, 1);
      expect(api.dueCalls, 1);
      api.failReview = false;
      answer(session, async);
      expect(session.card!.id, 2);
      expect(api.reviewCalls, 2);
      expect(api.dueCalls, 1);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'failed refill does not turn a successful score into another POST',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: batch(1)));
      final session = ReviewSession(api: api, deckId: 10);
      session.load();
      async.flushMicrotasks();
      api.failDue = true;
      answer(session, async);
      expect(session.error, isNotNull);
      expect(session.canUndo, isTrue);
      api.failDue = false;
      session.load();
      async.flushMicrotasks();
      expect(api.reviewCalls, 1);
      expect(session.done, isTrue);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'undo immediately invalidates the cached batch and restores the card first',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: batch(3)))
        ..restored = sample(delay: 0);
      final session = ReviewSession(api: api, deckId: 10);
      session.load();
      async.flushMicrotasks();
      answer(session, async);
      session.undo();
      async.flushMicrotasks();
      expect(api.undoCalls, 1);
      expect(api.dueCalls, 2);
      expect(session.card!.id, 1);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'late score after disposal cannot refill or advance the queue',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: batch(2)))
        ..rating = Completer<Card>();
      final session = ReviewSession(api: api, deckId: 10);
      session.load();
      async.flushMicrotasks();
      answer(session, async);
      session.dispose();
      api.rating!.complete(const Card(id: 1));
      async.flushMicrotasks();
      expect(api.dueCalls, 1);
      api.dispose();
    }),
  );

  test(
    'timing starts only when ready and pauses in background',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: [sample(delay: 10000)]));
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
      );
      session.load();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 30));
      expect(session.durationMs, 0);
      session.contentReady(session.visit, false);
      async.elapse(const Duration(seconds: 4));
      session.setForeground(false);
      async.elapse(const Duration(minutes: 1));
      expect(session.revealed, isFalse);
      expect(session.durationMs, 4000);
      session.setForeground(true);
      async.elapse(const Duration(seconds: 5));
      expect(session.revealed, isFalse);
      async.elapse(const Duration(seconds: 1));
      expect(session.revealed, isTrue);
      expect(session.durationMs, 10000);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'manual reveal cancels countdown and does not reset study duration',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: [sample(delay: 10000)]));
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
      );
      session.load();
      async.flushMicrotasks();
      session.contentReady(session.visit, false);
      async.elapse(const Duration(seconds: 3));
      session.reveal();
      session.contentReady(session.visit, true);
      async.elapse(const Duration(seconds: 12));
      expect(session.durationMs, 15000);
      expect(api.reviewCalls, 0);
      expect(session.remaining, isNull);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'immediate answer only autoplays the back, duplicate ready is harmless',
    () => fakeAsync((async) {
      final played = <String>[];
      final api = FakeStudyApi(
        DueQueue(cards: [sample(delay: 0, audio: true)]),
      );
      final session = ReviewSession(
        api: api,
        deckId: 10,
        onAutoplay: (_, media) => played.addAll(media.map((m) => m.side)),
      );
      session.load();
      async.flushMicrotasks();
      expect(session.revealed, isTrue);
      session.contentReady(session.visit, false);
      session.contentReady(session.visit, true);
      session.contentReady(session.visit, true);
      expect(played, ['back']);
      session.contentUnavailable(session.visit);
      session.contentReady(session.visit, true);
      expect(played, ['back']);
      session.setForeground(false);
      session.setForeground(true);
      expect(played, ['back']);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'null presentation stays manual indefinitely',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: [sample()]));
      final session = ReviewSession(api: api, deckId: 10);
      session.load();
      async.flushMicrotasks();
      session.contentReady(session.visit, false);
      async.elapse(const Duration(hours: 1));
      expect(session.revealed, isFalse);
      expect(session.remaining, isNull);
      expect(api.reviewCalls, 0);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'render failure pauses automatic effects while allowing manual answer',
    () => fakeAsync((async) {
      final played = <String>[];
      final api = FakeStudyApi(
        DueQueue(cards: [sample(delay: 1000, audio: true)]),
      );
      final session = ReviewSession(
        api: api,
        deckId: 10,
        onAutoplay: (_, media) => played.add('play'),
      );
      session.load();
      async.flushMicrotasks();
      session.contentReady(session.visit, false, automaticAllowed: false);
      async.elapse(const Duration(seconds: 10));
      expect(session.revealed, isFalse);
      expect(played, isEmpty);
      session.reveal();
      session.contentReady(session.visit, true, automaticAllowed: false);
      expect(session.canRate, isTrue);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'only one review POST; completion still permits undo with new presentation',
    () => fakeAsync((async) {
      final api = FakeStudyApi(DueQueue(cards: [sample(delay: 0)]))
        ..rating = Completer<Card>();
      api.restored = sample(delay: 10000);
      final session = ReviewSession(
        api: api,
        deckId: 10,
        clock: () => async.elapsed,
      );
      session.load();
      async.flushMicrotasks();
      final previous = session.visit;
      session.contentReady(previous, true);
      async.elapse(const Duration(seconds: 3));
      session.rate(3);
      session.rate(3);
      async.flushMicrotasks();
      expect(api.reviewCalls, 1);
      expect(api.submittedDuration, 3000);
      api.rating!.complete(const Card(id: 1, deckId: 10));
      async.flushMicrotasks();
      expect(session.done, isTrue);
      expect(session.canUndo, isTrue);
      session.undo();
      async.flushMicrotasks();
      expect(session.card!.id, 1);
      expect(session.revealed, isFalse);
      expect(session.visit, isNot(previous));
      session.contentReady(previous, true);
      expect(session.ready, isFalse);
      session.contentReady(session.visit, false);
      expect(session.remaining, const Duration(seconds: 10));
      expect(api.undoCalls, 1);
      session.dispose();
      api.dispose();
    }),
  );

  test(
    'dispose ignores late queue replies and cancels timers',
    () => fakeAsync((async) {
      final api = FakeStudyApi(const DueQueue())
        ..loading = Completer<DueQueue>();
      final session = ReviewSession(api: api, deckId: 10);
      var changes = 0;
      session.addListener(() => changes++);
      session.load();
      session.dispose();
      final before = changes;
      api.loading!.complete(DueQueue(cards: [sample(delay: 0)]));
      async.flushMicrotasks();
      expect(changes, before);
      api.dispose();
    }),
  );

  test(
    'media is filtered by side and position, independently of input order',
    () {
      final card = Card(
        media: const [
          CardMedia(mediaId: 'b', side: 'back', position: 2, url: '/b'),
          CardMedia(mediaId: 'f', side: 'front', url: '/f'),
          CardMedia(mediaId: 'a', side: 'back', position: 0, url: '/a'),
        ],
      );
      expect(mediaForSide(card, true).map((m) => m.mediaId), ['a', 'b']);
    },
  );
}
