import 'dart:convert';
import 'dart:io';

import 'package:flashnext_app/models/deck.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> loadFixture(String name) {
  final raw = File('test/fixtures/$name').readAsStringSync();
  final body = jsonDecode(raw) as Map<String, dynamic>;
  return body['data'] as Map<String, dynamic>;
}

List<dynamic> loadFixtureList(String name) {
  final raw = File('test/fixtures/$name').readAsStringSync();
  final body = jsonDecode(raw) as Map<String, dynamic>;
  return body['data'] as List<dynamic>;
}

void main() {
  test('Deck parses live payload', () {
    final list = loadFixtureList('decks.json');
    final deck = Deck.fromJson(list.first as Map<String, dynamic>);
    expect(deck.id, greaterThan(0));
    expect(deck.name, isNotEmpty);
    expect(deck.dueCount, greaterThanOrEqualTo(0));
    expect(deck.counts.review, greaterThanOrEqualTo(0));
    expect(deck.usage.reviewLimit, greaterThan(0));
  });

  test('DueQueue parses live payload', () {
    final data = loadFixture('due.json');
    final queue = DueQueue.fromJson(data);
    expect(queue.cards, isNotEmpty);
    final card = queue.cards.first;
    expect(card.front, isNotEmpty);
    expect(card.back, isNotEmpty);
    expect(card.word, isNotNull);
    expect(card.word!.tags, isNotEmpty);
    expect(queue.counts.review + queue.counts.intraday + queue.counts.fresh,
        greaterThanOrEqualTo(0));
  });

  test('Card list parses live payload', () {
    final list = loadFixtureList('cards.json');
    expect(list, isNotEmpty);
    final card = Card.fromJson(list.first as Map<String, dynamic>);
    expect(card.state, inInclusiveRange(0, 3));
    expect(card.stability, greaterThanOrEqualTo(0));
  });
}
