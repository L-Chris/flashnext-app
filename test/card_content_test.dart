import 'package:flashnext_app/core/card_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses phonetic + pos-aligned meanings', () {
    final content = CardContent.parse('/ˈwɔtɚ/\nn. 水, 雨水\nvt. 给...浇水\nvi. 流泪');
    expect(content.phonetic, '/ˈwɔtɚ/');
    expect(content.meanings.length, 3);
    expect(content.meanings[0].pos, 'n.');
    expect(content.meanings[0].text, '水, 雨水');
    expect(content.meanings[1].pos, 'vt.');
    expect(content.meanings[2].pos, 'vi.');
  });

  test('handles back without phonetic and continuation lines', () {
    final content = CardContent.parse('n. 人口统计\n补充说明');
    expect(content.phonetic, isNull);
    expect(content.meanings.length, 2);
    expect(content.meanings[0].pos, 'n.');
    expect(content.meanings[1].pos, isNull);
    expect(content.meanings[1].text, '补充说明');
  });
}
