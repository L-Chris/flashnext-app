# FlashNext App

<img src="assets/branding/logo.png" width="96" alt="FlashNext logo" />

FlashNext 的 Android 在线复习客户端，使用 Flutter、Riverpod、Dio 和 go_router。
包含牌组列表、卡片复习与撤销、每日限额提示、服务器设置和连接测试。

本工程已从 `../flashnext/app` 迁入；后端与 Web 工程位于 `../flashnext`。

## 开发与构建

在本目录运行：

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

修改模型后运行 `dart run build_runner build --delete-conflicting-outputs`。
APK 输出路径：`build/app/outputs/flutter-apk/app-release.apk`。
Android SDK 路径在本机的 `android/local.properties` 中配置。

## 连接服务器

默认地址为 `https://mem.home.rethinkos.com`，可在设置页修改并测试连接。
手机需要接入可访问服务器的内网或 Tailscale 网络。
`android/app/src/main/AndroidManifest.xml` 声明了 `INTERNET` 权限，确保 release 包也能联网。

## 图标

源图为 `assets/branding/logo.png`，同时用于首页标识和 Android 桌面图标。
替换源图后运行 `dart run flutter_launcher_icons`，提交生成的 `android/app/src/main/res/` 资源。
生成方式和提示词见 [assets/branding/README.md](assets/branding/README.md)。

## Tag 自动构建 Android

推送任意 tag 会触发 `.github/workflows/android.yml`，也可在 GitHub Actions 页面手动运行。
工作流使用 Flutter 3.47.0 / Java 17，执行依赖校验、静态检查、测试和 release APK 构建。
版本名取自 `pubspec.yaml`，构建号使用 Actions run number；发布前先更新 `pubspec.yaml` 的版本名。

```sh
git tag v1.0.1
git push origin v1.0.1
```

在 Actions → Build Android → 对应运行 → Artifacts 下载 `flashnext-android-<运行编号>`，其中包含 `app-release.apk`，保存 90 天。
目前只构建 Android，不自动创建 GitHub Release。

当前沿用工程的 debug key 签署 release APK，适合测试安装，不用于应用商店发布。
GitHub runner 的签名与本地手机安装版、其他运行之间可能不同，不能保证覆盖升级；正式分发前需配置固定的 release keystore。
