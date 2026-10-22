# Android 发布流程

发布说明格式以根目录 [AGENTS.md](../AGENTS.md#github-release-notes) 为准。本流程适用于 `L-Chris/flashnext-app` 的原生 Android 客户端。

## 准备版本与说明

1. 确认上一正式版和当前提交，检查 `git log <上版tag>..HEAD` 与对应差异。用 `gh api repos/L-Chris/flashnext-app/commits/<sha>/pulls` 查询每个待发布提交关联的 PR，核对作者及共同作者，只归属本版实际包含的贡献；维护者 `L-Chris` 的改动无需额外署名。尚未上传的本地提交可先推送分支，再在推送 tag 前完成 GitHub 归属核对。
2. 修改 `android/version.properties`。`versionName` 使用 `X.Y.Z`，`versionCode` 必须高于所有已发布构建。例如 `versionName=0.3.2`、`versionCode=12`；三个 ABI 共用同一构建号。
3. 创建 UTF-8 的 `docs/releases/vX.Y.Z.md`。说明先英文，再写中文折叠块，固定使用 `<summary>中文更新说明</summary>`；两种语言分类、条目和贡献归属一一对应。只使用有内容的 `Feature`、`Improvement`、`Fix` 分类，保持顺序，避免重复记录同一改动。
4. 更新 README 的最新版本链接、说明链接及版本信息。人工按 UTF-8 阅读说明，检查中文、标点、乱码和折叠标记。

## 构建与检查

使用 Java 17 或 21、Android SDK；在仓库根目录执行，Windows 将 `gradlew` 改为 `gradlew.bat`：

```sh
android/gradlew -p android testDebugUnitTest lintDebug
android/gradlew -p android assembleRelease
android/gradlew -p android connectedDebugAndroidTest
git diff --check
```

前两条为发布必需检查。根据改动补做已有设备测试，记录跳过项目和真实设备限制；真实服务器与更新 APK 样本测试单独运行，写操作仅使用测试服务。单独的构建或部分测试不能替代完整的 CI 单元测试与 Lint 命令。

本地固定签名配置为 `android/key.properties`，密钥备份为 Git 忽略的 `signing/flashnext-keystore.jks`；不要提交密钥或配置。CI 使用仓库的四项 Android 签名 Secrets，缺失时构建失败。发布包必须沿用现有签名，以便覆盖升级；可用 `apksigner verify --print-certs <apk>` 检查，当前证书 SHA-256 见 README。

## 推送与发布

核对待提交文件，提交代码、版本、说明、资源和文档；保持密钥及测试下载包不受 Git 跟踪。发布前确认目标 tag 尚不存在，工作区干净，远端分支没有未包含的提交。

```sh
git tag -a vX.Y.Z -m "FlashNext vX.Y.Z"
git push --atomic origin main refs/tags/vX.Y.Z
```

推送 tag 后由 `.github/workflows/android.yml` 检查版本、运行单元测试及 Lint、构建固定签名 APK，再创建 Release：

- 标题严格等于 tag，如 `v0.3.2`，不加应用名、日期或副标题。
- 正文必须来自 `docs/releases/<tag>.md`，不以自动生成说明替代。
- 附件只有三个架构 APK（`arm64-v8a`、`armeabi-v7a`、`x86_64`）及 `SHA256SUMS.txt`，没有通用包。
- CI 自动执行等效于 `gh release create <tag> dist/* --verify-tag --title <tag> --notes-file docs/releases/<tag>.md` 的发布。
- 手动触发工作流只构建 Artifact，不创建 Release；已有 Release 不会被覆盖。已发布 tag 不重用，通常以新版本修复；撤回发布需要用户明确要求。

## 发布后验证

1. 等待对应 tag 的 Actions 成功，确认构建提交与预期一致。
2. 用 `gh release view <tag> --json name,tagName,body,isDraft,isPrerelease,assets` 读取实际发布信息；标题与 tag 必须完全一致，且为正式、非草稿发布。
3. 将远端正文与本地 UTF-8 说明比对，并显示、人工检查远端中文部分、固定 summary 标记和标点；不能只检查两份文本相等。编码损坏时用正确的 UTF-8 文件更新并重新读取验证。
4. 下载三个 APK 与校验文件，核对 SHA-256、固定签名、包名、版本、构建号和对应 ABI，确认没有通用包，并确认本次发布成为 Latest。
5. 报告版本、发布链接、适合普通手机的 arm64 下载链接，以及任何尚未完成的验证限制。

旧版已经安装的用户可以在设置中检查更新；支持内置下载和安装流程的版本会在校验 APK 后打开系统安装器，仍需用户确认安装。
