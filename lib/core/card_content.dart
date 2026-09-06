class MeaningLine {
  const MeaningLine({this.pos, required this.text});
  final String? pos;
  final String text;
}

class CardContent {
  const CardContent({this.phonetic, required this.meanings});
  final String? phonetic;
  final List<MeaningLine> meanings;

  static final RegExp _posRe = RegExp(r'^([a-z&]+\.\s*)(.*)$');

  static CardContent parse(String back) {
    final lines = back.split('\n').where((l) => l.trim().isNotEmpty).toList();
    String? phonetic;
    var start = 0;
    if (lines.isNotEmpty && lines[0].startsWith('/')) {
      phonetic = lines[0];
      start = 1;
    }
    final meanings = <MeaningLine>[];
    for (final line in lines.skip(start)) {
      final m = _posRe.firstMatch(line);
      if (m != null) {
        meanings.add(MeaningLine(pos: m.group(1)!.trim(), text: m.group(2)!));
      } else {
        meanings.add(MeaningLine(text: line));
      }
    }
    return CardContent(phonetic: phonetic, meanings: meanings);
  }
}
