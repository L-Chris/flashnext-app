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

推送 tag 会触发 `.github/workflows/android.yml`，也可在 GitHub Actions 页面手动运行。
工作流使用 Flutter 3.47.0 / Java 17，执行依赖校验、静态检查、测试和 release APK 构建。
版本名和构建号取自 `pubspec.yaml`（如 `1.0.1+2`）；每次发布都应提高版本名和构建号。
tag 必须为与版本名匹配的 `vX.Y.Z`，不匹配时构建会失败，避免 App 更新判断与 APK 实际版本不一致。

```sh
git tag v1.0.1
git push origin v1.0.1
```

tag 构建成功后自动创建同名 GitHub Release，附带通用 APK `FlashNext-X.Y.Z-android.apk` 和 `SHA256SUMS.txt`。
发布说明优先读取 `docs/releases/<tag>.md`，没有该文件则使用自动生成的说明。已有 Release 不会被覆盖。
也可在 Actions → Build Android → 对应运行 → Artifacts 下载 `flashnext-android-<运行编号>`，保存 90 天。
手动运行只构建和上传 Artifact，不创建 Release。目前只支持 Android。

## 应用内更新

参考 Torto Android 的流程，在设置页点击“检查更新”，读取本仓库 GitHub 最新正式 Release。
有新版本且 APK 上传完成时显示“前往下载”，在浏览器打开发布页，再由用户下载并按 Android 提示安装。
不自动下载或静默安装；忽略草稿、预发布和旧版本。检查更新需要访问 GitHub，不依赖内网学习服务器。

## 固定签名

CI 使用仓库 Secrets：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`、`ANDROID_STORE_PASSWORD`。
缺少任一项则停止构建，避免生成无法覆盖升级的随机签名 APK。
当前固定使用已有 FlashNext 安装版的 Android Debug 证书，以保持现有用户覆盖升级兼容；尚不是商店发布证书。
SHA-256：`f81ff936bd1e69c4f571fb0eec392bd198aa83ecff53050177fc9708045ee82f`。

本地签名备份位于被 Git 忽略的 `signing/flashnext-keystore.jks`，配置位于 `android/key.properties`。
请单独安全备份签名材料，不要提交到仓库。新环境未配置签名时，本地构建仍会使用其自身的 debug key；需要覆盖升级时应先配置上述固定签名。
