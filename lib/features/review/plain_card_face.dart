import 'dart:convert';

import 'package:flutter/material.dart' hide Card;

import '../../core/card_content.dart';
import '../../core/word_pronunciations.dart';
import '../../models/due_queue.dart';
import 'pronunciations.dart';

String normalizeDictionaryNewlines(String text) =>
    text.replaceAll(RegExp(r'\\+r\\+n|\\+[nr]|\r\n?'), '\n');

bool generatedWordBack(Card card) {
  final word = card.word;
  if (card.contentFormat != 'plain' || word == null) return false;
  if (word.language == 'ja') {
    return card.back ==
        [
          word.reading,
          word.pos,
          word.translation,
        ].where((s) => s.isNotEmpty).join('\n');
  }
  final lines = normalizeDictionaryNewlines(card.back).split('\n');
  if (lines.isNotEmpty && RegExp(r'^/[^\n]+/$').hasMatch(lines.first)) {
    lines.removeAt(0);
  }
  return lines.join('\n') == normalizeDictionaryNewlines(word.translation);
}

class PlainCardFace extends StatelessWidget {
  const PlainCardFace({required this.card, required this.revealed, super.key});
  final Card card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final word = card.word;
    final isWord = generatedWordBack(card);
    final japanese = word?.language == 'ja';
    final content = CardContent.parse(normalizeDictionaryNewlines(card.back));
    final hideDuplicateMeanings =
        isWord &&
        !japanese &&
        pronunciationNotesCoverMeanings(
          normalizeDictionaryNewlines(word!.translation),
          word.pronunciations,
        );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            card.front,
            style: theme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (revealed) ...[
            const Divider(height: 40),
            if (!isWord)
              Text(card.back, style: theme.bodyLarge)
            else if (japanese) ...[
              if (word!.reading.isNotEmpty)
                Text(
                  word.reading,
                  style: theme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              if (word.romaji.isNotEmpty)
                ExpansionTile(
                  title: const Text('罗马音'),
                  children: [Text(word.romaji)],
                ),
              Text(word.pos, style: theme.labelLarge),
              const SizedBox(height: 8),
              Text(word.translation, style: theme.bodyLarge),
            ] else ...[
              Pronunciations(
                items: word!.pronunciations,
                fallback: content.phonetic ?? word.phonetic,
              ),
              const SizedBox(height: 16),
              if (!hideDuplicateMeanings)
                for (final meaning in content.meanings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${meaning.pos == null ? '' : '${meaning.pos} '}${meaning.text}',
                      style: theme.bodyLarge,
                    ),
                  ),
            ],
            if (isWord && word != null)
              for (final sense in word.senses)
                ..._sense(
                  context,
                  sense.examples,
                  sense.exampleDetails,
                  sense.zh,
                ),
          ],
        ],
      ),
    );
  }

  List<dynamic> _list(String source) {
    try {
      final value = jsonDecode(source);
      return value is List ? value : [];
    } catch (_) {
      return [];
    }
  }

  List<Widget> _sense(
    BuildContext context,
    String examples,
    String details,
    String zh,
  ) {
    final localized = _list(details).whereType<Map>().take(2);
    final lines = localized.isNotEmpty
        ? localized
              .map(
                (example) => [
                  example['ja'],
                  example['zh'] ?? example['en'],
                ].whereType<String>().join('\n'),
              )
              .toList()
        : _list(examples).whereType<String>().take(2).toList();
    final translations = _list(zh).whereType<String>().join('、');
    return [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(line, style: Theme.of(context).textTheme.bodyMedium),
        ),
      if (lines.isNotEmpty && translations.isNotEmpty) Text('译词：$translations'),
    ];
  }
}
