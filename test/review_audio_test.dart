import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flashnext_app/features/review/review_audio.dart';
import 'package:flashnext_app/models/study.dart';

class FakeOutput implements AudioOutput {
  final loaded = Completer<void>();
  int plays = 0, disposals = 0;
  List<Uri> urls = [];
  @override
  Future<void> load(List<Uri> value) async {
    urls = value;
    await loaded.future;
  }

  @override
  Future<void> play() async {
    plays++;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

void main() {
  test('a pending focus release finishes before a new activation', () async {
    final released = Completer<void>();
    final calls = <String>[];
    final output = FakeOutput()..loaded.complete();
    final audio = ReviewAudio(
      server: 'https://a.test',
      activate: () async {
        calls.add('activate');
        return true;
      },
      deactivate: () async {
        calls.add('release');
        await released.future;
      },
      createOutput: () => output,
    );
    addTearDown(audio.dispose);
    final playing = audio.play('a', const [CardMedia(mediaId: 'a', url: '/a')]);
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['release']);
    released.complete();
    await playing;
    expect(calls, ['release', 'activate', 'release']);
  });

  test('media paths resolve against server root without double api', () {
    expect(
      mediaUri('https://a.test', '/api/media/uuid/content').toString(),
      'https://a.test/api/media/uuid/content',
    );
    expect(
      () => mediaUri('https://a.test', 'https://evil.test/a.mp3'),
      throwsFormatException,
    );
  });

  test('late source load from previous side cannot start playback', () async {
    final outputs = <FakeOutput>[];
    final audio = ReviewAudio(
      server: 'https://a.test',
      activate: () async => true,
      createOutput: () {
        final output = FakeOutput();
        outputs.add(output);
        return output;
      },
    );
    addTearDown(audio.dispose);
    final a = audio.play('a', const [CardMedia(mediaId: 'a', url: '/a')]);
    await Future<void>.delayed(Duration.zero);
    final b = audio.play('b', const [
      CardMedia(mediaId: 'b', side: 'back', url: '/b'),
    ]);
    await Future<void>.delayed(Duration.zero);
    outputs[0].loaded.complete();
    await a;
    expect(outputs[0].plays, 0);
    expect(outputs[0].disposals, 1);
    outputs[1].loaded.complete();
    await b;
    expect(outputs[1].plays, 1);
    expect(audio.error, isNull);
  });

  test('load failure exposes retry and no automatic loop', () async {
    final outputs = <FakeOutput>[];
    final audio = ReviewAudio(
      server: 'https://a.test',
      activate: () async => true,
      createOutput: () {
        final output = FakeOutput();
        outputs.add(output);
        return output;
      },
    );
    addTearDown(audio.dispose);
    final pending = audio.play('a', const [CardMedia(mediaId: 'a', url: '/a')]);
    await Future<void>.delayed(Duration.zero);
    outputs.single.loaded.completeError(StateError('404'));
    await pending;
    expect(audio.error, isNotNull);
    expect(outputs.length, 1);
    expect(audio.playing, isFalse);
  });
}
