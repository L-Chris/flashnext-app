import 'package:flashnext_app/features/review/plain_card_face.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flashnext_app/models/study.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';

WordPronunciation sound(String ipa, String pos, String usage) =>
    WordPronunciation(
      displayIpa: ipa,
      pos: pos,
      usage: usage,
      accent: 'UK',
      status: 'accepted',
    );

Card englishCard({String translation = 'n. 大主教, 灵长目动物'}) => Card(
  front: 'primate',
  back: '/ˈpraɪmeɪt/\n$translation',
  word: WordBrief(
    phonetic: 'ˈpraɪmeɪt',
    translation: translation,
    pronunciations: [
      sound('ˈpraɪmeɪt', 'noun', '灵长目动物'),
      sound('ˈpraɪmət', 'noun', '首席主教、大主教'),
    ],
  ),
);

Future<void> show(
  WidgetTester tester,
  Card card, {
  bool revealed = true,
  double scale = 1,
}) => tester.pumpWidget(
  MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 844),
        textScaler: TextScaler.linear(scale),
      ),
      child: Scaffold(
        body: PlainCardFace(card: card, revealed: revealed),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'both meanings and sounds are visible without expanding; duplicate translation hidden',
    (tester) async {
      await show(tester, englishCard());
      expect(find.text('n. 灵长目动物'), findsOneWidget);
      expect(find.text('n. 首席主教、大主教'), findsOneWidget);
      expect(
        find.textContaining('/ˈpraɪmət/', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('n. 大主教, 灵长目动物'), findsNothing);
      expect(find.byType(ExpansionTile), findsNothing);
    },
  );

  testWidgets(
    'uncovered translation is retained and question side leaks no answer',
    (tester) async {
      final card = englishCard(translation: 'n. 大主教, 灵长目动物, 补充义项');
      await show(tester, card);
      expect(find.text('n. 大主教, 灵长目动物, 补充义项'), findsOneWidget);
      await show(tester, card, revealed: false);
      expect(find.text('primate'), findsOneWidget);
      expect(find.textContaining('灵长目动物'), findsNothing);
      expect(
        find.textContaining('/ˈpraɪmət/', findRichText: true),
        findsNothing,
      );
    },
  );

  testWidgets(
    'custom back stays literal without inserting dictionary pronunciations',
    (tester) async {
      await show(tester, englishCard().copyWith(back: '/[riːd]/\n我的笔记'));
      expect(find.text('/[riːd]/\n我的笔记'), findsOneWidget);
      expect(find.text('n. 首席主教、大主教'), findsNothing);
    },
  );

  testWidgets('Japanese kana and meaning survive omitted romaji', (
    tester,
  ) async {
    final card = Card.fromJson({
      'front': '学生',
      'back': 'がくせい\n名词\n学生',
      'word': {
        'language': 'ja',
        'reading': 'がくせい',
        'pos': '名词',
        'translation': '学生',
      },
    });
    await show(tester, card);
    expect(find.text('がくせい'), findsOneWidget);
    expect(find.text('学生'), findsNWidgets(2));
    expect(find.text('罗马音'), findsNothing);
  });

  testWidgets('variants, usage notes and large text fit a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final card = englishCard().copyWith(
      word: englishCard().word!.copyWith(
        pronunciations: [
          sound('ˈfʌndʒaɪ', 'noun', 'fungus 的复数：真菌'),
          sound('ˈfʌŋɡiː', 'noun', 'fungus 的复数：真菌'),
          sound('ˈfʌŋɡaɪ', 'noun', 'fungus 的复数：真菌'),
        ],
      ),
    );
    await show(tester, card, scale: 2);
    await tester.pumpAndSettle();
    expect(find.text('n. fungus 的复数：真菌'), findsOneWidget);
    expect(find.textContaining(' 或 ', findRichText: true), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
