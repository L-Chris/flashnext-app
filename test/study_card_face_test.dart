import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/core/network/api_client.dart';
import 'package:flashnext_app/features/review/study_card_face.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flashnext_app/models/study.dart';

class FailedPreviewApi extends ApiClient {
  FailedPreviewApi() : super('https://mock.test');
  int calls = 0;
  @override
  Future<ContentPreview> preview(Card card, {CancelToken? cancelToken}) async {
    calls++;
    return const ContentPreview(
      front: RenderedSide(
        errors: [ContentDiagnostic(message: 'invalid formula')],
      ),
      back: RenderedSide(),
      valid: false,
    );
  }
}

void main() {
  testWidgets(
    'manual answer after render failure is immediate and does not re-request',
    (tester) async {
      final api = FailedPreviewApi();
      addTearDown(api.dispose);
      final readiness = <bool>[];
      Widget face(bool back) => MaterialApp(
        home: Scaffold(
          body: StudyCardFace(
            api: api,
            card: const Card(
              contentFormat: 'markdown_math',
              front: r'\(x\)',
              back: r'$$answer$$',
            ),
            visit: 'one',
            revealed: back,
            onReady: (_, _, {bool automaticAllowed = true}) =>
                readiness.add(automaticAllowed),
            onUnavailable: (_) {},
          ),
        ),
      );
      await tester.pumpWidget(face(false));
      await tester.pumpAndSettle();
      expect(api.calls, 1);
      expect(find.text('重试公式渲染'), findsOneWidget);
      await tester.pumpWidget(face(true));
      await tester.pumpAndSettle();
      expect(find.text(r'$$answer$$'), findsOneWidget);
      expect(api.calls, 1);
      expect(readiness, everyElement(isFalse));
      await tester.tap(find.text('重试公式渲染'));
      await tester.pumpAndSettle();
      expect(api.calls, 2);
    },
  );
}
