import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../models/study.dart';
import 'fsrs_panel.dart';

Future<void> showDeckSettings(BuildContext context, int deckId, String name) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) => GestureDetector(
        key: const ValueKey('deck-settings-panel'),
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: DeckSettingsSheet(deckId: deckId, name: name),
      ),
    );

class DeckSettingsSheet extends ConsumerStatefulWidget {
  const DeckSettingsSheet({
    required this.deckId,
    required this.name,
    super.key,
  });
  final int deckId;
  final String name;
  @override
  ConsumerState<DeckSettingsSheet> createState() => _DeckSettingsSheetState();
}

class _DeckSettingsSheetState extends ConsumerState<DeckSettingsSheet> {
  final _form = GlobalKey<FormState>();
  final _new = TextEditingController();
  final _review = TextEditingController();
  final _rollover = TextEditingController();
  final _delay = TextEditingController();
  late final ApiClient _api = ref.read(apiClientProvider);
  late final DeckSettingsKey _key = (
    server: _api.baseUrl,
    deckId: widget.deckId,
  );
  DeckSettings? _saved;
  bool _audio = false, _immediate = false, _timed = false, _saving = false;
  bool _serverChanged = false, _discarding = false;
  String? _error;

  bool get _dirty =>
      _saved != null &&
      !_discarding &&
      !_serverChanged &&
      (_new.text != '${_saved!.newPerDay}' ||
          _review.text != '${_saved!.reviewPerDay}' ||
          _rollover.text != '${_saved!.rolloverHour}' ||
          _audio != _saved!.audioAutoplay ||
          _immediate != _saved!.showNewCardAnswerImmediately ||
          _timed != (_saved!.autoRevealAnswerSeconds != null) ||
          (_timed && _delay.text != '${_saved!.autoRevealAnswerSeconds}'));

  void _populate(DeckSettings settings) {
    _saved = settings;
    _new.text = '${settings.newPerDay}';
    _review.text = '${settings.reviewPerDay}';
    _rollover.text = '${settings.rolloverHour}';
    _delay.text = '${settings.autoRevealAnswerSeconds ?? 10}';
    _audio = settings.audioAutoplay;
    _immediate = settings.showNewCardAnswerImmediately;
    _timed = settings.autoRevealAnswerSeconds != null;
  }

  Future<void> _leave() async {
    if (_saving) return;
    if (_dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('放弃未保存的修改？'),
          content: const Text('返回后，本次修改不会保存。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('继续编辑'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('放弃修改'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
      setState(() => _discarding = true);
      // Let PopScope observe the new canPop value before closing the sheet.
      await WidgetsBinding.instance.endOfFrame;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    if (_saving || _serverChanged || !_form.currentState!.validate()) return;
    final saved = _saved!;
    final draft = saved.copyWith(
      newPerDay: int.parse(_new.text),
      reviewPerDay: int.parse(_review.text),
      rolloverHour: int.parse(_rollover.text),
      audioAutoplay: _audio,
      showNewCardAnswerImmediately: _immediate,
      autoRevealAnswerSeconds: _timed ? int.parse(_delay.text) : null,
    );
    final changes = draft.changesFrom(saved);
    if (changes.isEmpty) {
      setState(() => _populate(saved));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await _api.saveDeckSettings(widget.deckId, changes);
      if (!mounted || _serverChanged) return;
      ref.invalidate(deckSettingsProvider(_key));
      ref.invalidate(decksProvider);
      setState(() => _populate(result));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('牌组设置已保存')));
    } catch (error) {
      if (mounted && !_serverChanged) {
        setState(
          () => _error = error is DioException
              ? describeDioError(error)
              : '$error',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [_new, _review, _rollover, _delay]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(apiClientProvider, (_, api) {
      if (api != _api) setState(() => _serverChanged = true);
    });
    final settings = ref.watch(deckSettingsProvider(_key));
    // Populate once; subsequent refreshes must not erase an unsaved draft.
    if (_saved == null && settings.hasValue) _populate(settings.requireValue);
    return PopScope(
      canPop: !_saving && !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .88,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.name} · 设置',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _serverChanged
                    ? const Center(child: Text('服务器已切换，请返回后重新打开设置。'))
                    : _saved == null
                    ? settings.when(
                        data: (_) => const SizedBox(),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                error is DioException
                                    ? describeDioError(error)
                                    : '$error',
                              ),
                              TextButton(
                                onPressed: () =>
                                    ref.invalidate(deckSettingsProvider(_key)),
                                child: const Text('重试'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Form(
                        key: _form,
                        child: ListView(
                          children: [
                            _integer(_new, '每日新卡额度', 0, 100000),
                            _integer(_review, '每日复习额度', 0, 100000),
                            _integer(_rollover, '日切点（小时）', 0, 23),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('自动播放音频'),
                              value: _audio,
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => _audio = v),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('新卡立即显示答案'),
                              value: _immediate,
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => _immediate = v),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('延迟自动显示答案'),
                              value: _timed,
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => _timed = v),
                            ),
                            if (_timed) _integer(_delay, '自动显示等待秒数', 1, 3600),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            FsrsPanel(api: _api, deckId: widget.deckId),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : _leave,
                    child: const Text('返回'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving || _serverChanged || !_dirty
                        ? null
                        : _save,
                    child: Text(_saving ? '保存中…' : '保存设置'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _integer(
    TextEditingController controller,
    String label,
    int min,
    int max,
  ) => TextFormField(
    controller: controller,
    enabled: !_saving,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(labelText: label),
    onChanged: (_) => setState(() {}),
    validator: (text) {
      final value = int.tryParse(text ?? '');
      return value == null || value < min || value > max
          ? '请输入 $min–$max 的整数'
          : null;
    },
  );
}
