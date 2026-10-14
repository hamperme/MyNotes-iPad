# Project Progress / 项目进度

Last reviewed: **2026-10-13**  
Overall: **Mac project generation and unsigned Simulator build passed; device installation and runtime tests pending**
Next milestone: **M0 — compile and run on physical iPad**

| 阶段 | 状态 | 当前完成内容 | 完成标准 |
| --- | --- | --- | --- |
| M0 工程启动 | 🟡 构建通过，待真机 | XcodeGen 工程生成及无签名 Simulator 构建成功 | Mac Xcode 构建成功、iPad 安装启动 |
| M1 PencilKit 手写 | 🟡 代码草稿 | 画笔、橡皮擦、基础套索、颜色/笔粗、本地保存 | Pencil 真机顺滑使用，重启不丢数据 |
| M2 多页与模板 | 🟡 部分实现 | 可新增/切换页面及四种模板 | 页面删除/排序、模板位置与笔迹对齐可靠 |
| M3 笔记管理 | ⚪ 未开始 | 仅简单笔记列表/新建 | 文件夹、重命名、删除与恢复策略 |
| M4 PDF 批注 | ⚪ 未开始 | 已选 PDFKit + PencilKit 方案 | 导入、多页坐标正确、批注可编辑、PDF 导出 |
| M5 稳定性与备份 | ⚪ 未开始 | 原子写入笔迹/索引的基础实现 | 撤销/重做、错误提示、备份/恢复、压力回归 |

## 现在的主要阻塞项

1. Mac 工程生成和无签名 Simulator 构建已通过；尚需用户配置 Personal Team 与唯一 Bundle ID，再完成 iPad 安装启动。
2. M0–M5 Issues #1–#6 保持未完成；Simulator 构建不等于运行或 Apple Pencil 功能验收。
3. 保存失败目前仅写日志、没有用户可见提示；正式记笔记前必须补上。
4. PDF 页面可编辑笔迹层的坐标与缩放策略还未落地。

## 最近变更

- **2026-10-13 — M0 Mac 首次构建证据（Issue #1）**：在 macOS 26.5（25F71）、Xcode 26.6（17F113）、XcodeGen 2.45.4 上运行 `./scripts/bootstrap.sh` 与 `./scripts/check.sh`，均退出 0，后者输出 `** BUILD SUCCEEDED **`。使用 iOS Simulator SDK 26.5，未改应用代码或工程规格。仅完成构建；签名、iPad 安装启动及功能验收仍待完成。

- **2026-10-13 — GitHub 初始化与源码同步**：私有仓库 `main` 已发布全部 30 个工程、文档及模板文件，并用 GitHub recursive tree 核对；已建 Issues #1–#6。Swift 静态语法与 YAML 解析通过，但 **Xcode 编译和 iPad 真机测试均未执行**。

- **2026-10-13 — Initial local scaffold**：创建工程源文件、项目生成脚本、开发路线、AI 协作规则及交接文档。验证：Swift 静态语法解析和 YAML 格式检查通过；本地 Git 提交；**未验证 Xcode/真机运行**。

## 更新规则

- 每个已合并的 PR 更新这里的一行或一个简短记录；勿把纯计划标记为已完成。
- GitHub Issues 负责细粒度状态，本文件只记录当前总体状态和可核实的证据。
- 任何计划变更应先调整 `ROADMAP.md` 或 `docs/DECISIONS.md`，再调整进度。