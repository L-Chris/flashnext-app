# FlashNext App

> **本项目由 Qwen3.8 Max 开发**

<img src="assets/branding/logo.png" width="96" alt="FlashNext logo" />

最新版本：[v0.3.2](https://github.com/L-Chris/flashnext-app/releases/tag/v0.3.2)，更新内容见 [发布说明](docs/releases/v0.3.2.md)。普通 Android 手机优先下载 `arm64-v8a` 安装包，原生版约 2.35 MB。

FlashNext 的 Android 在线复习客户端，使用 Kotlin、Jetpack Compose、系统 WebView 和 Media3。
包含牌组列表、卡片复习与撤销、牌组学习设置、服务器设置和连接测试。

原生 Android 工程位于 `android/`，使用独立 Gradle 构建，已移除 Flutter 工程与依赖。后端与 Web 工程位于 `../flashnext`。

## 学习设置与复习展示

每张牌组最右侧齿轮打开该牌组设置，可保存每日新卡/复习额度、日切点、自动播放、新卡立即显示答案和延迟自动显示答案。点击弹窗外部空白可关闭，点击面板内部保持打开；未保存修改会提示放弃，保存失败保留草稿。

首页统一「设置」弹窗可配置服务器地址和所有牌组共用的 IANA 时区，共用一个“保存”按钮，另可测试连接及检查应用更新。共享时区使用新版后端 `GET/POST /api/settings`，该接口仅接受时区，额度和日切点仍按牌组保存。

支持服务端 Markdown/数学公式、英日词卡与正反面音频顺序播放。倒计时从内容就绪后开始，后台暂停，手动显示会取消倒计时。评分和撤销由服务器处理，队列完成后仍可撤销。

英语多读音默认显示各自的词性、词义和时态说明；同用法的备选音标以“或”合并。只有读音说明完整覆盖原释义时才隐藏重复释义，自定义笔记保留原文。详见 [多读音同步记录](docs/implementation/app-pronunciations-2026-10-21.md)。

复习页不显示剩余额度和底部进度条。评分确认后优先使用缓存队列切卡，退出复习时再刷新首页统计；学习卡到期、撤销等情况会重新对齐服务端。评分仍需联网确认，详见 [复习切卡优化](docs/implementation/app-review-cache-2026-10-22.md)。

设置中可查看本牌组 FSRS 参数、来源、日志数和训练门槛，手动启动训练并查看状态；不会自动重建日程。本次未开放高级手动参数或重建操作。

接口和验收背景见 [App 开发交接文档](docs/handoff/app-study-features-2026-10-20.md)。范围仅限复习展示与牌组设置，不包含卡片新增/编辑、音频上传或词库导入。
实现与验证记录见 [Android 学习功能实施记录](docs/implementation/app-study-2026-10-20.md)。

## 开发与构建

使用 Java 17 或 21，在本目录运行（Windows 使用 `gradlew.bat`）：

```sh
android/gradlew -p android testDebugUnitTest lintDebug
android/gradlew -p android connectedDebugAndroidTest
android/gradlew -p android assembleRelease
```

APK 输出目录：`build/native/app/outputs/apk/release/`。普通手机选择 `app-arm64-v8a-release.apk`；32 位旧机和 x86_64 设备选择对应包。不生成通用包。
三个架构使用相同 versionCode，覆盖升级需提高构建号。版本统一读取 `android/version.properties`，当前为 `0.3.2+12`；也可用 `-PbuildNumber=数字` 覆盖本地验证构建号。
Android SDK 路径在本机 `android/local.properties` 中配置，例如 `sdk.dir=F\:/android-sdk`。
详细实现、验证命令与迁移说明见 [原生 Android 迁移](docs/implementation/native-android-2026-10-22.md)。

## 连接服务器

默认地址为 `https://mem.home.rethinkos.com`，可在设置页修改并测试连接。
手机需要接入可访问服务器的内网或 Tailscale 网络。
`android/app/src/main/AndroidManifest.xml` 声明了 `INTERNET` 权限，release 使用 HTTPS。覆盖安装后自动读取原 Flutter 版保存的服务器地址，学习记录和学习设置继续由原后端保存。

## 图标

源图为 `assets/branding/logo.png`；原生桌面图标使用同一套已生成资源，位于 `android/app/src/main/res/`。
替换图标时同步各分辨率的 `ic_launcher.png`、`ic_launcher_foreground.png` 和自适应图标背景色。
生成方式和提示词见 [assets/branding/README.md](assets/branding/README.md)。

## Tag 自动构建 Android

推送 tag 会触发 `.github/workflows/android.yml`，也可在 GitHub Actions 页面手动运行。
工作流使用 Java 17 和 Gradle，执行原生单元测试、Android Lint 和 release 构建。启用 R8 代码优化及资源裁剪；对应 `mapping.txt` 另存为 `flashnext-symbols-<版本>-<运行编号>` Artifact，保存 90 天，排查历史崩溃需使用匹配构建的文件。
版本名和构建号取自 `android/version.properties`（当前为 `0.3.2+12`）；每次发布都应提高版本名和构建号。发布规则见 [AGENTS.md](AGENTS.md#github-release-notes)，完整步骤见 [发布流程](docs/RELEASING.md)。
tag 必须为与版本名匹配的 `vX.Y.Z`，不匹配时构建会失败，避免 App 更新判断与 APK 实际版本不一致。

```sh
# 先修改 android/version.properties 的 versionName 和 versionCode
git tag -a v0.3.2 -m "FlashNext v0.3.2"
git push --atomic origin main refs/tags/v0.3.2
```

tag 构建成功后自动创建同名 GitHub Release，附带 `FlashNext-X.Y.Z-android-arm64-v8a.apk`、`FlashNext-X.Y.Z-android-armeabi-v7a.apk`、`FlashNext-X.Y.Z-android-x86_64.apk` 和 `SHA256SUMS.txt`。
从 0.2.0 起仅发布三个架构的 APK，不再构建或发布通用包；普通手机下载 arm64-v8a 包即可。0.1.0 客户端的更新检查依赖通用包，升级到 0.2.0 时请从 Release 页面手动下载对应架构的安装包。
发布说明必须来自 `docs/releases/<tag>.md`，先英文、再附中文折叠块，Release 标题必须与 tag 完全一致。已有 Release 不会被覆盖。
也可在 Actions → Build Android → 对应运行 → Artifacts 下载 `flashnext-android-<运行编号>`，保存 90 天。
手动运行只构建和上传 Artifact，不创建 Release。目前只支持 Android。

当前发布原生 APK，不再携带 Flutter 引擎或 Dart AOT 代码。原 Flutter 包的体积分解见 [APK 体积分析](docs/implementation/apk-size-2026-10-22.md)，原生构建对比见 [迁移记录](docs/implementation/native-android-2026-10-22.md)。v0.2.0 附件仍为 Flutter 版。

## 应用内更新

应用启动时自动检查 GitHub 最新正式 Release（最多每 6 小时一次），也可在设置中手动检查。发现新版后提示更新，点击“立即更新”由 App 下载适合本机架构的 APK，并显示进度。
下载完成后校验 SHA-256、包名、版本、签名和架构，再打开 Android 安装界面。首次更新需要允许此应用安装未知应用，授权返回后继续安装；取消安装后可直接重试，不必重新下载。
更新连接独立于学习服务器，忽略草稿、预发布和旧版本。Android 安装仍需用户确认。
实现与验证记录见 [原生设置与应用内更新](docs/implementation/android-updates-settings-2026-10-22.md)。

## 固定签名

CI 使用仓库 Secrets：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`、`ANDROID_STORE_PASSWORD`。
缺少任一项则停止构建，避免生成无法覆盖升级的随机签名 APK。
当前固定使用已有 FlashNext 安装版的 Android Debug 证书，以保持现有用户覆盖升级兼容；尚不是商店发布证书。
SHA-256：`f81ff936bd1e69c4f571fb0eec392bd198aa83ecff53050177fc9708045ee82f`。

本地签名备份位于被 Git 忽略的 `signing/flashnext-keystore.jks`，配置位于 `android/key.properties`。
原生构建读取 `android/key.properties`；其中 storeFile 相对于 `android/app/`，本机配置为 `../../signing/flashnext-keystore.jks`。debug 包使用 `.native` 包名，可与正式版并存；未配置固定签名的 release 产物为 unsigned，不能用于覆盖升级。CI 缺少签名 Secrets 时直接失败。
请单独安全备份签名材料，不要提交到仓库。
