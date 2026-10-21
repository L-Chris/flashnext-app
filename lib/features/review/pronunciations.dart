import 'package:flutter/material.dart';

import '../../core/word_pronunciations.dart';
import '../../models/study.dart';

class Pronunciations extends StatelessWidget {
  const Pronunciations({required this.items, this.fallback = '', super.key});

  final List<WordPronunciation> items;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final presentation = presentPronunciations(items, fallback: fallback);
    final theme = Theme.of(context).textTheme;
    if (presentation.groups.isEmpty) {
      if (fallback.trim().isEmpty) return const SizedBox.shrink();
      return Text(formatPhonetic(fallback), style: theme.titleMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in presentation.groups)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${group.accentLabel} ',
                        style: theme.labelMedium,
                      ),
                      for (var i = 0; i < group.ipas.length; i++) ...[
                        if (i > 0)
                          TextSpan(text: ' 或 ', style: theme.labelMedium),
                        TextSpan(text: group.ipas[i]),
                      ],
                    ],
                  ),
                  style: theme.titleMedium,
                ),
                if (presentation.showLabels && group.labels.isNotEmpty)
                  Text(group.labels.join('；'), style: theme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}
