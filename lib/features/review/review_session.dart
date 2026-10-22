import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../models/due_queue.dart';
import '../../models/study.dart';

List<CardMedia> mediaForSide(Card card, bool revealed) =>
    card.media.where((m) => m.side == (revealed ? 'back' : 'front')).toList()
      ..sort((a, b) {
        final n = a.position.compareTo(b.position);
        return n != 0 ? n : a.mediaId.compareTo(b.mediaId);
      });

/// One controller per server/deck. A revisit (including undo) always gets a new token.
class ReviewSession extends ChangeNotifier {
  ReviewSession({
    required this.api,
    required this.deckId,
    Duration Function()? clock,
    DateTime Function()? wallClock,
    this.onAutoplay,
    this.onStopAudio,
  }) : _clock = clock ?? _monotonicClock(),
       _wallClock = wallClock ?? DateTime.now;

  final ApiClient api;
  final int deckId;
  final Duration Function() _clock;
  final DateTime Function() _wallClock;
  static const batchSize = 20;
  static const cacheLifetime = Duration(minutes: 2);
  final _learningDueAt = <int, Duration>{};
  Duration? _loadedAt;
  int _batchRemaining = 0;
  bool _refreshOnAdvance = false;
  final void Function(String visit, List<CardMedia> media)? onAutoplay;
  final VoidCallback? onStopAudio;
  final _requests = CancelToken();
  static Duration Function() _monotonicClock() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  DueQueue? queue;
  Card? card;
  bool busy = false;
  bool revealed = false;
  bool ready = false;
  bool foreground = true;
  String? error;
  String? notice;
  int? _lastRated;
  int _visit = 0, _operation = 0;
  bool _disposed = false, _automaticAllowed = true;
  bool _autoplayApplied = false;
  Duration _studied = Duration.zero;
  Duration? _durationSince, _remaining, _countdownSince;
  Timer? _ticker;

  String get visit => '${api.baseUrl}:$deckId:${card?.id}:$_visit';
  bool get canUndo => _lastRated != null && !busy;
  bool get done => !busy && error == null && queue != null && card == null;
  bool get canRate => !busy && foreground && revealed && ready && card != null;
  bool get counting =>
      ready &&
      foreground &&
      _automaticAllowed &&
      !revealed &&
      _remaining != null;
  int get durationMs =>
      (_studied +
              (_durationSince == null
                  ? Duration.zero
                  : _clock() - _durationSince!))
          .inMilliseconds;
  Duration? get remaining {
    final value = _remaining;
    if (value == null) return null;
    final result =
        value -
        (_countdownSince == null ? Duration.zero : _clock() - _countdownSince!);
    return result.isNegative ? Duration.zero : result;
  }

  bool _valid(int operation) => !_disposed && operation == _operation;
  String _message(Object value) =>
      value is DioException ? describeDioError(value) : '$value';

  void _freeze() {
    if (_durationSince != null) _studied += _clock() - _durationSince!;
    _durationSince = null;
    _remaining = remaining;
    _countdownSince = null;
    _ticker?.cancel();
    _ticker = null;
  }

