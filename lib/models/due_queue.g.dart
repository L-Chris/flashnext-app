// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'due_queue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QueueCounts _$QueueCountsFromJson(Map<String, dynamic> json) => _QueueCounts(
  intraday: (json['intraday'] as num?)?.toInt() ?? 0,
  review: (json['review'] as num?)?.toInt() ?? 0,
  fresh: (json['fresh'] as num?)?.toInt() ?? 0,
  queued: (json['queued'] as num?)?.toInt() ?? 0,
  hiddenByLimit: (json['hiddenByLimit'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$QueueCountsToJson(_QueueCounts instance) =>
    <String, dynamic>{
      'intraday': instance.intraday,
      'review': instance.review,
      'fresh': instance.fresh,
      'queued': instance.queued,
      'hiddenByLimit': instance.hiddenByLimit,
    };

_Usage _$UsageFromJson(Map<String, dynamic> json) => _Usage(
  newCount: (json['newCount'] as num?)?.toInt() ?? 0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  newLimit: (json['newLimit'] as num?)?.toInt() ?? 0,
  reviewLimit: (json['reviewLimit'] as num?)?.toInt() ?? 0,
  newRemaining: (json['newRemaining'] as num?)?.toInt() ?? 0,
  reviewRemaining: (json['reviewRemaining'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UsageToJson(_Usage instance) => <String, dynamic>{
  'newCount': instance.newCount,
  'reviewCount': instance.reviewCount,
  'newLimit': instance.newLimit,
  'reviewLimit': instance.reviewLimit,
  'newRemaining': instance.newRemaining,
  'reviewRemaining': instance.reviewRemaining,
};

_DueQueue _$DueQueueFromJson(Map<String, dynamic> json) => _DueQueue(
  cards:
      (json['cards'] as List<dynamic>?)
          ?.map((e) => Card.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Card>[],
  usage: json['usage'] == null
      ? const Usage()
      : Usage.fromJson(json['usage'] as Map<String, dynamic>),
  counts: json['counts'] == null
      ? const QueueCounts()
      : QueueCounts.fromJson(json['counts'] as Map<String, dynamic>),
  reviewOptions: json['reviewOptions'] == null
      ? const ReviewOptions()
      : ReviewOptions.fromJson(json['reviewOptions'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DueQueueToJson(_DueQueue instance) => <String, dynamic>{
  'cards': instance.cards,
  'usage': instance.usage,
  'counts': instance.counts,
  'reviewOptions': instance.reviewOptions,
};

_WordTag _$WordTagFromJson(Map<String, dynamic> json) => _WordTag(
  id: (json['id'] as num?)?.toInt() ?? 0,
  wordId: (json['wordId'] as num?)?.toInt() ?? 0,
  scheme: json['scheme'] as String? ?? '',
  level: (json['level'] as num?)?.toInt() ?? 0,
  label: json['label'] as String? ?? '',
);

Map<String, dynamic> _$WordTagToJson(_WordTag instance) => <String, dynamic>{
  'id': instance.id,
  'wordId': instance.wordId,
  'scheme': instance.scheme,
  'level': instance.level,
  'label': instance.label,
};

_WordBrief _$WordBriefFromJson(Map<String, dynamic> json) => _WordBrief(
  id: (json['id'] as num?)?.toInt() ?? 0,
  headword: json['headword'] as String? ?? '',
  language: json['language'] as String? ?? 'en',
  reading: json['reading'] as String? ?? '',
  romaji: json['romaji'] as String? ?? '',
  rank: (json['rank'] as num?)?.toInt(),
  pos: json['pos'] as String? ?? '',
  phonetic: json['phonetic'] as String? ?? '',
  translation: json['translation'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)
          ?.map((e) => WordTag.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WordTag>[],
  pronunciations:
      (json['pronunciations'] as List<dynamic>?)
          ?.map((e) => WordPronunciation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WordPronunciation>[],
  senses:
      (json['senses'] as List<dynamic>?)
          ?.map((e) => WordSense.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <WordSense>[],
);

Map<String, dynamic> _$WordBriefToJson(_WordBrief instance) =>
    <String, dynamic>{
      'id': instance.id,
      'headword': instance.headword,
      'language': instance.language,
      'reading': instance.reading,
      'romaji': instance.romaji,
      'rank': instance.rank,
      'pos': instance.pos,
      'phonetic': instance.phonetic,
      'translation': instance.translation,
      'tags': instance.tags,
      'pronunciations': instance.pronunciations,
      'senses': instance.senses,
    };

_Card _$CardFromJson(Map<String, dynamic> json) => _Card(
  id: (json['id'] as num?)?.toInt() ?? 0,
  deckId: (json['deckId'] as num?)?.toInt() ?? 0,
  wordId: (json['wordId'] as num?)?.toInt(),
  front: json['front'] as String? ?? '',
  back: json['back'] as String? ?? '',
  contentFormat: json['contentFormat'] as String? ?? 'plain',
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => CardMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CardMedia>[],
  presentation: json['presentation'] == null
      ? const CardPresentation()
      : CardPresentation.fromJson(json['presentation'] as Map<String, dynamic>),
  stability: (json['stability'] as num?)?.toDouble() ?? 0,
  difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0,
  state: (json['state'] as num?)?.toInt() ?? 0,
  reps: (json['reps'] as num?)?.toInt() ?? 0,
  lapses: (json['lapses'] as num?)?.toInt() ?? 0,
  learningSteps: (json['learningSteps'] as num?)?.toInt() ?? 0,
  interval: (json['interval'] as num?)?.toInt() ?? 0,
  due: json['due'] as String? ?? '',
  lastReview: json['lastReview'] as String?,
  createdAt: json['createdAt'] as String? ?? '',
  word: json['word'] == null
      ? null
      : WordBrief.fromJson(json['word'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CardToJson(_Card instance) => <String, dynamic>{
  'id': instance.id,
  'deckId': instance.deckId,
  'wordId': instance.wordId,
  'front': instance.front,
  'back': instance.back,
  'contentFormat': instance.contentFormat,
  'media': instance.media,
  'presentation': instance.presentation,
  'stability': instance.stability,
  'difficulty': instance.difficulty,
  'state': instance.state,
  'reps': instance.reps,
  'lapses': instance.lapses,
  'learningSteps': instance.learningSteps,
  'interval': instance.interval,
  'due': instance.due,
  'lastReview': instance.lastReview,
  'createdAt': instance.createdAt,
  'word': instance.word,
};
