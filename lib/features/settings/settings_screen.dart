import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _controller = TextEditingController();
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    final state = ref.read(settingsProvider);
    _controller.text = state.baseUrl;
    if (!state.loaded) {
      Future.microtask(() async {
        await ref.read(settingsProvider.notifier).load();
        if (mounted) {
          _controller.text = ref.read(settingsProvider).baseUrl;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(settingsProvider.notifier).save(_controller.text);
    ref.invalidate(decksProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已保存')));
    }
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final client = ApiClient(_controller.text.trim().replaceAll(RegExp(r'/+$'), ''));
      final decks = await client.decks();
      setState(() => _testResult = '连接成功，${decks.length} 个牌组');
    } catch (e) {
      final message = e is DioException ? describeDioError(e) : '$e';
      setState(() => _testResult = '连接失败：$message');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: '服务器地址',
              hintText: kDefaultBaseUrl,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(onPressed: _save, child: const Text('保存')),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _testing ? null : _test,
                child: _testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('测试连接'),
              ),
            ],
          ),
          if (_testResult != null) ...[
            const SizedBox(height: 12),
            Text(_testResult!),
          ],
          const SizedBox(height: 24),
          Text(
            '需处于内网或 Tailscale 网络内才能访问服务器。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
