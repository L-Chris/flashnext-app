import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/deck.dart';
import '../../models/due_queue.dart';

class ApiClient {
  ApiClient(this.baseUrl)
      : _dio = Dio(
          BaseOptions(
            baseUrl: '$baseUrl/api',
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 20),
          ),
        ) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(requestBody: true, error: true));
    }
  }

  final String baseUrl;
  final Dio _dio;

  static bool _isNetworkFlake(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout;

  Future<Response<dynamic>> _get(String path) async {
    var attempt = 0;
    while (true) {
      try {
        return await _dio.get(path);
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
    if (body is Map<String, dynamic> && body.containsKey('data')) return body['data'];
    throw ApiException('unexpected response shape');
  }

  Future<List<Deck>> decks() async {
    final data = _unwrap(await _get('/decks'));
    return (data as List).map((e) => Deck.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DueQueue> due(int deckId) async {
    final data = _unwrap(await _get('/decks/$deckId/cards/due'));
    return DueQueue.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Card>> cards(int deckId) async {
    final data = _unwrap(await _get('/decks/$deckId/cards'));
    return (data as List).map((e) => Card.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Card> review(int cardId, int rating, {int durationMs = 0}) async {
    final data = await _unwrap(
      await _dio.post(
        '/cards/$cardId/review',
        data: {'rating': rating, 'durationMs': durationMs},
      ),
    );
    return Card.fromJson(data as Map<String, dynamic>);
  }

  Future<Card> undo(int cardId) async {
    final data = await _unwrap(await _dio.post('/cards/$cardId/undo'));
    return Card.fromJson(data as Map<String, dynamic>);
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
  if (status != null) return '服务器错误 ($status)';
  return e.message ?? '网络错误';
}
