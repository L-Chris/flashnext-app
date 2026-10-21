import 'package:flashnext_app/core/word_pronunciations.dart';
import 'package:flashnext_app/models/study.dart';
import 'package:flutter_test/flutter_test.dart';

WordPronunciation pronunciation(
  String ipa,
  String pos,
  String usage, {
  String accent = 'UK',
  String status = 'accepted',
}) => WordPronunciation(
  displayIpa: ipa,
  pos: pos,
  usage: usage,
  accent: accent,
  status: status,
);

void main() {
  final primate = [
    pronunciation('ˈpraɪmeɪt', 'noun', '灵长目动物'),
    pronunciation('ˈpraɪmət', 'noun', '首席主教、大主教'),
  ];

  test('same POS with different meanings keeps its own pronunciation', () {
    final result = presentPronunciations(primate);
    expect(result.showLabels, isTrue);
    expect(result.groups.map((g) => g.labels), [
      ['n. 灵长目动物'],
      ['n. 首席主教、大主教'],
    ]);
    expect(result.groups.map((g) => g.ipas), [
      ['/ˈpraɪmeɪt/'],
      ['/ˈpraɪmət/'],
    ]);
  });

  test('shared sound keeps every POS and tense associated with that sound', () {
    final result = presentPronunciations([
      pronunciation('riːd', 'verb', '原形／现在时：读'),
      pronunciation('red', 'verb', '过去式／过去分词：读'),
      pronunciation('riːd', 'noun', '阅读'),
    ]);
    expect(result.groups, hasLength(2));
    expect(result.groups[0].labels, ['n. 阅读', 'v. 原形／现在时：读']);
    expect(result.groups[1].labels, ['v. 过去式／过去分词：读']);
  });

  test(
    'alternatives deduplicate, prefer the default, and exclude candidates',
    () {
      final result = presentPronunciations([
        pronunciation('ˈfʌŋɡiː', 'noun', 'fungus 的复数：真菌'),
        pronunciation('ˈfʌndʒaɪ', 'noun', 'fungus 的复数：真菌'),
        pronunciation('/ˈfʌndʒaɪ/', 'noun', 'fungus 的复数：真菌'),
        pronunciation('ˈfʌŋɡaɪ', 'noun', 'fungus 的复数：真菌'),
        pronunciation('WRONG', 'noun', '错误', status: 'review'),
        pronunciation('  ', 'noun', '空读音'),
      ], fallback: '/ˈfʌndʒaɪ/');
      expect(result.groups, hasLength(1));
      expect(result.groups.single.ipas, [
        '/ˈfʌndʒaɪ/',
        '/ˈfʌŋɡiː/',
        '/ˈfʌŋɡaɪ/',
      ]);
      expect(result.groups.single.labels, ['n. fungus 的复数：真菌']);
      expect(result.showLabels, isTrue);
    },
  );

  test('accents remain separate and UK/US are labelled correctly', () {
    final result = presentPronunciations([
      pronunciation('test', 'noun', '名词读法'),
      pronunciation('test', 'noun', '名词读法', accent: 'US'),
    ]);
    expect(result.groups.map((g) => g.accentLabel), ['英', '美']);
    expect(result.groups.map((g) => g.labels), [
      ['n.'],
      ['n.'],
    ]);
  });

  test('single sound is concise; etymology boilerplate is removed', () {
    final result = presentPronunciations([
      pronunciation('ˈtiːtʃə(r)', 'noun', '词源 1 · 教师'),
    ]);
    expect(result.showLabels, isFalse);
    expect(result.groups.single.labels, ['n. 教师']);
  });

  test(
    'phonetic formatting preserves narrow notation and internal slashes',
    () {
      expect(formatPhonetic(' [tʰest] '), '[tʰest]');
      expect(formatPhonetic('/t/est/'), '/t/est/');
      expect(formatPhonetic('ˈtiːtʃə(r)'), '/ˈtiːtʃə(r)/');
      expect(formatPhonetic('  '), '');
    },
  );

  test(
    'hide meanings only when every POS and exact Chinese gloss is covered',
    () {
      expect(pronunciationNotesCoverMeanings('n. 大主教, 灵长目动物', primate), isTrue);
      expect(pronunciationNotesCoverMeanings('n. 大主教， 灵长目动物', primate), isTrue);
      expect(
        pronunciationNotesCoverMeanings('n. 大主教; 灵长目动物\nv. 读', [
          ...primate,
          pronunciation('riːd', 'verb', '原形／现在时：读'),
        ]),
        isTrue,
      );
    },
  );

  test(
    'extra glosses, unknown/mismatched POS and unstructured notes are kept',
    () {
      for (final meanings in [
        'n. 大主教, 灵长目动物, 补充义项',
        'v. 大主教, 灵长目动物',
        'a. 大主教, 灵长目动物',
        '我的笔记',
        'n. 大主教, 灵长目动物\n补充说明',
        '',
      ]) {
        expect(
          pronunciationNotesCoverMeanings(meanings, primate),
          isFalse,
          reason: meanings,
        );
      }
    },
  );

  test(
    'one sound, generic POS notes and rejected candidates cannot hide meanings',
    () {
      expect(
        pronunciationNotesCoverMeanings('n. 灵长目动物', [primate.first]),
        isFalse,
      );
      expect(
        pronunciationNotesCoverMeanings('n. 大主教, 灵长目动物', [
          primate.first,
          primate.last.copyWith(status: 'review'),
        ]),
        isFalse,
      );
      expect(
        pronunciationNotesCoverMeanings('n. 大主教, 灵长目动物', [
          for (final p in primate) p.copyWith(usage: '名词读法'),
        ]),
        isFalse,
      );
      expect(
        pronunciationNotesCoverMeanings('n. animal', [
          for (final p in primate) p.copyWith(usage: 'animal'),
        ]),
        isFalse,
      );
    },
  );
}
