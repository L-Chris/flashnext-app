# 原生 Android 设置与应用内更新

原生 Kotlin 工程统一位于 `android/`。旧 Flutter 宿主、Dart 源码、测试、pubspec 和插件配置已移除；Gradle、CI、签名配置及版本号均独立于 Flutter。保留旧服务器偏好的读取兼容，覆盖升级后无需重新填写地址。

## 设置

服务器地址和时区共用一个“保存”按钮，移除“学习时区”标题及网络、共享时区提示。保留连接测试和未保存草稿的退出确认。

同时修改服务器与时区时，将时区写入新服务器，成功后才保存本机服务器地址；失败保留草稿及原地址。仅修改服务器时，不会将原服务器时区覆盖到新服务器。

## 更新

启动时检查 GitHub 最新正式 Release，自动检查间隔至少 6 小时，设置中的手动检查不受此限制。发现新版后提示，点击更新由应用下载对应 ABI 的 APK，显示进度并允许取消。下载由 ViewModel 管理，关闭设置不会中止。

仅接受本仓库发布地址和 GitHub 下载域名。先检查长度及 SHA-256（优先使用 GitHub digest，缺失时读取 SHA256SUMS），再检查 APK 包名、版本名、递增构建号、当前安装证书及设备架构。校验通过的包存放于私有目录，经 FileProvider 临时授权交给系统安装器。

首次安装更新需要系统“允许安装未知应用”授权，返回后继续安装。取消安装可重新使用已验证下载包；重新创建更新控制器后可恢复下载记录，安装前再次校验。Android 安装确认由用户操作。

## 验证

- 20 项 JVM 测试通过，覆盖版本选择、队列、流式下载、校验清单、重定向限制、损坏及取消清理。
- Android 15 模拟器本轮 14 项用例中 13 项通过，原有在线公式用例因未提供预览服务器参数跳过；本轮未修改公式实现。
- 新增设置用例覆盖合并保存、新服务器写入、失败保留草稿及仅切换服务器。
- 更新用例使用本地构建的 0.3.2 / code 12 APK，验证证书不匹配、旧构建号、缓存恢复和篡改拒绝；授权返回后继续安装，以及实际打开 Android 安装器。未向生产服务写入学习记录，也未发布测试版本。
- 本地 release 三种 ABI 构建通过；arm64 APK 为 2,261,151 字节，固定签名与现有正式版一致。Android Lint 和工作流 actionlint 通过。

常规检查：

```sh
android/gradlew -p android testDebugUnitTest lintDebug assembleRelease
android/gradlew -p android connectedDebugAndroidTest
```

更新安装测试需先另行构建更高版本且同签名的 debug APK，并准备一个不同签名的同版本副本；样本不提交到仓库。可通过 `-PupdateFixtures=<样本目录>` 将 `valid.apk` 和 `wrong.apk` 仅打包进测试 APK，传入以下参数运行：

```sh
android/gradlew -p android connectedDebugAndroidTest \
  -PupdateFixtures=/absolute/path/to/fixtures \
  -Pandroid.testInstrumentationRunnerArguments.updateApk=valid.apk \
  -Pandroid.testInstrumentationRunnerArguments.updateWrongSigner=wrong.apk
```

未提供样本时，依赖实际 APK 的四项用例跳过。权限用例需在未授权安装权限的测试客户端上开始；撤销该权限可能由 Android 终止进程，应在启动测试进程前操作。
