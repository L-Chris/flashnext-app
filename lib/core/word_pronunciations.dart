import 'dart:convert';

import '../models/study.dart';

String formatPhonetic(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';
  if (text.startsWith('[') && text.endsWith(']')) return text;
  return '/${text.replaceAll(RegExp(r'^/+|/+$'), '')}/';
}

const _posLabels = {
  'noun': 'n.',
  'verb': 'v.',
  'adj': 'adj.',
  'adv': 'adv.',
  'prep': 'prep.',
  'name': '专名',
  'pron': 'pron.',
  'intj': 'int.',
  'conj': 'conj.',
  'det': 'det.',
  'num': '数词',
  'particle': '小品词',
  'phrase': '短语',
  'postp': '后置词',
  'prep_phrase': '介词短语',
};
final _etymology = RegExp(r'^词源 .*? · ');
final _genericUsage = RegExp(r'^(?:名词|动词|形容词|副词|介词|代词|感叹词|连词|限定词|数词|专名)读法$');

String _usageLabel(WordPronunciation item) {
  final usage = item.usage.replaceFirst(_etymology, '').trim();
  return [
    _posLabels[item.pos] ?? item.pos,
    if (!_genericUsage.hasMatch(usage)) usage,
  ].where((value) => value.isNotEmpty).join(' ');
}

class PronunciationGroup {
  PronunciationGroup({
    required this.accent,
    required this.ipas,
    required this.labels,
  });

  final String accent;
  final List<String> ipas;
  final List<String> labels;

  String get accentLabel => switch (accent.toUpperCase()) {
    'UK' => '英',
    'US' => '美',
    _ => accent,
  };
}

class PronunciationPresentation {
  const PronunciationPresentation({
    required this.groups,
    required this.showLabels,
  });
  final List<PronunciationGroup> groups;
  final bool showLabels;
}

/// Mirrors Web Pronunciations: first merge identical sounds, then alternatives
/// with identical complete usage labels. Never merge accents or just by POS.
PronunciationPresentation presentPronunciations(
  Iterable<WordPronunciation> items, {
  String fallback = '',
}) {
  final sounds = <(String, String), Set<String>>{};
  for (final item in items) {
    if (item.status != 'accepted' || item.displayIpa.trim().isEmpty) continue;
    final key = (item.accent, formatPhonetic(item.displayIpa));
    sounds.putIfAbsent(key, () => {}).add(_usageLabel(item));
  }
  final preferred = formatPhonetic(fallback);
  final ordered = [
    ...sounds.entries.where((entry) => entry.key.$2 == preferred),
    ...sounds.entries.where((entry) => entry.key.$2 != preferred),
  ];
  final groups = <String, PronunciationGroup>{};
  for (final entry in ordered) {
    final labels = entry.value.where((value) => value.isNotEmpty).toList()
      ..sort();
    final key = jsonEncode([entry.key.$1, labels]);
    final group = groups.putIfAbsent(
      key,
      () => PronunciationGroup(accent: entry.key.$1, ipas: [], labels: labels),
    );
    group.ipas.add(entry.key.$2);
  }
  return PronunciationPresentation(
    groups: groups.values.toList(),
    showLabels: sounds.length > 1,
  );
}

/// Conservative de-duplication: unknown POS, missing/extra meanings, generic
/// labels and a single sound all retain the original translation.
bool pronunciationNotesCoverMeanings(
  String meanings,
  Iterable<WordPronunciation> items,
) {
  final accepted = items
      .where((p) => p.status == 'accepted' && p.displayIpa.trim().isNotEmpty)
      .toList();
  final sounds = {
    for (final p in accepted) (p.accent, formatPhonetic(p.displayIpa)),
  };
  if (sounds.length < 2 || meanings.trim().isEmpty) return false;
  const posNames = {
    'n': 'noun',
    'v': 'verb',
    'adj': 'adj',
    'adv': 'adv',
    'prep': 'prep',
    'pron': 'pron',
    'conj': 'conj',
    'det': 'det',
    'int': 'intj',
    'num': 'num',
  };
  final separators = RegExp(r'[,，、;；]');
  final whitespace = RegExp(r'\s+');
  // Exact matching is deliberately conservative for uncommon compatibility
  // characters: an uncertain match keeps the original meaning visible.
  Iterable<String> terms(String text) => text
      .split(separators)
      .map((term) => term.replaceAll(whitespace, ''))
      .where((term) => term.isNotEmpty);
  final han = RegExp(
    r'[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\u{20000}-\u{323af}]',
    unicode: true,
  );
  final covered = <String, Set<String>>{};
  for (final item in accepted) {
    final usage = item.usage
        .replaceFirst(_etymology, '')
        .replaceFirst(RegExp(r'^.*[：:]'), '');
    covered
        .putIfAbsent(item.pos, () => {})
        .addAll(terms(usage).where(han.hasMatch));
  }
  final linePattern = RegExp(r'^([a-z]+)\.\s*(.+)$');
  return meanings.split('\n').where((line) => line.trim().isNotEmpty).every((
    line,
  ) {
    final match = linePattern.firstMatch(line.trim());
    if (match == null) return false;
    final pos = posNames[match[1]];
    final glosses = terms(match[2]!).toList();
    return pos != null &&
        glosses.isNotEmpty &&
        glosses.every((gloss) => covered[pos]?.contains(gloss) ?? false);
  });
}
