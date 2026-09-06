import 'package:freezed_annotation/freezed_annotation.dart';

import 'due_queue.dart';

part 'deck.freezed.dart';
part 'deck.g.dart';

@freezed
sealed class Deck with _$Deck {
  const factory Deck({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String description,
    @Default('') String createdAt,
    @Default(0) int dueCount,
    @Default(QueueCounts()) QueueCounts counts,
    @Default(Usage()) Usage usage,
  }) = _Deck;

  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);
}
