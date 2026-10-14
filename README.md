# MyNotes-iPad

自用的原生 iPad 手写笔记 App，目标是以 SwiftUI + PencilKit + PDFKit 实现 Notability 常用功能，但不复制商标、专有素材或代码。**仓库默认建议设为 Private，不上架 App Store。**

> **当前状态（2026-10-13）**：已准备可本地生成 Xcode 工程的源码骨架（单页书写、工具切换、模板、多页追加、文件保存）。**已通过 Simulator 和签名真机版本构建，并在 iPad 安装、启动成功；设备进程查询确认运行，用户已确认看到笔记界面；手写/保存功能尚待验收**。PDF 批注、笔记分类等仍未实现。请先阅读 [PROGRESS.md](PROGRESS.md) 和 [handoff.md](handoff.md)。

## 功能范围（MVP）

- [ ] Apple Pencil 手写与擦除（基础实现，等待真机验收）
- [ ] 画笔颜色和粗细（基础实现，等待真机验收）
- [ ] 空白、横线、方格、点阵纸（基础实现，等待真机验收）
- [ ] 多页笔记（只实现新增/切换；删除、排序尚未实现）
- [ ] 笔记分类 / 文件夹（未实现）
- [ ] PDF 导入和逐页可编辑批注（未实现）
- [ ] 套索选择 / 移动 / 缩放（接入 PKLassoTool；需要真机验证操作能力与缩放需求）
- [ ] 撤销/重做、自动保存优化、PDF 导出与可靠备份（未实现）

## 快速开始（Mac）

1. 安装 Xcode（需支持你的 macOS 与目标 iPadOS）。
2. 安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen)：`brew install xcodegen`（若无 Homebrew，参阅其官方安装说明）。
3. 在仓库根目录运行 `./scripts/bootstrap.sh`，生成 `MyNotes.xcodeproj`。
4. 在 Xcode 打开项目，进入目标 **MyNotes → Signing & Capabilities**：勾选 **Automatically manage signing**，选择你的 Personal Team，并把 `PRODUCT_BUNDLE_IDENTIFIER` 调整为唯一值，例如 `com.yourname.mynotes`。
5. 连接 iPad，启用开发者模式，选择 iPad 为运行目标，按 `⌘R` 安装。免费 Personal Team 签名通常需要每 7 天重新签名。
6. 可在 Mac 上运行 `./scripts/check.sh` 执行无签名 Simulator 构建。2026-10-13 已在 Xcode 26.6（17F113）/ iOS Simulator SDK 26.5 构建通过；这不代表模拟器启动、真机安装或手写功能已验收。失败时请建立 Issue 并记录报错。

> 启动工程不包含已生成的 `.xcodeproj`；这是有意设计，避免多人使用不同 Xcode 版本时出现工程文件冲突。

## 进度与协作——所有 Agent 都必须遵守

| 文档 | 单一职责 |
| --- | --- |
| [PROGRESS.md](PROGRESS.md) | 面向人的当前里程碑进度和阻塞项（保持简短） |
| [handoff.md](handoff.md) | **当前唯一交接入口**：谁做了什么、验证证据、接手下一步 |
| [ROADMAP.md](ROADMAP.md) | 功能范围、验收标准及推荐开发顺序 |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 模块边界、数据保存与 PDF 批注策略 |
| [docs/DECISIONS.md](docs/DECISIONS.md) | 关键技术决策与原因（ADR） |
| [docs/TEST_PLAN.md](docs/TEST_PLAN.md) | 编译、真机与回归验收矩阵 |
| GitHub Issues / Pull Requests | 具体任务的状态与代码审查，创建远程仓库后启用 |

**原则：Issue 是任务级真相，PR/Commit 是代码级证据，PROGRESS 是摘要，handoff 是当前工作交接。** 不要在多个文档维护互相矛盾的勾选状态。

## 给 Codex / Claude Code / ChatGPT 的指令

1. 开始工作先读 `AGENTS.md`、`handoff.md`、`PROGRESS.md`、`ROADMAP.md` 和相关代码。
2. 一次只领一个 Issue；先查已有分支、PR 与 handoff 的 `Active task`，避免重复开发。建议 `feat/issue-<N>-short-name` 分支。
3. 不要声称已在 iPad、Xcode 或 CI 验证，除非真的执行并记录工具与结果。
4. 做完修改：运行能运行的检查，写明无法运行的检查；创建或更新 PR / Issue。
5. **同一个提交中更新 `handoff.md` 和 `PROGRESS.md`**（必要时更新 `docs/DECISIONS.md`），标记下一位接手者的第一步。
6. 不直接提交私有证书、个人笔记、Apple ID、签名凭据、未脱敏 PDF 等。

## GitHub 远程与后续同步

当前远程仓库：**[hamperme/MyNotes-iPad](https://github.com/hamperme/MyNotes-iPad)**（Private）。里程碑 Issues 已创建：[M0 #1](https://github.com/hamperme/MyNotes-iPad/issues/1) 至 [M5 #6](https://github.com/hamperme/MyNotes-iPad/issues/6)。

推荐在 Mac 上直接 `git clone https://github.com/hamperme/MyNotes-iPad.git`，然后运行 `./scripts/bootstrap.sh`。后续修改通过独立分支和 PR 合并到 `main`，每个 PR 同时更新 `PROGRESS.md` 和 `handoff.md`。

> 首次 GitHub 初始化使用 GitHub 连接，云端提交 SHA 与早期离线 Git 提交 SHA 可能不同；请以远程 `main` 为标准，不要强制推送旧离线历史。

## 项目安全边界

仅供自用、不上架。App 的笔迹暂时只保存在本地 Application Support 容器。卸载 App 可能删除数据；**正式使用之前必须完成可恢复备份和数据迁移测试**。