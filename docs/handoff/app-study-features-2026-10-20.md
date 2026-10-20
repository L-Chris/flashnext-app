# FlashNext App 学习设置与复习展示交接

目标是在 Flutter App 接入已经完成的每牌组设置、数学公式展示、卡片音频和自动显示答案。用户已明确：**App 只做复习展示与牌组设置，不做新增或编辑卡片、上传音频、词库导入。** 本次提交提供交接说明和接口样例，尚未实现这些 App 功能。

## 代码基线与新机器启动

| 仓库 | 基线 | 用途 |
| --- | --- | --- |
| `L-Chris/flashnext` | `029c25ea7bd68fe893571f9bb317cb25181cb2b1` | 后端接口、数据库模型、Web 交互与回归测试已实现 |
| `L-Chris/flashnext-app` | 功能实现前基线 `63a5170`；从包含本文档的最新 main 开始 | Flutter 客户端，当前仍是原复习界面 |

默认服务地址为 `https://mem.home.rethinkos.com`，需能访问内网或 Tailscale。App 仍允许用户修改服务器地址。后端代码基线不代表生产数据也在 Git：数据库、媒体、Kaikki 大文件、生成音频和 API Key 均未提交。

```sh
git clone https://github.com/L-Chris/flashnext-app.git
git clone https://github.com/L-Chris/flashnext.git
cd flashnext-app
git switch -c feat/app-study-presentation
flutter --version
flutter pub get --enforce-lockfile
flutter analyze
flutter test
```

已有本地仓库时先在干净工作区 `git pull --ff-only`。目前 CI 使用 Flutter **3.47.0**、Java **17**，`pubspec.yaml` 要求 Dart `^3.13.0`。修改 Freezed 模型后运行：

```sh
dart run build_runner build --delete-conflicting-outputs
```

同时提交对应 `.freezed.dart`、`.g.dart`。新增播放器或 WebView 依赖时，在上述 SDK 上选择兼容版本并提交 `pubspec.lock`，不要直接沿用网上片段的版本号。

## 交付范围与页面入口

| 部分 | 应实现的行为 |
| --- | --- |
| 牌组列表 | 每张牌组卡片最右侧齿轮打开该牌组设置；齿轮点击不进入复习 |
| 牌组设置 | 每日新卡/复习额度、时区、日切点，以及音频自动播放、新卡立即显示答案、延迟自动显示答案 |
| FSRS 设置 | 查看本牌组参数及来源、更新时间、日志数和训练门槛；从本牌组启动训练并查看状态 |
| 高级 FSRS 操作 | 如提供手动参数或重建，使用下文的本牌组接口；重建必须先预览再由用户确认应用 |
| 卡片正文 | 保留纯文本与英日词汇布局；为 `markdown_math` 展示服务端渲染的公式和 Markdown |
| 卡片音频 | 正反面分开、排序、手动播放，以及依牌组设置自动播放；正确处理生命周期和播放失败 |
| 自动显示答案 | 使用每张卡片的 `presentation`，支持立即、倒计时和纯手动三种情况 |
| 原有复习 | 保留评分、撤销、限额提示、完成队列后的撤销和连接设置 |

全局设置页保留服务器地址、连接测试和应用更新；学习设置移到各牌组。牌组设置弹层没有右上角关闭按钮，使用 Android 返回或底部弹层/遮罩退出，保存是明确操作，不在关闭时隐式保存。有未保存内容时保留草稿或提示放弃。

**不增加**卡片创建/编辑器、文件选择/上传、音频生成按钮、词库导入或后台音频播放服务。卡片、公式、附件继续在 Web 维护；App 播放已有文件，不调用 Gemini、Forvo 或 Bifrost，也不需要它们的 Key。

## 当前 App 的主要改动位置

以下是已核对的现状，不要假定新增字段已经接入。

