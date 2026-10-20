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
  int reviewCalls = 0, undoCalls = 0;
  int? submittedDuration;
  @override
  Future<DueQueue> due(int deckId, {CancelToken? cancelToken}) async =>
      loading == null ? data : loading!.future;
  @override
  Future<Card> review(int id, int ratingValue, {int durationMs = 0}) async {
    reviewCalls++;
    submittedDuration = durationMs;
    data = const DueQueue();
    return rating == null ? Card(id: id, deckId: 10) : rating!.future;
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
