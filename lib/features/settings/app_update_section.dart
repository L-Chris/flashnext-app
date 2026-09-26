import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/update/app_update_service.dart';

class AppUpdateSection extends StatefulWidget {
  const AppUpdateSection({super.key});

  @override
  State<AppUpdateSection> createState() => _AppUpdateSectionState();
}

class _AppUpdateSectionState extends State<AppUpdateSection> {
  final _service = AppUpdateService();
  late final _packageInfo = PackageInfo.fromPlatform();
  AppUpdateInfo? _update;
  bool _checking = false;
  String _status = '检查是否有可用的新版本';

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _update = null;
      _status = '正在检查更新…';
    });
    try {
      final package = await _packageInfo;
      final update = await _service.check(package.version);
      if (!mounted) return;
      setState(() {
        _update = update;
        _status = update == null
            ? '尚未发布正式版本'
            : update.available
            ? '发现新版本 v${update.version}'
            : '已是最新版本';
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _status = error is AppUpdateException
            ? error.message
            : '检查失败，请稍后重试。',
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _download() async {
    final page = _update?.releasePage;
    if (page == null) return;
    try {
      if (await launchUrl(page, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Surface both platform errors and a missing browser as a retryable state.
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('无法打开下载页，请检查是否安装了浏览器。')));
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(height: 32),
      Text('应用更新', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) => Text(
          snapshot.hasData
              ? '当前版本 ${snapshot.data!.version} (${snapshot.data!.buildNumber})'
              : snapshot.hasError
              ? '无法读取当前版本'
              : '正在读取版本…',
        ),
      ),
      const SizedBox(height: 8),
      Text(_status),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: _checking ? null : _check,
            child: Text(_checking ? '检查中…' : '检查更新'),
          ),
          if (_update?.available == true)
            FilledButton(onPressed: _download, child: const Text('前往下载')),
        ],
      ),
      if (_update?.available == true) const Text('将在浏览器打开发布页，下载 APK 后按系统提示安装。'),
    ],
  );
}
