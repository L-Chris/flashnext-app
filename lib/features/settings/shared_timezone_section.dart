import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';

class SharedTimezoneSection extends ConsumerStatefulWidget {
  const SharedTimezoneSection({required this.api, super.key});
  final ApiClient api;
  @override
  ConsumerState<SharedTimezoneSection> createState() =>
      _SharedTimezoneSectionState();
}

class _SharedTimezoneSectionState extends ConsumerState<SharedTimezoneSection> {
  final _controller = TextEditingController();
  String? _saved, _error;
  bool _loading = true, _saving = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _message(Object error) =>
      error is DioException ? describeDioError(error) : '$error';

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final timezone = await widget.api.sharedTimezone();
      if (!mounted || generation != _generation) return;
      _saved = timezone;
      _controller.text = timezone;
    } catch (error) {
      if (mounted && generation == _generation) _error = _message(error);
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    final draft = _controller.text.trim();
    if (_saving || draft == _saved) return;
    if (draft.isEmpty) {
      setState(() => _error = '请输入时区');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final timezone = await widget.api.saveSharedTimezone(draft);
      if (!mounted) return;
      _saved = timezone;
      _controller.text = timezone;
      ref.invalidate(deckSettingsProvider);
      ref.invalidate(decksProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('时区已保存')));
    } catch (error) {
      if (mounted) _error = _message(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _generation++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('学习时区', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      if (_loading)
        const LinearProgressIndicator()
      else if (_saved == null)
        TextButton(onPressed: _load, child: const Text('重试加载时区'))
      else ...[
        TextField(
          controller: _controller,
          enabled: !_saving,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'IANA 时区',
            helperText: '所有牌组共用，例如 Asia/Shanghai 或 UTC',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saving || _controller.text.trim() == _saved
              ? null
              : _save,
          child: Text(_saving ? '保存中…' : '保存时区'),
        ),
      ],
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ],
  );
}
