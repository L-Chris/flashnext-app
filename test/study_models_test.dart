import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flashnext_app/models/study.dart';
import 'package:flashnext_app/features/review/plain_card_face.dart';

void main() {
  final cases =
      (jsonDecode(
            File('docs/handoff/fixtures/review-cases.json').readAsStringSync(),
          ) as Map)['cases']
          as List;
  test('handoff queues retain null, zero, UUIDs and options', () {
    final timed = DueQueue.fromJson(cases[0]['response']['data']);
    final immediate = DueQueue.fromJson(cases[1]['response']['data']);
    final manual = DueQueue.fromJson(cases[2]['response']['data']);
    expect(timed.cards.single.presentation.answerRevealAfterMs, 10000);
    expect(immediate.cards.single.presentation.answerRevealAfterMs, 0);
    expect(immediate.cards.single.media.single.mediaId, isA<String>());
    expect(immediate.cards.single.word!.reading, 'がくせい');
    expect(manual.cards.single.presentation.answerRevealAfterMs, isNull);
    expect(manual.reviewOptions.autoRevealAnswerSeconds, isNull);
  });

  test('legacy cards default to manual and no audio', () {
    final card = Card.fromJson({
      'id': 1,
      'front': r'price $5',
      'back': r'\(literal\)',
    });
    expect(card.contentFormat, 'plain');
    expect(card.media, isEmpty);
    expect(card.presentation.answerRevealAfterMs, isNull);
    expect(card.presentation.audioAutoplay, isFalse);
  });

  test('partial setting patches preserve explicit null and zero', () {
    final saved = DeckSettings.fromJson(cases.first['settings']['data']);
    final changed = saved.copyWith(newPerDay: 0, autoRevealAnswerSeconds: null);
    expect(changed.changesFrom(saved), {
      'newPerDay': 0,
      'autoRevealAnswerSeconds': null,
    });
    expect(
      DeckSettings.fromJson(changed.toJson()).autoRevealAnswerSeconds,
      isNull,
    );
    expect(saved.changesFrom(saved), isEmpty);
  });

  test('Japanese generated text and custom notes are distinguished', () {
    final card = DueQueue.fromJson(cases[1]['response']['data']).cards.single;
    expect(generatedWordBack(card), isTrue);
    expect(generatedWordBack(card.copyWith(back: '自定义笔记\nがくせい')), isFalse);
  });

  test(
    'dictionary newline repair is only selected for generated word content',
    () {
      final word = WordBrief(translation: 'n. 一行\n另一行');
      expect(generatedWordBack(Card(word: word, back: r'n. 一行\n另一行')), isTrue);
      expect(generatedWordBack(Card(word: word, back: r'笔记 \(x\)')), isFalse);
      expect(
        generatedWordBack(
          Card(
            word: word,
            contentFormat: 'markdown_math',
            back: word.translation,
          ),
        ),
        isFalse,
      );
    },
  );
}
