# Agent Handoff / 跨助手交接（唯一当前交接入口）

> 供 **Codex、Claude Code、ChatGPT 和人类开发者** 互相审查与接手。每次结束修改前务必更新本文件。若内容和仓库代码冲突，以当前代码/测试/Issue 为准，并先纠正此文件。

## Snapshot

- **Updated:** 2026-10-13
- **Last actor:** Codex (first verified Mac project generation and unsigned Simulator build)
- **Repository target:** [`hamperme/MyNotes-iPad`](https://github.com/hamperme/MyNotes-iPad) (private; remote created)
- **Working branch:** `feat/issue-1-mac-build-evidence` (based on remote `main` at `25dffffc634d4005922abb0fe53490dec508e9a7`)
- **Active task:** M0 — user signing setup, physical iPad installation and launch
- **Issue / PR:** [M0 Issue #1](https://github.com/hamperme/MyNotes-iPad/issues/1); M1–M5 Issues #2–#6; build-evidence PR on `feat/issue-1-mac-build-evidence`
- **Actual verification:** On macOS 26.5 (25F71), Xcode 26.6 (17F113), XcodeGen 2.45.4: `./scripts/bootstrap.sh` exit 0; `./scripts/check.sh` exit 0 and `** BUILD SUCCEEDED **` (iOS Simulator SDK 26.5, unsigned). **No simulator launch, iPad installation or runtime tests**
- **Status summary:** basic handwriting editor skeleton only; do not claim MVP complete

## What exists now

- `project.yml`: XcodeGen specification for an iPad-only iOS 17+ app.
- `MyNotes/App/MyNotesApp.swift`: SwiftUI entry point.
- `MyNotes/Views/LibraryView.swift`: create and browse notes.
- `MyNotes/Views/NoteEditorView.swift`: basic drawing tools, page picker, paper picker.
- `MyNotes/Components/PencilCanvas.swift`: PKCanvasView with PencilKit tools.
- `MyNotes/Components/PaperBackground.swift`: blank/ruled/grid/dotted display.
- `MyNotes/Models/NoteRecord.swift` & `Services/NoteStore.swift`: editable PKDrawing per page + JSON note index.
- `scripts/bootstrap.sh` and `scripts/check.sh`: generate/build project on Mac.
- `ROADMAP.md`, `PROGRESS.md`, `docs/*`, GitHub collaboration templates.

## First task for the next agent

1. Check `git status`, review `AGENTS.md`, `README.md`, `docs/ARCHITECTURE.md`, `docs/TEST_PLAN.md`.
2. Mac generation/build have passed. Re-run `./scripts/check.sh` after source changes; do not replace the recorded successful build with an unverified claim.
3. User must select their Apple Personal Team and a unique bundle ID in the generated Xcode project. Keep account identifiers, certificates and generated signing configuration out of Git. Re-running bootstrap may overwrite local generated-project signing settings.
4. Set unique bundle ID and Apple Personal Team, install on real iPad; verify pencil/eraser/lasso, page switch, app restart persistence.
5. Record outcomes in `docs/TEST_PLAN.md` (date, device, version, pass/fail) and update `PROGRESS.md` + this document.
6. Work on [Issue #1](https://github.com/hamperme/MyNotes-iPad/issues/1) in a small branch; open PR, update these documents, get review.

## Known gaps / risks

- **Runtime unverified:** Unsigned Simulator build passed; simulator launch, device signing/install, Apple Pencil and persistence tests are still pending. One build warning: `Metadata extraction skipped. No AppIntents.framework dependency found.`
- **Data durability:** no debounce, backup/restore, file recovery, atomic metadata transaction, or storage error UI. Avoid using for irreplaceable notes.
- **Page editing:** add/switch exists; delete/reorder/zoom not implemented.
- **Lasso:** PKLassoTool wired; moving/scaling selected strokes is not verified on a device.
- **PDF:** import/render/overlay/export not implemented. Need a page-ID-to-PDF-page map and coordinate tests.
- **Folders:** not implemented; metadata model will need migration strategy.
- **Undo/redo:** not exposed in UI; plan proper undo ownership in PKCanvasView.
- **Security:** no secrets, signing certificates or user PDFs should be committed.

## Transfer protocol (required for every agent)

Before coding:
- Pull `main`, inspect open PR/Issues and the last commit.
- State the issue ID and exact scope in a branch/PR; do not edit unrelated areas.
- Mark blocked items honestly; do not assume another agent's report is verified.

Before handoff:
- Summarize **change / reason / files / validation commands with results**.
- Write explicit **untested** items; never invent test outcomes.
- Document migration impacts, decisions, open questions, and next actionable step.
- Update `PROGRESS.md`, this file, and relevant Issue/PR **in the same change set**.
- When finished, change `Last actor`, `Active task`, `Working branch`, and `Issue / PR` above.

## Handoff log (newest on top)

| Date | Actor | Work | Verification | Next |
| --- | --- | --- | --- | --- |
| 2026-10-13 | Codex | Verified M0 generation and unsigned Simulator compilation; documentation-only evidence update; no app source or storage changes | Both scripts exited 0 on Xcode 26.6 / macOS 26.5; iPad install and runtime NOT RUN | User selects signing Team/bundle ID, then install and launch on iPad; keep #1 open |
| 2026-10-13 | ChatGPT | Published all 30 source, config, and documentation files to private GitHub main; verified remote tree and Issues #1–#6 | Remote tree count + file fetch, local Swift parse/YAML pass; Xcode/iPad NOT RUN | Issue #1: build on Mac and validate on iPad |
| 2026-10-13 | ChatGPT | Created GitHub repo and issues #1–#6; published initial docs | GitHub writes confirmed; no Xcode build | Mac build for #1 |
| 2026-10-13 | ChatGPT | Initial local source scaffold and collaboration docs | Swift syntax parse + YAML checks + local Git commit; Xcode not available | Mac build, device test, push remote |