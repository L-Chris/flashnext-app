import 'package:freezed_annotation/freezed_annotation.dart';

part 'due_queue.freezed.dart';
part 'due_queue.g.dart';

@freezed
sealed class QueueCounts with _$QueueCounts {
  const factory QueueCounts({
    @Default(0) int intraday,
    @Default(0) int review,
    @Default(0) int fresh,
    @Default(0) int queued,
    @Default(0) int hiddenByLimit,
  }) = _QueueCounts;

  factory QueueCounts.fromJson(Map<String, dynamic> json) => _$QueueCountsFromJson(json);
}

@freezed
sealed class Usage with _$Usage {
  const factory Usage({
    @Default(0) int newCount,
    @Default(0) int reviewCount,
    @Default(0) int newLimit,
    @Default(0) int reviewLimit,
    @Default(0) int newRemaining,
    @Default(0) int reviewRemaining,
  }) = _Usage;

  factory Usage.fromJson(Map<String, dynamic> json) => _$UsageFromJson(json);
}

@freezed
sealed class DueQueue with _$DueQueue {
  const factory DueQueue({
    @Default(<Card>[]) List<Card> cards,
    @Default(Usage()) Usage usage,
    @Default(QueueCounts()) QueueCounts counts,
  }) = _DueQueue;

  factory DueQueue.fromJson(Map<String, dynamic> json) => _$DueQueueFromJson(json);
}

@freezed
sealed class WordTag with _$WordTag {
  const factory WordTag({
    @Default(0) int id,
    @Default(0) int wordId,
    @Default('') String scheme,
    @Default(0) int level,
    @Default('') String label,
  }) = _WordTag;

  factory WordTag.fromJson(Map<String, dynamic> json) => _$WordTagFromJson(json);
}

@freezed
sealed class WordBrief with _$WordBrief {
  const factory WordBrief({
    @Default(0) int id,
    @Default('') String headword,
    int? rank,
    @Default('') String pos,
    @Default('') String phonetic,
    @Default('') String translation,
    @Default(<WordTag>[]) List<WordTag> tags,
  }) = _WordBrief;

  factory WordBrief.fromJson(Map<String, dynamic> json) => _$WordBriefFromJson(json);
}

@freezed
sealed class Card with _$Card {
  const factory Card({
    @Default(0) int id,
    @Default(0) int deckId,
    int? wordId,
    @Default('') String front,
    @Default('') String back,
    @Default(0) double stability,
    @Default(0) double difficulty,
    @Default(0) int state,
    @Default(0) int reps,
    @Default(0) int lapses,
    @Default(0) int learningSteps,
    @Default(0) int interval,
    @Default('') String due,
    String? lastReview,
    @Default('') String createdAt,
    WordBrief? word,
  }) = _Card;

  factory Card.fromJson(Map<String, dynamic> json) => _$CardFromJson(json);
}
