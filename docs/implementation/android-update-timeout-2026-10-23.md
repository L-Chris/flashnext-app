# Android 更新下载超时排查与修复

## 复现与原因

手机可以读取版本号，用户反馈同一安装包在手机浏览器中可以下载，但应用一直没有进度并最终超时。

通过手提电脑的 ADB 服务连接 Redmi K60（Android 15），正式应用已安装 0.3.2 / code 12。在独立测试包内复用更新下载器，对比同一手机、同一时段、同一 GitHub Release 的访问：

| 路径 | 结果 |
| --- | --- |
| 原连接策略：GitHub 版本 API → github.com 附件链接 | 版本查询成功；连接 github.com:443 超过 10 秒后失败，尚未收到响应头或安装包字节 |
| 延长连接时间并重试，仍使用 github.com 附件入口 | 三次连接均超时，总计约 48.7 秒 |
| 修复：版本 API → 附件 API → GitHub 官方 CDN | 约 2.8 秒完成版本查询、下载 2,354,572 字节 arm64 APK 及 SHA-256 校验 |

更新独立测试程序后真机复测约 1.9 秒通过；Android 15 模拟器通过新链路约 8.3 秒下载并校验 2,355,233 字节 x86_64 APK。

手机当时使用移动网络，Tailscale 仅配置了内网路由；没有系统 HTTP 代理。故障发生在连接 github.com 这一步，尚未进入 CDN 下载阶段。版本 API 与下载入口是不同主机，能查询版本并不保证旧下载链路可用。浏览器成功的具体连接、DNS 或代理差异没有抓包确认，不据此推断所有应用的网络行为相同。

旧客户端仅在收到文件字节后更新进度，连接阶段停留在 0%；网络错误还复用了学习服务器的提示。两者使更新问题更难定位。

## 修改

- 从 Release 元数据读取所选 APK 和校验清单的数字附件 ID，按固定仓库构造 `https://api.github.com/repos/L-Chris/flashnext-app/releases/assets/{id}`，携带 `Accept: application/octet-stream` 获取附件。这个官方入口可以直接返回文件或重定向到 CDN，不必连接 github.com。缺少附件 ID 的旧数据仍兼容原下载地址。
- API 下载无需 GitHub 凭据，不使用第三方镜像，也不通过学习后端转发。仍限制原始发布地址、重定向域名和 HTTPS，保留长度、整包 SHA-256、包名、版本、安装签名和 ABI 校验。
- 对暂时性网络故障和部分服务端错误最多尝试三次。中途断开时在本轮下载中按 Range 续传，严格核对 Content-Range，并校验完整文件；不支持续传的 200 响应从头覆盖。校验失败、错误范围、证书失败不会盲目重试。
- 连接、校验清单、接收文件和重试阶段分别显示状态；收到文件字节后才显示百分比。下载错误指出更新主机，支持重新下载和取消，不再指向学习服务器。
- 下载总期限三分钟，每次请求最多两分钟；连接超时 15 秒，读取超时 45 秒。取消和失败清理临时文件。手动重试、取消或进程退出不保留断点。

接口依据：[GitHub 官方 Release assets API 文档](https://docs.github.com/en/rest/releases/assets#get-a-release-asset)，支持公开附件无认证下载及 200 / 302 响应。

## 验证方法

常规本地验证：

```sh
android/gradlew -p android testDebugUnitTest lintDebug assembleRelease
```

JVM 用例覆盖连接阶段无字节超时重试、断线续传、忽略 Range 时重新下载、错误范围及哈希拒绝、重试上限、不可重试状态码、总期限、取消清理，以及附件 API 跳过网页主机并保留 CDN 续传请求。

本轮 29 项 JVM 用例通过；Android Lint 及三种 ABI 的 release 构建通过。模拟器上的连接提示、超时后重试与取消界面用例通过。手机验证仅执行不依赖前台界面的网络测试，不将其计作真机界面或系统安装器测试。

下载测试的模拟服务和请求固定使用 `127.0.0.1`，避免 Linux 上 `localhost` 同时解析到 IPv4、IPv6 时，断线重连误连到未监听的地址；不改变生产下载器的 DNS 或连接策略。

界面用例 `AppUpdaterTest.connectionStageIsVisibleBeforeBytesAndTimeoutAllowsRetryAndCancel` 使用本地伪数据验证连接提示、错误恢复、重试与取消。依赖更高版本 APK 样本的原有安装用例需单独提供样本，不能把跳过计为通过。

真实网络验证独立于界面测试，仅在明确传入参数时读取公开 GitHub Release 并下载当前设备 ABI 的 APK，不触发安装或写入学习服务：

```sh
adb shell am instrument -w \
  -e class com.rethinkos.flashnext_app.UpdateNetworkTest \
  -e networkUpdate true \
  com.rethinkos.flashnext_app.native.test/androidx.test.runner.AndroidJUnitRunner
```

增加 `-e legacyNetworking true` 可对比原连接策略和网页下载入口。日志标签为 `FlashNextUpdateTest`，仅记录阶段、主机与重试次数，不记录 CDN 签名 URL。

本次手机验证使用独立的 `.native` 测试包，验证后已移除，未替换正式应用或清理其数据。修复纳入 v0.3.3 / code 13；旧版若仍在应用内下载超时，可用手机浏览器下载对应架构的新版 APK，覆盖安装后使用修复后的更新机制。
