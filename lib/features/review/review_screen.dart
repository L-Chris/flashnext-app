import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/card_content.dart';
import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../models/due_queue.dart';

const _ratings = [
  (rating: 1, label: '忘记', color: Color(0xFFDC2626)),
  (rating: 2, label: '困难', color: Color(0xFFD97706)),
  (rating: 3, label: '良好', color: Color(0xFF059669)),
  (rating: 4, label: '简单', color: Color(0xFF0284C7)),
];

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({required this.deckId, required this.deckName, super.key});

  final int deckId;
  final String deckName;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<Card>? _queue;
  bool _revealed = false;
  bool _busy = false;
  bool _done = false;
  String? _error;
  int? _lastRatedCardId;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      final queue = await ref.read(apiClientProvider).due(widget.deckId);
      if (!mounted) return;
      setState(() {
        _queue = queue.cards;
        _done = queue.cards.isEmpty;
        _revealed = false;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is DioException ? describeDioError(e) : '$e';
        _busy = false;
      });
    }
  }

  void _reveal() {
    setState(() => _revealed = true);
    _stopwatch
      ..reset()
      ..start();
  }

  Future<void> _rate(int rating) async {
    final queue = _queue;
    if (queue == null || queue.isEmpty || _busy) return;
    final card = queue.first;
    _stopwatch.stop();
    setState(() => _busy = true);
    try {
      await ref
          .read(apiClientProvider)
          .review(card.id, rating, durationMs: _stopwatch.elapsedMilliseconds);
      _lastRatedCardId = card.id;
      if (!mounted) return;
      setState(() {
        _queue = queue.skip(1).toList();
        _revealed = false;
        _busy = false;
      });
      if (_queue!.isEmpty) await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评分失败：${e is DioException ? describeDioError(e) : e}')),
      );
    }
  }

  Future<void> _undo() async {
    final id = _lastRatedCardId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(apiClientProvider).undo(id);
      _lastRatedCardId = null;
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('撤销失败：${e is DioException ? describeDioError(e) : e}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queue = _queue;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          if (_lastRatedCardId != null)
            IconButton(tooltip: '撤销上一次', onPressed: _busy ? null : _undo, icon: const Icon(Icons.undo)),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('重试')),
                  ],
                ),
              ),
            )
          : _done
              ? const Center(child: Text('太棒了！当前没有需要复习的卡片'))
              : queue == null || queue.isEmpty
                  ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 260),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: GestureDetector(
                            onTap: _revealed ? null : _reveal,
                            child: Center(child: _CardFace(card: queue.first, revealed: _revealed)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!_revealed)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _busy ? null : _reveal,
                        child: const Text('显示答案'),
                      ),
                    )
                  else
                    Row(
                      children: [
                        for (final r in _ratings)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: r.color,
                                  disabledBackgroundColor: r.color.withValues(alpha: 0.5),
                                ),
                                onPressed: _busy ? null : () => _rate(r.rating),
                                child: Text(r.label),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.card, required this.revealed});

  final Card card;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = CardContent.parse(card.back);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(card.front, style: theme.textTheme.headlineMedium),
          if (revealed) ...[
            if (content.phonetic != null) ...[
              const SizedBox(height: 16),
              Text(content.phonetic!, style: theme.textTheme.titleMedium),
            ],
            const SizedBox(height: 20),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.top,
              children: [
                for (final m in content.meanings)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12, bottom: 4),
                        child: Text(m.pos ?? '', style: theme.textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(m.text, style: theme.textTheme.bodyLarge),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