| 文件 | 现状与改动 |
| --- | --- |
| `lib/models/due_queue.dart` | `Card` 缺 `contentFormat/media/presentation`，`DueQueue` 缺 `reviewOptions`；扩展类型并生成代码 |
| `lib/models/due_queue.dart` 中 `WordBrief` | 缺日语 `language/reading/romaji`，还需按实际 UI 补充规范音标/义项字段 |
| `lib/models/deck.dart` | 可增加 `language`，用于正确标记英日牌组 |
| `lib/core/network/api_client.dart` | 增加牌组设置、FSRS 状态/操作和内容渲染方法；继续统一解包 `{data:...}` |
| `lib/core/providers.dart` | 现有 `settingsProvider` 只管理服务器地址；新增按服务器与 deckId 隔离的学习设置 Provider |
| `lib/features/decks/decks_screen.dart` | `_DeckTile.trailing` 目前是数量/完成标记，调整为含最右侧设置齿轮的布局 |
| `lib/features/review/review_screen.dart` | 当前只手动显示答案，无播放器、倒计时或公式；需要拆出卡片会话、卡面、音频组件 |
| `lib/core/card_content.dart` | 当前仅解析英文 `/音标/` 和词性行；仅在纯文本词卡分支使用，不能拿它解析数学内容 |
| `lib/features/settings/settings_screen.dart` | 保留连接设置与应用更新，别把牌组字段写进全局 SharedPreferences |

`ApiClient.cards()` 目前把 `/decks/:id/cards` 的分页对象当成数组；本次复习继续使用 `/due`。若后续使用卡片列表方法，应按 `data.cards` 解包，不能假定旧方法可用。

建议新增 `DeckSettings/ReviewOptions/CardPresentation/CardMedia/ContentPreview` 模型，以及可独立测试的 `ReviewSession` 控制器。网络请求、计时和播放器副作用不放在 Widget 的 `build()` 中。

## 接口与序列化规则

以下路径均相对 `/api`。现有 Dio 的 baseUrl 已是 `$baseUrl/api`，JSON 接口继续使用 `/decks/...` 等路径。

| 方法与路径 | 返回 data 或用途 |
| --- | --- |
| `GET /decks` | 牌组数组，含队列计数与今日用量 |
| `GET /decks/:deckId/settings` | 该牌组设置对象 |
| `POST /decks/:deckId/settings` | 保存提交的设置字段，返回完整设置 |
| `GET /decks/:deckId/cards/due` | `{cards, reviewOptions, usage, counts}`，cards 已按后端调度与限额处理 |
| `GET /cards/:id` | 单张完整卡片 |
| `POST /cards/:id/review` | `{rating:1..4,durationMs:整数毫秒}`，返回更新后的完整 Card |
| `POST /cards/:id/undo` | 返回撤销后的完整 Card，包含重新计算的 presentation |
| `POST /content/preview` | 按原始正文渲染两面，不修改卡片 |
| `GET/HEAD /media/:id/content` | 音频字节流；不是 JSON，不经 `_unwrap` |

`GET/POST /settings`、无 deckId 的 `/fsrs/*` 已返回 **400**，不能用作全局入口或自动回退。

缺失字段的兼容默认值：`contentFormat=plain`、`media=[]`；缺失 `presentation` 时手动显示、自动播放关闭。未知格式保留原文，不擅自当 HTML。

### 牌组设置

完整示例在 [fixtures/deck-settings.json](fixtures/deck-settings.json)。

| 字段 | 类型与约束 |
| --- | --- |
| `deckId` | 响应中的牌组 ID |
| `newPerDay/reviewPerDay` | 整数 0–100000；0 是有效值 |
| `timezone` | 有效 IANA 时区，例如 `Asia/Shanghai` |
| `rolloverHour` | 整数 0–23，例如 4；不是字符串时间 |
| `audioAutoplay` | 布尔值；默认 false，但 UI 必须读取实际牌组值 |
| `showNewCardAnswerImmediately` | 布尔值；默认 false |
| `autoRevealAnswerSeconds` | 整数 1–3600；**null 表示关闭**，默认 10 秒 |
| `version` | 响应版本；保存成功后用于刷新状态和缓存 |

