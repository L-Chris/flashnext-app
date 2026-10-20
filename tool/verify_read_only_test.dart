// Read-only smoke checks. Never calls review/undo/settings POST or FSRS jobs.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/features/review/review_audio.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flashnext_app/models/study.dart';

Future<void> verifyReadOnly() async {
  const server = String.fromEnvironment(
    'STUDY_SERVER',
    defaultValue: 'https://mem.home.rethinkos.com',
  );
  final api = ApiClient(server, logRequests: false);
  final mediaClient = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  final reports = <Map<String, dynamic>>[];
  CardMedia? audio;
  try {
    for (final deck in await api.decks()) {
      final settings = await api.deckSettings(deck.id);
      final before = await api.fsrsParams(deck.id);
      final cards = await api.cards(deck.id);
      final queue = await api.due(deck.id);
      for (final card in cards) {
        if (card.media.isNotEmpty) audio ??= card.media.first;
      }
      final after = await api.fsrsParams(deck.id);
      if (before.reviewCount != after.reviewCount) {
        throw StateError('Concurrent review activity detected');
      }
      reports.add({
        'language': deck.language,
        'settingsVersion': settings.version,
        'parsedCards': cards.length,
        'queued': queue.cards.length,
        'reviewCountUnchanged': true,
        'trainingThreshold': before.minReviews,
      });
    }
    final preview = await api.preview(
      const Card(
        contentFormat: 'markdown_math',
        front: r'价格 $5；\(\frac{1}{2}\)；\[\sqrt{4}\]；`\(code\)`',
        back: r'$$\begin{pmatrix}1&2\\3&4\end{pmatrix}$$',
      ),
    );
    if (!preview.valid) {
      throw StateError(
        'Preview diagnostics: ${preview.front.errors} ${preview.back.errors}',
      );
    }
    final css = await mediaClient.getUri<String>(
      Uri.parse(server).resolve(preview.renderer.cssUrl),
    );
    if (css.statusCode != 200) throw StateError('KaTeX CSS unavailable');
    var rangedAudio = false;
    if (audio != null) {
      final uri = mediaUri(server, audio.url);
      await mediaClient.headUri<dynamic>(uri);
      final range = await mediaClient.getUri<List<int>>(
        uri,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Range': 'bytes=0-31'},
        ),
      );
      rangedAudio = range.statusCode == 206 && range.data?.length == 32;
      if (!rangedAudio) throw StateError('Audio Range request failed');
    }
    debugPrint(
      jsonEncode({
        'decks': reports,
        'mathValid': preview.valid,
        'katexCssLoaded': true,
        'audioRange206': rangedAudio,
        'productionMutations': 0,
      }),
    );
  } finally {
    api.dispose();
    mediaClient.close(force: true);
  }
}

void main() {
  test('read-only live API contract and media smoke check', verifyReadOnly);
}
