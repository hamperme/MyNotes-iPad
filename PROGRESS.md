# Project Progress / 项目进度

> **Native workflow restored:** owner confirmed native development and remote main now agrees. Previous build/install evidence below remains valid for the connected owner iPad; it does not establish SideStore or recipient-device acceptance.
Last reviewed: **2026-11-15**
Overall: **M0 build/install/launch passed with user-confirmed visible UI; PR review pending; M1 handwriting/persistence acceptance next**
Next milestone: **M1 — verify full-screen zoom, floating tools and dual erasers on iPad; remaining Pencil/persistence acceptance**

| 阶段 | 状态 | 当前完成内容 | 完成标准 |
| --- | --- | --- | --- |
| M0 工程启动 | 🟢 验收通过，待 PR 审查 | 构建、签名、iPad 安装/启动及进程检查通过；用户确认看到界面 | Mac Xcode 构建成功、iPad 安装启动 |
| M1 PencilKit 手写 | 🟡 部分实现与回归验证 | 画笔、双模式橡皮擦、颜色/笔粗、双指缩放、本地保存；新功能真机验收待确认 | Pencil 真机顺滑使用，重启不丢数据 |
| M2 多页与模板 | 🟡 部分实现 | 可新增/切换页面及四种模板 | 页面删除/排序、模板位置与笔迹对齐可靠 |
| M3 笔记管理 | ⚪ 未开始 | 仅简单笔记列表/新建 | 文件夹、重命名、删除与恢复策略 |
| M4 PDF 批注 | 🟡 导入与独立批注层已实现 | Files / Open In 导入、原件保留、逐页编辑；16 项自动回归通过，微信真机待验收 | 导入、多页坐标正确、批注可编辑、PDF 导出 |
| M5 稳定性与备份 | ⚪ 未开始 | 原子写入笔迹/索引的基础实现 | 撤销/重做、错误提示、备份/恢复、压力回归 |

## 现在的主要阻塞项

1. 开发者模式与签名信任阻塞已解除：用户确认信任后，启动退出 0，后续设备进程查询确认 MyNotes 正在运行。用户已确认看到笔记界面；接下来审查 PR #7，并进行 M1 手写/保存验收。
2. M0 构建/安装/启动验收已满足，Issue #1 暂保留开放等待 PR #7 审查；M1–M5 尚未验收。M0 成功不等于手写功能可用。
3. 保存失败目前仅写日志、没有用户可见提示；正式记笔记前必须补上。
4. PDF 导入与逐页笔迹坐标/缩放策略已落地并通过 Simulator 回归；微信真机、导出和大文件性能待验收。

## 最近变更

- **2026-11-15 — 外部 PDF 导入（#5，部分范围）**：新增系统文件选择器与 Open In 接收（微信可通过其他应用打开，具体界面待真机确认）；复制原件、稳定页 ID、独立可编辑笔迹、裁剪/旋转背景与共享缩放。完整 16 项 Simulator 回归通过，含 50 页及第 2/15/40 页笔迹重开。基线/回滚与 iPad 更新证据见 TEST_PLAN。导出未实现，不关闭 #5。
- **2026-11-15 — 签名恢复**：同身份 Xcode refresh 后用户信任开发者并确认“可以打开了”；原有五个笔记文件逐一哈希不变。SideStore 安装/刷新仍未验收。


- **2026-10-14 — 全屏编辑与手势/橡皮擦（#2，涉及 #3）**：用户已确认黑色笔迹、纵向纸张均正常。继续加入整页双指缩放/移动、整笔与局部擦除、可拖动且左右竖排的悬浮工具栏；翻页与加页合并到右下角。底层笔迹坐标与存储格式不变；8 项自动回归通过，基线与回滚均复现 4 项缺失功能；构建/签名/备份/原位更新/启动通过。验证结果见 TEST_PLAN，新的真机体验待用户确认。

