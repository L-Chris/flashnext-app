// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Deck _$DeckFromJson(Map<String, dynamic> json) => _Deck(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  createdAt: json['createdAt'] as String? ?? '',
  dueCount: (json['dueCount'] as num?)?.toInt() ?? 0,
  counts: json['counts'] == null
      ? const QueueCounts()
      : QueueCounts.fromJson(json['counts'] as Map<String, dynamic>),
  usage: json['usage'] == null
      ? const Usage()
      : Usage.fromJson(json['usage'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DeckToJson(_Deck instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'createdAt': instance.createdAt,
  'dueCount': instance.dueCount,
  'counts': instance.counts,
  'usage': instance.usage,
};