POST 接受部分字段。建议只发用户实际修改的字段，避免覆盖其他端的新设置。保存成功使用响应完整对象替换本地状态，再刷新牌组计数及下次队列；失败保留草稿。接口没有客户端版本条件写协议，不要虚构 `If-Match` 或版本冲突接口。

关闭自动显示应发送 `{"autoRevealAnswerSeconds":null}`。Dart 序列化不能把该 null 丢掉：省略字段会使后端保留原值。开关重新开启时可给 10 秒初始值，但不能在解析显式 null 时重设为 10。

限额、日切点、时区、FSRS 调度由后端负责；App 不再按本机午夜重算、截断或重排队列。限额保存不会重建已有复习日程。

### 卡片展示字段

卡片仍返回 `front/back/state/reps/word`，并新增：

```json
{
  "contentFormat": "plain",
  "media": [],
  "presentation": {
    "audioAutoplay": true,
    "answerRevealAfterMs": 10000,
    "settingsVersion": 3
  }
}
```

`answerRevealAfterMs` 三种值必须区分：

| 值 | 行为 |
| --- | --- |
| `0` | 直接显示答案；只自动播放背面，不短暂播放正面 |
| 正整数 | 卡片内容实际准备好并显示后开始倒计时 |
| `null` | 完全手动显示，无倒计时 |

每张卡片的 `presentation` 是展示依据，`reviewOptions` 用于队列级配置。App 不要自行把所有新卡变成立即显示，也不要用 `?? 10000` 覆盖 null。后端的新卡条件为 `state == 0 && reps == 0`，立即显示开关优先于延迟设置。

评分和撤销响应都含最新展示字段。现有 `_undo()` 丢弃响应再加载队列，接入时应保证撤销的卡片按最新 Card 建立新会话，并刷新队列/用量，不能复用旧的 revealed 状态。

## 复习会话和生命周期

使用 `server + deckId + cardId + visitCounter` 区分一次展示；同一张卡撤销后再次出现也必须有新 visit。切卡、翻面、退出和请求结束时核对会话标识，旧的异步响应不能影响当前卡片。

建议按以下顺序实现：加载卡片 → 准备卡面 → 按 presentation 显示正面或答案 → 启动相应音频与计时 → 用户评分 → 清理本次会话 → 下一张。立即显示不应出现正面音频或正面倒计时闪动。

计时与播放器规则：

1. 倒计时从正文/公式准备好后开始；普通 Widget rebuild 不重置计时。
2. 用户提前显示答案时取消倒计时，避免第二次翻面、重复声音或重复副作用。
3. `inactive/paused/hidden` 时暂停倒计时、记录剩余时间并停止音频；回前台按剩余时间继续计时，不突然恢复播放。
4. 切卡、撤销、退出、切换服务器和 dispose 时取消计时、请求、播放监听，并释放音频资源。
5. 后台停留时间不作为倒计时已用时间。使用单调时钟/Stopwatch，避免系统时钟校准导致提前翻面。
6. 公式请求失败时显示原始正文与重试入口，暂停自动显示与自动播放，仍允许手动看答案。
7. 翻面、播放和倒计时结束都不能提交评分、切换卡片或扣减额度；只有用户评分调用 review。
8. 评分期间锁住按钮；评分/撤销 POST 不自动重试，防止网络超时后重复评分。
9. `durationMs` 从内容准备好开始累计，手动或自动翻面均不重置。当前 App 在 `_reveal()` 才开始计时，应一并调整。
10. 最后一张评分后仍保留“撤销上一次”，不能只在还有待复习卡时显示。

Flutter 生命周期可使用 [AppLifecycleListener](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html) 或 `WidgetsBindingObserver`；注意资源回收和异步完成后的 mounted/session 检查。

