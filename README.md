# FlashNext App

> **本项目由 Qwen3.8 Max 开发**

<img src="assets/branding/logo.png" width="96" alt="FlashNext logo" />

FlashNext 的 Android 在线复习客户端，使用 Flutter、Riverpod、Dio 和 go_router。
包含牌组列表、卡片复习与撤销、每日限额提示、服务器设置和连接测试。

本工程已从 `../flashnext/app` 迁入；后端与 Web 工程位于 `../flashnext`。

## 学习设置与复习展示

每张牌组最右侧齿轮打开该牌组设置，可保存每日新卡/复习额度、日切点、自动播放、新卡立即显示答案和延迟自动显示答案。点击弹窗外部空白可关闭，点击面板内部保持打开；未保存修改会提示放弃，保存失败保留草稿。

首页统一「设置」弹窗可配置所有牌组共用的 IANA 时区，同时保留服务器连接与应用更新。共享时区使用新版后端 `GET/POST /api/settings`，该接口仅接受时区，额度和日切点仍按牌组保存。

支持服务端 Markdown/数学公式、英日词卡与正反面音频顺序播放。倒计时从内容就绪后开始，后台暂停，手动显示会取消倒计时。评分和撤销由服务器处理，队列完成后仍可撤销。

设置中可查看本牌组 FSRS 参数、来源、日志数和训练门槛，手动启动训练并查看状态；不会自动重建日程。本次未开放高级手动参数或重建操作。

接口和验收背景见 [App 开发交接文档](docs/handoff/app-study-features-2026-10-20.md)。范围仅限复习展示与牌组设置，不包含卡片新增/编辑、音频上传或词库导入。
实现与验证记录见 [Android 学习功能实施记录](docs/implementation/app-study-2026-10-20.md)。

## 开发与构建

在本目录运行：

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

修改模型后运行 `dart run build_runner build --delete-conflicting-outputs`。
APK 输出目录：`build/app/outputs/flutter-apk/`。普通手机优先选择 `app-arm64-v8a-release.apk`；32 位旧机选择 `app-armeabi-v7a-release.apk`，x86_64 设备选择对应包。
按架构拆分，避免一个安装包携带三套引擎；各架构的 versionCode 使用相同构建号，后续升级仍应提高构建号。
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
版本名和构建号取自 `pubspec.yaml`（如 `0.1.0+3`）；每次发布都应提高版本名和构建号。
tag 必须为与版本名匹配的 `vX.Y.Z`，不匹配时构建会失败，避免 App 更新判断与 APK 实际版本不一致。

```sh
git tag v0.1.0
git push origin v0.1.0
```

tag 构建成功后自动创建同名 GitHub Release，附带 `FlashNext-X.Y.Z-android-arm64-v8a.apk`、`FlashNext-X.Y.Z-android-armeabi-v7a.apk`、`FlashNext-X.Y.Z-android-x86_64.apk` 和 `SHA256SUMS.txt`。
同时保留通用 APK `FlashNext-X.Y.Z-android.apk`，确保现有 0.1.0 客户端的升级检查仍可用；普通手机下载 arm64-v8a 包即可。
发布说明优先读取 `docs/releases/<tag>.md`，没有该文件则使用自动生成的说明。已有 Release 不会被覆盖。
也可在 Actions → Build Android → 对应运行 → Artifacts 下载 `flashnext-android-<运行编号>`，保存 90 天。
手动运行只构建和上传 Artifact，不创建 Release。目前只支持 Android。

## 应用内更新

参考 Torto Android 的流程，在设置页点击“检查更新”，读取本仓库 GitHub 最新正式 Release。
有新版本且本机架构对应 APK 上传完成时显示“前往下载”，在浏览器下载适合本机的包，再按 Android 提示安装。兼容旧 Release 中的通用 APK。
不自动下载或静默安装；忽略草稿、预发布和旧版本。检查更新需要访问 GitHub，不依赖内网学习服务器。

## 固定签名

CI 使用仓库 Secrets：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`、`ANDROID_STORE_PASSWORD`。
缺少任一项则停止构建，避免生成无法覆盖升级的随机签名 APK。
当前固定使用已有 FlashNext 安装版的 Android Debug 证书，以保持现有用户覆盖升级兼容；尚不是商店发布证书。
SHA-256：`f81ff936bd1e69c4f571fb0eec392bd198aa83ecff53050177fc9708045ee82f`。

本地签名备份位于被 Git 忽略的 `signing/flashnext-keystore.jks`，配置位于 `android/key.properties`。
请单独安全备份签名材料，不要提交到仓库。新环境未配置签名时，本地构建仍会使用其自身的 debug key；需要覆盖升级时应先配置上述固定签名。
