import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/study.dart';

Uri mediaUri(String server, String url) {
  final base = Uri.parse(server);
  final uri = base.resolve(url);
  if (!['https', 'http'].contains(uri.scheme) ||
      uri.origin != base.origin ||
      uri.userInfo.isNotEmpty) {
    throw const FormatException('音频地址不属于当前服务器');
  }
  return uri;
}

abstract interface class AudioOutput {
  Future<void> load(List<Uri> urls);
  Future<void> play();
  Future<void> dispose();
}

class _NativeOutput implements AudioOutput {
  final _player = AudioPlayer(handleInterruptions: false);
  @override
  Future<void> load(List<Uri> urls) => _player
      .setAudioSources(urls.map((uri) => AudioSource.uri(uri)).toList())
      .then((_) {});
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> dispose() => _player.dispose();
}

/// A fresh output per playback prevents a late native load from changing a new side.
class ReviewAudio extends ChangeNotifier {
  ReviewAudio({
    required this.server,
    AudioOutput Function()? createOutput,
    Future<bool> Function()? activate,
    Future<void> Function()? deactivate,
  }) : _createOutput = createOutput ?? _NativeOutput.new,
       _activateOverride = activate,
       _deactivateOverride = deactivate;
  final String server;
  final AudioOutput Function() _createOutput;
  final Future<bool> Function()? _activateOverride;
  final Future<void> Function()? _deactivateOverride;
  Future<void> _focusChanges = Future.value();
  AudioOutput? _output;
  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptions;
  StreamSubscription<void>? _noisy;
  int _generation = 0;
  bool _disposed = false;
  bool loading = false, playing = false;
  String? error;

  // Serialize platform focus changes: an old stop must finish before a new play.
  Future<T> _changeFocus<T>(Future<T> Function() action) {
    final next = _focusChanges.then((_) => action());
    _focusChanges = next.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return next;
  }

  Future<bool> _activate() => _changeFocus(_activateNow);

  Future<bool> _activateNow() async {
    if (_disposed) return false;
    if (_activateOverride != null) return _activateOverride();
    if (_session == null) {
      final session = await AudioSession.instance;
      if (_disposed) return false;
      _session = session;
      await session.configure(const AudioSessionConfiguration.speech());
      if (_disposed) return false;
      _interruptions = session.interruptionEventStream.listen((_) => stop());
      _noisy = session.becomingNoisyEventStream.listen((_) => stop());
    }
    return _session!.setActive(true);
  }

  bool _valid(int generation) => !_disposed && generation == _generation;
  Future<void> _release(AudioOutput? output) async {
    if (output == null) return;
    try {
      await output.dispose();
    } catch (_) {
      /* Already released by the platform. */
    }
  }

  Future<void> _deactivate() => _changeFocus(() async {
    try {
      if (_deactivateOverride != null) {
        await _deactivateOverride();
      } else {
        await _session?.setActive(false);
      }
    } catch (_) {
      /* Focus was already released. */
    }
  });

  Future<void> play(String visit, List<CardMedia> items) async {
    if (_disposed || items.isEmpty) return;
    stop();
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final urls = items.map((item) => mediaUri(server, item.url)).toList();
      if (!await _activate()) throw StateError('音频焦点不可用');
      if (!_valid(generation)) return;
      final output = _createOutput();
      _output = output;
      await output.load(urls);
      if (!_valid(generation)) return;
      loading = false;
      playing = true;
      notifyListeners();
      await output.play();
      if (!_valid(generation)) return;
      playing = false;
      _output = null;
      await _release(output);
      if (_valid(generation)) {
        await _deactivate();
        if (_valid(generation)) notifyListeners();
      }
    } catch (_) {
      if (!_valid(generation)) return;
      final output = _output;
      _output = null;
      loading = false;
      playing = false;
      error = '音频播放失败，可点击播放重试。';
      await _release(output);
      if (_valid(generation)) {
        await _deactivate();
        if (_valid(generation)) notifyListeners();
      }
    }
  }

  void stop() {
    _generation++;
    final output = _output;
    _output = null;
    loading = false;
    playing = false;
    error = null;
    unawaited(_release(output));
    unawaited(_deactivate());
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    _interruptions?.cancel();
    _noisy?.cancel();
    super.dispose();
  }
}
