# FlashNext App

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
