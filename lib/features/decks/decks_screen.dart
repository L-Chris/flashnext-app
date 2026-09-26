import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/deck.dart';

class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key});

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(decksProvider);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/branding/logo.png', width: 32, height: 32,
                excludeFromSemantics: true),
            const SizedBox(width: 8),
            const Text('FlashNext'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: () => ref.invalidate(decksProvider),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: decks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: '$e', onRetry: () => ref.invalidate(decksProvider)),
        data: (list) => list.isEmpty
            ? const Center(child: Text('还没有牌组'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(decksProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _DeckTile(deck: list[i]),
                ),
              ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Text(deck.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '待复习 ${deck.dueCount} · 日内 ${deck.counts.intraday} · 新卡 ${deck.counts.fresh}',
        ),
        trailing: deck.dueCount > 0
            ? Chip(label: Text('${deck.dueCount}'))
            : const Icon(Icons.check_circle_outline),
        onTap: () => context.push('/review/${deck.id}?name=${Uri.encodeComponent(deck.name)}'),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
