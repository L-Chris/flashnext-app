import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/deck.dart';
import '../../models/due_queue.dart';
import '../../models/study.dart';

class ApiClient {
  ApiClient(this.baseUrl, {Dio? dio, bool logRequests = kDebugMode})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: '$baseUrl/api',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 20),
            ),
          ) {
    if (logRequests && dio == null) {
      _dio.interceptors.add(LogInterceptor(requestBody: false, error: true));
    }
  }

  final String baseUrl;
  final Dio _dio;
  final _previews = <String, ContentPreview>{};
  int _previewBytes = 0;

  void dispose() {
    _previews.clear();
    _dio.close(force: true);
  }

  static bool _isNetworkFlake(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout;

  Future<Response<dynamic>> _get(
    String path, {
    CancelToken? cancelToken,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await _dio.get(path, cancelToken: cancelToken);
      } on DioException catch (e) {
        attempt++;
        if (attempt >= 3 || !_isNetworkFlake(e)) rethrow;
        await Future.delayed(Duration(milliseconds: 1200 * attempt));
      }
    }
  }

  dynamic _unwrap(Response<dynamic> res) {
    dynamic body = res.data;
    if (body is String) {
      body = jsonDecode(body);
    }
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    throw ApiException('unexpected response shape');
  }

  Future<List<Deck>> decks() async {
    final data = _unwrap(await _get('/decks'));
    return (data as List)
        .map((e) => Deck.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DueQueue> due(int deckId, {CancelToken? cancelToken}) async {
    final data = _unwrap(
      await _get('/decks/$deckId/cards/due', cancelToken: cancelToken),
    );
    return DueQueue.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Card>> cards(int deckId) async {
    final data = _unwrap(await _get('/decks/$deckId/cards'));
    final rows = data is Map<String, dynamic> ? data['cards'] : data;
    return (rows as List)
        .map((e) => Card.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Card> review(int cardId, int rating, {int durationMs = 0}) async {
    final data = _unwrap(
      await _dio.post(
        '/cards/$cardId/review',
        data: {'rating': rating, 'durationMs': durationMs},
      ),
    );
    return Card.fromJson(data as Map<String, dynamic>);
  }

  Future<Card> undo(int cardId) async {
    final data = _unwrap(await _dio.post('/cards/$cardId/undo'));
    return Card.fromJson(data as Map<String, dynamic>);
  }

  Future<DeckSettings> deckSettings(int deckId) async => DeckSettings.fromJson(
    _unwrap(await _get('/decks/$deckId/settings')) as Map<String, dynamic>,
  );

  Future<DeckSettings> saveDeckSettings(
    int deckId,
    Map<String, dynamic> changes,
  ) async => DeckSettings.fromJson(
    _unwrap(await _dio.post('/decks/$deckId/settings', data: changes))
        as Map<String, dynamic>,
  );

  Future<FsrsParams> fsrsParams(int deckId) async => FsrsParams.fromJson(
    _unwrap(await _get('/decks/$deckId/fsrs/params')) as Map<String, dynamic>,
  );

  Future<OptimizeJob> optimizeStatus(int deckId) async => OptimizeJob.fromJson(
    _unwrap(await _get('/decks/$deckId/fsrs/optimize')) as Map<String, dynamic>,
  );

  Future<OptimizeJob> startOptimize(int deckId) async {
    final data = _unwrap(
      await _dio.post('/decks/$deckId/fsrs/optimize', data: {}),
    );
    return OptimizeJob.fromJson(data['job'] as Map<String, dynamic>);
  }

  Future<ContentPreview> preview(Card card, {CancelToken? cancelToken}) async {
    final key = jsonEncode([
      baseUrl,
      card.front,
      card.back,
      card.contentFormat,
    ]);
    final cached = _previews.remove(key);
    if (cached != null) {
      _previews[key] = cached;
      return cached;
    }
    final value = ContentPreview.fromJson(
      _unwrap(
        await _dio.post(
          '/content/preview',
          data: {
            'front': card.front,
            'back': card.back,
            'contentFormat': card.contentFormat,
          },
          cancelToken: cancelToken,
        ),
      ) as Map<String, dynamic>,
    );
    final size = utf8.encode(jsonEncode(value.toJson())).length;
    if (value.valid &&
        size <= 2 * 1024 * 1024 &&
        !(_previews.containsKey(key))) {
      while (_previews.isNotEmpty &&
          (_previews.length >= 20 || _previewBytes + size > 4 * 1024 * 1024)) {
        final removed = _previews.remove(_previews.keys.first)!;
        _previewBytes -= utf8.encode(jsonEncode(removed.toJson())).length;
      }
      _previews[key] = value;
      _previewBytes += size;
    }
    return value;
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

String describeDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return '连接超时，检查网络或服务器地址';
  }
  if (e.type == DioExceptionType.connectionError) {
    return '无法连接服务器，确认处于内网/Tailscale 且地址正确';
  }
  if (e.type == DioExceptionType.badCertificate) {
    return '证书校验失败';
  }
  final status = e.response?.statusCode;
  if (status != null) {
    final data = e.response?.data;
    final message = data is Map ? data['message'] : null;
    return '服务器错误 ($status)${message is String && message.isNotEmpty ? '：$message' : ''}';
  }
  return e.message ?? '网络错误';
}
