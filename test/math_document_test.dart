import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/features/review/study_card_face.dart';
import 'package:flashnext_app/models/study.dart';

void main() {
  const preview = ContentPreview(
    front: RenderedSide(html: '<math>front</math>'),
    back: RenderedSide(html: '<math>back</math>'),
    valid: true,
  );
  test(
    'controlled document uses current server CSS, dark colors and scaling',
    () {
      final html = mathDocument(
        server: 'https://study.test',
        preview: preview,
        revealed: false,
        dark: true,
        fontSize: 27,
        nonce: 'testNonce1234567890',
      );
      expect(
        html,
        contains('https://study.test/api/content/assets/katex.min.css'),
      );
      expect(html, contains("script-src 'nonce-testNonce1234567890'"));
      expect(html, contains('<script nonce="testNonce1234567890">'));
      expect(html, contains('await document.fonts.ready'));
      expect(html, contains('font.status === \'error\''));
      expect(html, isNot(contains("script-src 'unsafe-inline'")));
      expect(html, contains('font-size:27.0px'));
      expect(html, contains('overflow-x:auto'));
      expect(html, isNot(contains('back</math>')));
    },
  );
  test('answer document contains both already-rendered sides', () {
    final html = mathDocument(
      server: 'https://study.test',
      preview: preview,
      revealed: true,
      dark: false,
      fontSize: 18,
      nonce: 'testNonce1234567890',
    );
    expect(html, contains('<math>front</math><hr><math>back</math>'));
  });
  test('external renderer resources are rejected', () {
    expect(
      () => mathDocument(
        server: 'https://study.test',
        preview: preview.copyWith(
          renderer: const ContentRenderer(
            cssUrl: 'https://elsewhere.test/a.css',
          ),
        ),
        revealed: false,
        dark: false,
        fontSize: 18,
        nonce: 'testNonce1234567890',
      ),
      throwsFormatException,
    );
  });
}
