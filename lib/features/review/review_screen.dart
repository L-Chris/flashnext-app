import 'dart:async';

import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../models/study.dart';
import 'review_audio.dart';
import 'review_session.dart';
import 'study_card_face.dart';

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

class _ReviewScreenState extends ConsumerState<ReviewScreen>
    with WidgetsBindingObserver {
  late ReviewSession _session;
  late ReviewAudio _audio;
  ProviderSubscription<ApiClient>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bind(ref.read(apiClientProvider));
    _subscription = ref.listenManual(apiClientProvider, (_, api) {
      _session.removeListener(_changed);
      _session.dispose();
      _audio.dispose();
      _bind(api);
    });
  }

  void _bind(ApiClient api) {
    final audio = ReviewAudio(server: api.baseUrl);
    _audio = audio;
    _session = ReviewSession(
      api: api,
      deckId: widget.deckId,
      onAutoplay: (visit, media) => unawaited(audio.play(visit, media)),
      onStopAudio: audio.stop,
    );
    final state = WidgetsBinding.instance.lifecycleState;
    _session.setForeground(state == null || state == AppLifecycleState.resumed);
    _session.addListener(_changed);
    unawaited(_session.load());
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _session.setForeground(state == AppLifecycleState.resumed);

  Future<void> _rate(int rating) async {
    await _session.rate(rating);
    if (mounted) ref.invalidate(decksProvider);
  }

  Future<void> _undo() async {
    await _session.undo();
    if (mounted) ref.invalidate(decksProvider);
  }

  @override
  void dispose() {
    _subscription?.close();
    WidgetsBinding.instance.removeObserver(this);
    _session.removeListener(_changed);
    _session.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final card = session.card;
    final queue = session.queue;
    final media = card == null
        ? const <CardMedia>[]
        : mediaForSide(card, session.revealed);
    final remaining = session.remaining;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          IconButton(
            tooltip: '撤销上一次',
            onPressed: session.canUndo ? _undo : null,
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (session.notice != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    session.notice!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (queue != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '新卡剩余 ${queue.usage.newRemaining} · 复习剩余 ${queue.usage.reviewRemaining}'
                    '${queue.counts.hiddenByLimit > 0 ? ' · ${queue.counts.hiddenByLimit} 张已达限额' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (session.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(session.error!, textAlign: TextAlign.center),
                        FilledButton(
                          onPressed: session.busy ? null : session.load,
                          child: const Text('重试加载队列'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (session.done)
                const Expanded(child: Center(child: Text('太棒了！当前没有需要复习的卡片')))
              else if (card == null)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: StudyCardFace(
                      key: ValueKey(session.visit),
                      api: session.api,
                      card: card,
                      visit: session.visit,
                      revealed: session.revealed,
                      onReady: session.contentReady,
                      onUnavailable: session.contentUnavailable,
                    ),
                  ),
                ),
                if (media.isNotEmpty)
                  ListenableBuilder(
                    listenable: _audio,
                    builder: (context, _) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${session.revealed ? '背面' : '正面'}音频 · ${media.length} 个文件',
                              ),
                            ),
                            TextButton.icon(
                              onPressed:
                                  session.busy ||
                                      !session.foreground ||
                                      !session.ready
                                  ? null
                                  : () {
                                      if (_audio.playing || _audio.loading) {
                                        _audio.stop();
                                      } else {
                                        unawaited(
                                          _audio.play(
                                            '${session.visit}:${session.revealed}',
                                            media,
                                          ),
                                        );
                                      }
                                    },
                              icon: Icon(
                                _audio.playing || _audio.loading
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                _audio.loading
                                    ? '加载中（停止）'
                                    : _audio.playing
                                    ? '停止'
                                    : '播放',
                              ),
                            ),
                          ],
                        ),
                        if (_audio.error != null) Text(_audio.error!),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                if (!session.revealed)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: session.busy || !session.foreground
                          ? null
                          : session.reveal,
                      child: Text(
                        remaining == null || !session.counting
                            ? '显示答案'
                            : '显示答案 · ${(remaining.inMilliseconds / 1000).ceil()} 秒',
                      ),
                    ),
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final rating in _ratings)
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: rating.color,
                          ),
                          onPressed: session.canRate
                              ? () => _rate(rating.rating)
                              : null,
                          child: Text(rating.label),
                        ),
                    ],
                  ),
                if (session.busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
