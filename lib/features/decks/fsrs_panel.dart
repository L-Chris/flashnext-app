import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/study.dart';

class FsrsPanel extends StatefulWidget {
  const FsrsPanel({required this.api, required this.deckId, super.key});
  final ApiClient api;
  final int deckId;
  @override
  State<FsrsPanel> createState() => _FsrsPanelState();
}

class _FsrsPanelState extends State<FsrsPanel> with WidgetsBindingObserver {
  FsrsParams? _params;
  OptimizeJob? _job;
  String? _error;
  bool _busy = false;
  bool _foreground = true;
  int _generation = 0;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _poll?.cancel();
    if (_foreground && !_busy) _refresh();
  }

  Future<void> _refresh({bool start = false}) async {
    if (_busy || !_foreground) return;
    final generation = ++_generation;
    _poll?.cancel();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (start) await widget.api.startOptimize(widget.deckId);
      final params = await widget.api.fsrsParams(widget.deckId);
      final job = await widget.api.optimizeStatus(widget.deckId);
      if (!mounted || generation != _generation) return;
      setState(() {
        _params = params;
        _job = job;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(
        () =>
            _error = error is DioException ? describeDioError(error) : '$error',
      );
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
        if (_foreground && _job?.running == true && _error == null) {
          _poll = Timer(const Duration(seconds: 2), _refresh);
        }
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = _params;
    final job = _job;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Text('FSRS 参数与训练', style: Theme.of(context).textTheme.titleMedium),
        if (params != null) ...[
          const SizedBox(height: 8),
          Text('参数来源：${params.source}'),
          Text('更新时间：${params.updatedAt ?? '尚未训练'}'),
          Text('本牌组复习日志：${params.reviewCount} / 训练门槛 ${params.minReviews}'),
          Text('学习日：${params.timezone} · ${params.rolloverHour} 时日切'),
          ExpansionTile(
            title: Text('查看 ${params.w.length} 项参数'),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(params.w.join(', ')),
              ),
            ],
          ),
        ],
        if (job?.running == true) const Text('训练中，服务端任务将继续运行…'),
        if (job?.finishedAt != null) Text('任务结束：${job!.finishedAt}'),
        if (job?.error != null) Text('训练失败：${job!.error}'),
        if (job?.result != null)
          Text(
            job!.result!['saved'] == true
                ? '训练完成，参数已保存。已有卡片日程保持不变。'
                : '训练完成，参数未通过审计或未保存。',
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy ? null : _refresh,
              child: Text(_busy ? '加载中…' : '刷新状态'),
            ),
            FilledButton(
              onPressed:
                  _busy ||
                      job?.running == true ||
                      params == null ||
                      params.reviewCount < params.minReviews
                  ? null
                  : () => _refresh(start: true),
              child: const Text('训练本牌组参数'),
            ),
          ],
        ),
        const Text('训练在服务器执行，不会自动重建已有复习日程。'),
      ],
    );
  }
}
