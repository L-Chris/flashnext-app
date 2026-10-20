import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';

const releaseRepository = 'L-Chris/flashnext-app';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.releasePage,
    required this.available,
    this.downloadUrl,
    this.architecture,
  });

  final String version;
  final Uri releasePage;
  final bool available;
  final Uri? downloadUrl;
  final String? architecture;
}

Version releaseVersion(String value) => Version.parse(
  value.trim().replaceFirst(RegExp(r'^[vV]'), '').split('+').first,
);

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Uses public GitHub Releases, independently of the private study server.
class AppUpdateService {
  AppUpdateService({Dio? dio, String? architecture})
    : _dio = dio ?? Dio(),
      architecture = architecture ?? _runtimeArchitecture();
  final Dio _dio;
  final String? architecture;

  static String? _runtimeArchitecture() => switch (Abi.current()) {
    Abi.androidArm64 => 'arm64-v8a',
    Abi.androidArm => 'armeabi-v7a',
    Abi.androidX64 => 'x86_64',
    _ => null,
  };

  Future<AppUpdateInfo?> check(String currentVersion) async {
    final Response<dynamic> response;
    try {
      response = await _dio
          .get<dynamic>(
            'https://api.github.com/repos/$releaseRepository/releases/latest',
            options: Options(
              headers: {
                'Accept': 'application/vnd.github+json',
                'User-Agent': 'FlashNext-Android',
              },
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              validateStatus: (status) => status == 200 || status == 404,
            ),
          )
          .timeout(const Duration(seconds: 20));
    } on DioException catch (error) {
      if (error.response?.statusCode == 403 ||
          error.response?.statusCode == 429) {
        throw const AppUpdateException('检查过于频繁，请稍后再试。');
      }
      throw const AppUpdateException('无法连接 GitHub，请检查网络后重试。');
    }
    if (response.statusCode == 404) return null;
    final body = response.data;
    if (body is! Map<String, dynamic> ||
        body['tag_name'] is! String ||
        body['html_url'] is! String) {
      throw const AppUpdateException('发布信息不完整，请稍后重试。');
    }
    if (body['draft'] == true || body['prerelease'] == true) return null;
    final version = releaseVersion(body['tag_name'] as String);
    if (version.isPreRelease) return null;
    final page = Uri.tryParse(body['html_url'] as String);
    if (page == null ||
        page.scheme != 'https' ||
        page.host != 'github.com' ||
        page.userInfo.isNotEmpty ||
        page.hasPort ||
        !page.path.startsWith('/$releaseRepository/releases/tag/')) {
      throw const AppUpdateException('发布地址无效。');
    }
    final assets = body['assets'];
    final prefix = 'FlashNext-$version-android';
    final names = [
      if (architecture != null) '$prefix-$architecture.apk',
      '$prefix.apk',
      if (architecture == null) ...[
        '$prefix-arm64-v8a.apk',
        '$prefix-armeabi-v7a.apk',
        '$prefix-x86_64.apk',
      ],
    ];
    String? selected;
    if (assets is List) {
      for (final name in names) {
        if (assets.any(
          (asset) =>
              asset is Map &&
              asset['name'] == name &&
              asset['state'] == 'uploaded' &&
              asset['size'] is num &&
              (asset['size'] as num) > 0,
        )) {
          selected = name;
          break;
        }
      }
    }
    if (selected == null) {
      throw const AppUpdateException('新版本安装包尚未就绪，请稍后重试。');
    }
    return AppUpdateInfo(
      version: version.toString(),
      releasePage: page,
      available: version > releaseVersion(currentVersion),
      architecture: architecture,
      downloadUrl: Uri.https(
        'github.com',
        '/$releaseRepository/releases/download/${body['tag_name']}/$selected',
      ),
    );
  }

  void dispose() => _dio.close(force: true);
}