  void _resumeTiming() {
    if (!foreground || !ready || busy || card == null) return;
    _durationSince ??= _clock();
    if (revealed || !_automaticAllowed || _remaining == null) return;
    _countdownSince ??= _clock();
    _ticker ??= Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_disposed) return;
      if (remaining == Duration.zero) {
        reveal();
      } else {
        notifyListeners();
      }
    });
  }

  void _begin(Card? value) {
    _freeze();
    onStopAudio?.call();
    _visit++;
    card = value;
    ready = false;
    revealed = value?.presentation.answerRevealAfterMs == 0;
    _automaticAllowed = true;
    _autoplayApplied = false;
    _studied = Duration.zero;
    final delay = value?.presentation.answerRevealAfterMs;
    _remaining = delay != null && delay > 0
        ? Duration(milliseconds: delay)
        : null;
  }

  Future<void> load() async {
    if (busy || _disposed) return;
    final operation = ++_operation;
    busy = true;
    error = null;
    notice = null;
    _begin(null);
    notifyListeners();
    await _refresh(operation);
  }

  Future<void> _refresh(int operation, {Card? restored}) async {
    try {
      final data = await api.due(deckId, cancelToken: _requests);
      if (!_valid(operation)) return;
      queue = restored == null
          ? data
          : data.copyWith(
              cards: [
                restored,
                ...data.cards.where((c) => c.id != restored.id),
              ],
            );
      final now = _clock();
      _loadedAt = now;
      _batchRemaining = batchSize;
      _refreshOnAdvance = false;
      // A past deadline has just been reconciled by the server. Keep future
      // deadlines even if learn-ahead=0 excluded those cards from this response.
      _learningDueAt.removeWhere((_, deadline) => deadline <= now);
      if (restored != null) _learningDueAt.remove(restored.id);
      for (final pending in queue!.cards) {
        _rememberLearning(pending, onlyFuture: true);
      }
      _begin(queue!.cards.firstOrNull);
    } catch (value) {
      if (!_valid(operation)) return;
      if (restored != null) {
        queue = DueQueue(cards: [restored]);
        _begin(restored);
        notice = '已撤销，队列刷新失败：${_message(value)}';
      } else {
        error = _message(value);
      }
    } finally {
      if (_valid(operation)) {
        busy = false;
        notifyListeners();
      }
    }
  }

  static bool _intradayLearning(Card value) =>
      value.interval == 0 && (value.state == 1 || value.state == 3);

  void _rememberLearning(Card value, {bool onlyFuture = false}) {
    if (!_intradayLearning(value)) return;
    final due = DateTime.tryParse(value.due);
    if (due == null) {
      _refreshOnAdvance = true;
      return;
    }
    final delay = due.difference(_wallClock());
    if (onlyFuture && delay <= Duration.zero) return;
    _learningDueAt[value.id] = _clock() + delay;
  }

  bool get _needsRefresh {
    final next = queue?.cards.firstOrNull;
    final now = _clock();
    if (next == null ||
        _batchRemaining <= 0 ||
        _refreshOnAdvance ||
        _loadedAt == null ||
        now - _loadedAt! >= cacheLifetime ||
        _learningDueAt.values.any((deadline) => deadline <= now)) {
      return true;
    }
    // Before learning ahead, ask the server to include newly rated learning
    // cards and enforce its configured window; never guess that window here.
    if (_intradayLearning(next)) {
      final due = DateTime.tryParse(next.due);
      if (due == null || due.isAfter(_wallClock())) return true;
    }
    return false;
  }

  void contentUnavailable(String token) {
    if (_disposed || token != visit) return;
    _freeze();
    ready = false;
    onStopAudio?.call();
    notifyListeners();
  }

  void contentReady(String token, bool back, {bool automaticAllowed = true}) {
    if (_disposed ||
        token != visit ||
        back != revealed ||
        ready ||
        card == null) {
      return;
    }
    ready = true;
    _automaticAllowed = automaticAllowed;
    _resumeTiming();
    final autoplay = automaticAllowed && !_autoplayApplied;
    if (automaticAllowed) _autoplayApplied = true;
    if (autoplay &&
        foreground &&
        !busy &&
        automaticAllowed &&
        card!.presentation.audioAutoplay) {
      final media = mediaForSide(card!, revealed);
      if (media.isNotEmpty) onAutoplay?.call('$visit:$revealed', media);
    }
    notifyListeners();
  }

  void reveal() {
    if (_disposed || busy || !foreground || revealed || card == null) return;
    _freeze();
    _remaining = null;
    revealed = true;
    _autoplayApplied = false;
    ready = false;
    onStopAudio?.call();
    notifyListeners();
  }

  void setForeground(bool value) {
    if (_disposed || foreground == value) return;
    foreground = value;
    if (!value) {
      _refreshOnAdvance = true;
      _freeze();
      onStopAudio?.call();
    } else {
      _resumeTiming();
    }
    notifyListeners();
  }

  Future<void> rate(int rating) async {
    if (!canRate || rating < 1 || rating > 4) return;
    final current = card!;
    final operation = ++_operation;
    _freeze();
    onStopAudio?.call();
    busy = true;
    notice = null;
    notifyListeners();
    try {
      final rated = await api.review(
        current.id,
        rating,
        durationMs: durationMs,
      );
      if (!_valid(operation)) return;
      _lastRated = rated.id;
      _learningDueAt.remove(current.id);
      _rememberLearning(rated);
      _batchRemaining--;
      queue = queue!.copyWith(
        cards: queue!.cards.where((value) => value.id != current.id).toList(),
      );
      if (rated.presentation.settingsVersion !=
          current.presentation.settingsVersion) {
        _refreshOnAdvance = true;
      }
      if (_needsRefresh) {
        _begin(null);
        await _refresh(operation);
      } else {
        _begin(queue!.cards.first);
        busy = false;
        notifyListeners();
      }
    } catch (value) {
      if (!_valid(operation)) return;
      busy = false;
      notice = '评分失败，请确认网络后再操作：${_message(value)}';
      _resumeTiming();
      notifyListeners();
    }
  }

  Future<void> undo() async {
    if (!canUndo || _disposed) return;
    final operation = ++_operation;
    final id = _lastRated!;
    _freeze();
    onStopAudio?.call();
    busy = true;
    error = null;
    notice = null;
    notifyListeners();
    try {
      final restored = await api.undo(id);
      if (!_valid(operation)) return;
      _lastRated = null;
      _begin(null);
      await _refresh(operation, restored: restored);
    } catch (value) {
      if (!_valid(operation)) return;
      busy = false;
      notice = '撤销失败：${_message(value)}';
      _resumeTiming();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _requests.cancel('Review session closed');
    _operation++;
    _freeze();
    onStopAudio?.call();
    super.dispose();
  }
}