## 数学公式与多语言正文

后端返回的是 **源文本**，没有 `renderedHtml` 字段。只对 `contentFormat == markdown_math` 调用：

```http
POST /api/content/preview
Content-Type: application/json

{"front":"求解 \\(x^2=4\\)","back":"$$x=\\pm 2$$","contentFormat":"markdown_math"}
```

响应位于 `data`：`front/back` 各含 `html` 和 `errors`，另有 `valid` 与 `renderer.{name,version,cssUrl}`。真实渲染样例见 [fixtures/content-preview.json](fixtures/content-preview.json)。错误有 `message/offset/line/column`；offset 从 0 开始，行列从 1 开始。

支持 `\(...\)`、`\[...\]`、`$$...$$`。单个 `$` 是普通字符；代码块和行内代码不解析公式。不要用简单 `$...$` 正则另做一套数学语法，也不要把 `plain` 中的反斜杠或价格自动解释为公式。

推荐复用后端 HTML/MathML 和 KaTeX 资源，用 [webview_flutter](https://pub.dev/packages/webview_flutter) 承载受控卡面，与 Web 保持同一语法和渲染器。该插件由 flutter.dev 发布，使用平台 WebView；引入时核对 Android SDK 要求。本文不要求强行升级 App 的最低 Android 版本。

实现要点：

- 用 Dio 请求 JSON，取后端生成的 `html`，不要把原始 front/back 拼成活动 HTML。
- 加载 `renderer.cssUrl`，当前为 `/api/content/assets/katex.min.css`，以及 CSS 引用的 `/api/content/assets/fonts/...`。地址基于当前服务器解析，不依赖公共 CDN。
- 后端已经渲染公式，不需要在 WebView 再加载 KaTeX JS。优先禁用 JavaScript 并使用可滚动卡面；若布局确需受控测量脚本，不执行卡片原文中的脚本，不允许任意页面导航。
- 适配深色模式、文字缩放、长公式横向滚动和移动端宽度；不让 WebView 抢走原生评分控件。
- `valid=false` 或网络失败时可读原始文本并重试；防止上一张卡的迟到响应覆盖下一张。
- 渲染缓存包含服务器、原始正文和格式标识，限制条数/大小；切换服务器不能命中上一服务的缓存。

`plain` 仍使用原生 Text，保留真实换行和空白；不要对所有卡片全局解码反斜杠转义来修补换行，避免破坏 TeX。日语显示 `word.reading`、词性与中文释义，不把假名套进 `/IPA/`；罗马音可折叠。自定义 back 保留原文，不用词典字段替换笔记。英文音标、多义项和例句继续保持可读。参考后端 `word-card.ts` 与 Web `utils/word-card.ts` 的判断。

## 音频播放

`media` 每项含 `mediaId`、`side`、`position`、`id`、`mimeType`、`bytes`、`originalName`、`createdAt`、`url`。`mediaId/id` 都是字符串 UUID，不是整数；`side` 为 `front` 或 `back`。先按卡面过滤，再按 position 升序播放。

`url` 通常为 `/api/media/<uuid>/content`，需要以配置的服务器为基准转为绝对 URL；例如 `Uri.parse(serverBaseUrl).resolve(media.url)`。不要把它再次接到已带 `/api` 的 Dio baseUrl 上，造成 `/api/api/media/...`。

推荐 [just_audio](https://pub.dev/packages/just_audio) 播放现有 URL，并用 [audio_session](https://pub.dev/packages/audio_session) 处理语音音频会话与焦点中断。按兼容 SDK 锁定版本，网络字节流交给播放器；不要先用 JSON 客户端下载整个音频。后端支持 MP3、M4A、WAV、OGG/Opus，提供 MIME、长度、ETag、HEAD 和单一 Range 请求的 206/416 响应。

| 场景 | 行为 |
| --- | --- |
| 自动播放关闭 | 保留手动播放控件，不启动自动播放 |
| 展示正面 | 仅播放正面附件，按顺序一次播放 |
| 翻面 | 停止正面音频，再启动背面附件 |
| 新卡立即显示 | 只启动背面自动播放 |
| 同一面多个文件 | 当前结束后顺序播放下一个；不并发播放 |
| 音频加载/解码/焦点失败 | 显示可恢复状态并允许手动重试，不反复自动请求或连播报错 |
| 切卡/退出/后台/撤销 | 停止播放，撤销后按新会话重新应用设置 |
| 回到前台 | 不自动恢复已中断音频，用户可手动播放 |

在播放完成、URL 加载完成等回调中核对会话标识，避免 A 卡的旧回调开始播放 B 卡或切卡后继续播。播放器错误不阻止用户正常查看文字和评分。

生产日语牌组已有 343 张带背面 MP3 的卡片，约 3.13 MB，由后端保存。App 不需要重新生成、批量上传或分发这些文件；在可访问服务器的设备上直接读取现有 media URL 即可。数量是 2026-10-20 的校验值，不要硬编码牌组 ID、卡片 ID 或总数。

## FSRS 参数与训练接口

路径均以 `/decks/:deckId/fsrs` 开头：

| 操作 | 请求与返回要点 |
| --- | --- |
| `GET /params` | `w/source/updatedAt/revlogMigratedAt/reviewCount/minReviews/timezone/rolloverHour` |
| `POST /optimize` | `{}` 启动；返回 `{started,job}`；不要把启动响应当训练已经完成 |
| `GET /optimize` | `running/startedAt/finishedAt/force/result/error`，UI 轮询直到结束 |
| `POST /params` | 高级手动参数操作使用 `{w:[...],audit:true}`，根据实际后端结果显示审计信息 |
| `POST /rebuild` | 高级重建先 `{"dryRun":true}`，完成预览后再由用户确认 POST `{}` |
| `GET /rebuild` | `running/progress/result/error`，结果含 `dryRun`、卡数和到期预测 |

`reviewCount/minReviews` 都按本牌组计算，当前门槛为 1000 条；显示门槛时以响应为准。训练由服务端执行，App 不携带优化器，不在打开设置或启动 App 时自动训练。训练成功不自动重建已有卡片。

任务状态按牌组查询，但服务端一次只运行一个训练/重建任务。页面可以显示忙碌/失败信息；不要混用其他牌组的任务结果。页面关闭或 App 后台停止轮询，重新打开再查询；停止轮询不代表服务端取消任务。训练结束重新取 params；服务器重启后任务状态可能重置。

重建预览有效 15 分钟，期间复习、撤销、设置或参数改变都会使预览失效。遇到 409/任务 error 应重新预览；不能自动重试应用。用户未明确确认重建时，只展示参数和预测，不改学习日程。

## 实施顺序与验收

1. 扩展 Freezed 类型、API 客户端和测试样例，先保证旧字段/缺字段仍可解析。
2. 接入每牌组设置与 FSRS 面板，确认 A/B 牌组与服务器地址切换的隔离。
3. 建立复习会话控制器，先测试 0/null/10000、后台暂停、撤销和重复回调。
4. 接入公式卡面与音频，再在 Android 真机测试音频焦点、WebView 字体、网络异常和资源释放。
5. 回归现有英日词卡、评分与撤销、应用更新，构建 release APK；此次交接不发布新版本或推送 tag。

[fixtures/review-cases.json](fixtures/review-cases.json) 含三个独立、内部一致的 mock 队列：普通英文 10 秒、日语新卡立即显示且背面带音频、数学卡纯手动。其 ID 与音频 URL 是假的，不可发往生产；真实音频另通过只读接口取样。

| 必测项目 | 验收结果 |
| --- | --- |
| 序列化 | 保留 null 和 0；UUID 为字符串；旧卡缺少新字段正常展示 |
| 设置隔离 | 修改 A 牌组不改变 B；重启后能取回服务端设置；服务器切换不串数据 |
| 关闭自动显示 | POST 确实带 null；重新 GET 仍为 null，未意外恢复 10 秒 |
| 新卡立即显示 | 无正面闪动/音频；复习卡不因开关被误判为新卡 |
| 延迟与后台 | 卡片 ready 后倒计时；后台暂停；提前翻面后没有迟到事件 |
| 人工评分 | 等待、翻面、播放不发 review；连续点击评分只提交一次 |
| 撤销 | 使用新 presentation；队列完成后也能撤销；旧回调不再影响当前卡 |
| 英日纯文本 | 音标、假名、词性、中文释义、换行和自定义笔记正确 |
| 数学 | 三种分隔符、矩阵/分数/根式、代码与价格；错误/断网回退；字体可加载 |
| 音频 | 前后面隔离、多文件顺序、手动/自动、切卡停止、回前台不突发播放 |
| 异常和切换 | 不可达服务、音频 404、渲染迟到、快速进出、切服务器均可恢复 |
| FSRS | 本牌组状态/门槛、任务忙碌/结束；若实现重建，预览失效后必须重做 |
| 数据保护 | 只读展示测试前后卡片状态/复习日志不变；写操作测试只指向 mock/临时服务 |

```sh
flutter analyze
flutter test
flutter build apk --release
```

本次仅文档交付，未运行或声称完成新增 App 功能测试。后续实现提交应写明实际命令、模拟器/真机环境、通过用例和仍存在的限制。

生产可用于 GET 队列、卡片、设置、媒体和不写库的内容渲染检查。评分、撤销、设置保存、参数训练/重建的自动化验收使用 mock 或独立测试服务，不能对生产复习记录试写。

若需要本地完整后端，可在独立测试数据卷运行仓库镜像，不挂生产数据目录。Android 模拟器使用宿主机地址或 `adb reverse`；当前主 Manifest 未开放明文 HTTP，调试 HTTP 仅配置 debug 范围的网络策略，不为调试关闭 release 的 HTTPS 校验。

## 后端与 Web 参考源码

以下链接固定在已核对的后端提交，避免另一台机器读到不一致接口：

- [牌组设置及字段校验](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/server/app/modules/settings/application/settings.service.ts)
- [卡片展示策略计算](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/server/app/modules/cards/application/card-presenter.ts)
- [内容渲染与语法](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/server/app/modules/content/application/content.service.ts)
- [媒体接口](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/server/app/controllers/media.controller.ts)
- [Web 展示与撤销](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/web/src/components/ReviewView.tsx)
- [Web 倒计时](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/web/src/hooks/useAnswerCountdown.ts)
- [Web 音频生命周期](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/web/src/components/CardAudio.tsx)
- [Web 公式请求与缓存](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/web/src/hooks/useContentPreview.ts)
- [日语正文处理](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/web/src/utils/word-card.ts)
- [Web 浏览器回归用例](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/web/tests/rich-cards.spec.ts)
- [后端功能说明](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/docs/rich-cards-2026-10-20/README.md)
- [每牌组设置与迁移说明](https://github.com/L-Chris/flashnext/blob/029c25ea7bd68fe893571f9bb317cb25181cb2b1/docs/deck-settings-2026-10-19/README.md)

## 交给下一位开发者的任务

在 `flashnext-app` 按本文实现每牌组设置、公式/音频复习展示和自动显示答案；不做新增/编辑卡片、音频上传或词库导入。先核对已固定的后端接口，再改模型、API 和可测试的复习会话控制器，最后接入原生音频和公式卡面。保留原有服务器设置、应用更新、评分和撤销；不在手机端重算 FSRS。自动化写入用 mock 或独立测试服务，完成静态检查、单元/Widget 测试和 Android 真机验证后提交实现，不自动推送发布 tag。