- **2026-10-13 — 墨色/纸张修复（#2，涉及 #3）**：用户报告选黑写白、页面横向铺满。修复将白纸画布固定浅色，颜色不透明；纸张采用固定纵向 210:297 比例，整页等比适配屏幕，旧笔迹不重涂/删除。新增隔离 Simulator 回归；用户随后回复“两项都正常”；这仅确认黑色和纵向纸张，不能据此勾选整个 M1。

- **2026-10-13 — M0 真机启动成功（Issue #1 / PR #7）**：用户确认开发者签名已信任后，复用已安装 App 启动退出 0；后续进程查询退出 0，返回同一 MyNotes 进程。安装、启动、存活检查均有实际命令结果；用户随后回复“已看到界面”，完成 M0 可见界面确认；手写/保存功能未验收。

- **2026-10-13 — M0 真机安装成功（Issue #1 / PR #7）**：复用已签名 App，安装退出 0，设备应用查询退出 0 并返回 MyNotes。启动退出 1，系统提示签名/权限/描述文件信任相关安全拒绝；本地复查签名通过、描述文件未过期且包含目标 iPad、应用与团队标识匹配。尚不能据此认定唯一根因，等待用户检查开发者信任提示；未完成启动和功能验收。

- **2026-10-13 — M0 签名后续验收（Issue #1 / PR #7）**：保留用户生成工程内的本地配置，Simulator 复查退出 0。真机版本首次构建因 `No space left on device` 退出 65；降低并发并关闭本次索引写入后构建退出 0，`codesign --verify --deep --strict` 退出 0。实际安装退出 1，设备提示开发者模式未启用；尚未启动 App，不关闭 #1。

- **2026-10-13 — M0 Mac 首次构建证据（Issue #1）**：在 macOS 26.5（25F71）、Xcode 26.6（17F113）、XcodeGen 2.45.4 上运行 `./scripts/bootstrap.sh` 与 `./scripts/check.sh`，均退出 0，后者输出 `** BUILD SUCCEEDED **`。使用 iOS Simulator SDK 26.5，未改应用代码或工程规格。仅完成构建；签名、iPad 安装启动及功能验收仍待完成。

- **2026-10-13 — GitHub 初始化与源码同步**：私有仓库 `main` 已发布全部 30 个工程、文档及模板文件，并用 GitHub recursive tree 核对；已建 Issues #1–#6。Swift 静态语法与 YAML 解析通过，但 **Xcode 编译和 iPad 真机测试均未执行**。

- **2026-10-13 — Initial local scaffold**：创建工程源文件、项目生成脚本、开发路线、AI 协作规则及交接文档。验证：Swift 静态语法解析和 YAML 格式检查通过；本地 Git 提交；**未验证 Xcode/真机运行**。

## 更新规则

- 每个已合并的 PR 更新这里的一行或一个简短记录；勿把纯计划标记为已完成。
- GitHub Issues 负责细粒度状态，本文件只记录当前总体状态和可核实的证据。
- 任何计划变更应先调整 `ROADMAP.md` 或 `docs/DECISIONS.md`，再调整进度。

## Issue #10 / SideStore local trial (2026-10-14)

- Owner chose the connected local iPad; remote target iPad unavailable.
- PASS: isolated Release iphoneos build and unsigned IPA packaging for trial build 1 and 2; identity/version/arm64/iOS/iPad/no-signature checks; 8 offline validator tests.
- PASS: fresh private existing-note backup; official-linked iloader 2.3.7 asset hash, codesign and notarization checks; USB iPad visible and selected.
- NOT RUN: SideStore account-based installation, initial refresh, trial import, in-place update/data retention, seven-day expiry/refresh, pairing recovery and backup restoration. Owner login/device approvals pending; no secrets in Git.
- No app source, original signing configuration, existing bundle ID or storage format was changed. Separate trial identity is deliberate isolation, not an upgrade of existing MyNotes.
- See [trial procedure](docs/SIDESTORE_TRIAL.md); keep #10 open until device gates are observed.
