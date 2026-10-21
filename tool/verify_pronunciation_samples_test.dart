// Offline UI verification of read-only GET /api/cards/:id sample responses.
// Input is a JSON array; this test never makes network requests or submits scores.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flashnext_app/features/review/plain_card_face.dart';
import 'package:flashnext_app/models/due_queue.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final samples =
      (jsonDecode(
            File(
              const String.fromEnvironment(
                'PRONUNCIATION_SAMPLES',
                defaultValue: 'build/qa/pronunciation-samples.json',
              ),
            ).readAsStringSync(),
          ) as List)
          .map((json) => Card.fromJson(json as Map<String, dynamic>))
          .toList();

  setUpAll(() async {
    // Load real fonts for screenshot inspection instead of Flutter's Ahem font.
    for (final font in {
      'StudyIpa': 'C:/Windows/Fonts/segoeui.ttf',
      'StudyChinese': 'C:/Windows/Fonts/msyh.ttc',
    }.entries) {
      final file = File(font.value);
      if (!file.existsSync()) continue;
      final loader = FontLoader(font.key);
      loader.addFont(
        Future.value(ByteData.sublistView(await file.readAsBytes())),
      );
      await loader.load();
    }
  });

  for (final card in samples) {
    for (final large in [false, true]) {
      final label = '${card.front}-${large ? 'large-dark' : 'phone'}';
      testWidgets('real dictionary sample $label', (tester) async {
        tester.view.physicalSize = Size(large ? 320 : 390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: large ? Brightness.dark : Brightness.light,
              fontFamily: 'StudyIpa',
              fontFamilyFallback: const ['StudyChinese'],
            ),
            home: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(large ? 2 : 1),
              ),
              child: RepaintBoundary(
                key: boundaryKey,
                child: Scaffold(
                  body: PlainCardFace(card: card, revealed: true),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(card.front), findsOneWidget);
        expect(find.byType(ExpansionTile), findsNothing);
        expect(tester.takeException(), isNull);
        if (card.front == 'primate') {
          expect(find.text('n. 灵长目动物'), findsOneWidget);
          expect(find.text('n. 首席主教、大主教'), findsOneWidget);
          expect(find.text('n. 大主教, 灵长目动物'), findsNothing);
        }
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final screenshot = await boundary.toImage();
          try {
            final png = await screenshot.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('build/qa/pronunciations/$label.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(png!.buffer.asUint8List());
          } finally {
            screenshot.dispose();
          }
        });
      });
    }
  }
}
