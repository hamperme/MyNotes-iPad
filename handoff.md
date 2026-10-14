# Agent Handoff / 跨助手交接（唯一当前交接入口）

> **Routing conflict discovered 2026-10-14:** remote `main` at `e5fd1d3` pauses this native prototype and redirects active work to `hamperme/maplehub-study`. This branch preserves the already implemented/installed native editor changes only. The owner explicitly replied “继续原生 iPad 版” in this chat after seeing that pivot. Continue this native branch; leave the PWA repository untouched, and resolve routing/document conflicts explicitly during PR review. This branch does not implement or supersede the PWA.
> 供 **Codex、Claude Code、ChatGPT 和人类开发者** 互相审查与接手。每次结束修改前务必更新本文件。若内容和仓库代码冲突，以当前代码/测试/Issue 为准，并先纠正此文件。

## Snapshot

- **Updated:** 2026-10-14
- **Last actor:** Codex (full-screen zoom, movable toolbar and two eraser modes)
- **Repository target:** [`hamperme/MyNotes-iPad`](https://github.com/hamperme/MyNotes-iPad) (private; remote created)
- **Working branch:** `feat/issue-2-zoom-eraser-modes` (stacked on PR #8 at `e89f5c3be2ccf0493b69e09320e2691dba0c6984`)
- **Active task:** Issue #2 / #3 — full-screen zoom, movable tools, dual erasers and bottom-right paging; physical verification after update
- **Issue / PR:** [M1 Issue #2](https://github.com/hamperme/MyNotes-iPad/issues/2), related [M2 Issue #3](https://github.com/hamperme/MyNotes-iPad/issues/3); [current feature PR #9](https://github.com/hamperme/MyNotes-iPad/pull/9) uses `feat/issue-2-zoom-eraser-modes`, stacked on [ink/portrait PR #8](https://github.com/hamperme/MyNotes-iPad/pull/8), which is stacked on [M0 PR #7](https://github.com/hamperme/MyNotes-iPad/pull/7).
- **Actual verification:** User confirmed prior black ink/portrait repair. Current 6 unit + 2 UI regressions pass, including strict rendered-landscape/pinch checks after restarting the dedicated simulator; pristine baseline and restored source both reproduce the same 4 missing-feature failures. All 33 pristine source hashes restored by rollback. Simulator build, signed iphoneos build, signature verification, fresh local note backup, in-place iPad installation, launch and running-process query passed. Physical acceptance of new zoom/pan, both eraser behaviors and palette/paging remains pending; detailed commands/results in TEST_PLAN.
- **Status summary:** M0 startup accepted, PR review pending; basic handwriting skeleton only, not a complete MVP

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

## Previous editor repair (PR #8; user confirmed)

- User reproduced black ink appearing white and landscape-shaped paper. Baseline hosted iPad Simulator tests reproduced both: dark canvas style=2 maps black to RGB 1,1,1; a 1200×800 host yields a 1200×661 canvas.
- Changed `PencilCanvas.makeUIView/updateUIView` to force light paper/opaque literal ink and disable independent scrolling. `NoteEditorView.body/loadPage` now fits fixed portrait paper without rewriting legacy stroke coordinates.
- Regression harness uses a separate bundle ID and dedicated simulator; baseline and rollback reproduce 14 failing assertions, modified passes all 4 tests. Signed build, in-place install, launch and running-process query passed; user subsequently confirmed black ink and portrait layout both normal. Local note backup completed before update. No personal data is committed; original signed checkout and M0 branch stay unchanged.
- Review PR #7 first; repair branch is stacked so its PR should target the M0 branch until that is merged. Do not auto-merge or mark whole M1 complete.

## Current full-screen editor update

- Source baseline is PR #8. User explicitly confirmed black ink/portrait paper, then requested zoom, dual erasers, full-screen paper, movable edge-adaptive palette and bottom-right paging/add. The new branch addresses this scope only.
- Native outer scroll view transforms paper and ink together; fixed logical coordinates and storage remain unchanged. Inner canvas navigation is disabled. Eraser mode maps to vector/bitmap. Floating tools and paging are overlays; no fixed navigation bar consumes page space.
- Tests include actual XCUITest pinch, palette drag to both sides, mode selection, page add/previous/next, rotation and back navigation, in addition to hosted ink/coordinate/legacy-data regressions. See TEST_PLAN for final observed outcomes; physical Pencil erase/persistence acceptance is separate.
- Latest update installed and running on the user’s iPad; do not repeat Developer Mode/trust setup. Ask for physical gesture/eraser/layout feedback, then record it separately from automated results.
- Review this stacked PR after PR #8; do not auto-merge or close the entire M1 issue. Keep raw logs, private note backup and signing identifiers out of Git.

## First task for the next agent

1. Check `git status`, review `AGENTS.md`, `README.md`, `docs/ARCHITECTURE.md`, `docs/TEST_PLAN.md`.
2. Mac generation/build have passed. Re-run `./scripts/check.sh` after source changes; do not replace the recorded successful build with an unverified claim.
3. User has configured signing locally. Preserve the existing generated project; do NOT rerun bootstrap over it. Keep account identifiers, certificates, bundle identity and generated signing configuration out of Git.
4. Installation and launch have now succeeded; do not rebuild/reinstall or repeat trust setup unnecessarily. The user confirmed the notebook/new-note screen is visible. Review PR #7, then take M1 Issue #2 for physical Pencil and restart-persistence checks separately. Do not treat startup acceptance as proof of working handwriting.
5. Record outcomes in `docs/TEST_PLAN.md` (date, device, version, pass/fail) and update `PROGRESS.md` + this document.
6. Review M0 PR #7 and this separate editor repair branch for Issue #2. Black ink and portrait shape are already user-confirmed. Verify the new two-finger zoom/pan, both eraser modes, floating toolbar placement, bottom-right paging and reopen persistence; record user observations separately from automated tests.

## Known gaps / risks

- **Runtime scope:** Simulator UI launch/gestures/layout and signed device install/launch passed. User confirmed prior black/portrait fixes. New physical Pencil erasing, pan/zoom, lasso and persistence still need acceptance.
- **Build resources:** Historical device build failed with `No space left on device`; subsequent builds passed after space became available. No user files/caches were deleted. Keep resource-conscious builds; avoid treating that old failure as a current blocker.
- **Data durability:** no debounce, backup/restore, file recovery, atomic metadata transaction, or storage error UI. Avoid using for irreplaceable notes.
- **Page editing:** add/switch exists; delete/reorder not implemented; zoom added in this branch, physical acceptance pending.
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
| 2026-10-14 | Codex | Full-screen paper, explicit pinch zoom, vector/bitmap erasers, movable adaptive tools and bottom-right paging | 8 regressions pass; baseline/rollback 4 missing-feature failures; signed update backed up/installed/launched | User verifies physical gestures/erasers/layout; review stacked feature PR |
| 2026-10-13 | Codex | Fix literal ink on white paper and portrait sheet layout; add isolated regressions | Baseline/rollback reproduce defects; modified 4 tests pass; signed update installed/launched | User verifies black ink, portrait page and rotation; review stacked fix PR; M1 remains partial |
| 2026-10-13 | Codex | Launched installed MyNotes after user confirmed developer trust; checked running process | Launch exit 0; device process query exit 0 confirms same app process | User confirmed visible UI; review PR #7, then M1 physical Pencil/persistence tests |
| 2026-10-13 | Codex | Installed MyNotes on the iPad; queried installed app; attempted launch | Install/query 0; launch 1 Security. Local signature/profile checks passed; device trust not confirmed | User checks developer trust; retry launch, keep #1 open |
| 2026-10-13 | Codex | Verified signed device build and code signature; attempted actual iPad install | Build retry 0, codesign 0, install 1: Developer Mode disabled; no launch | User enables Developer Mode; retry existing signed app installation, then launch |
| 2026-10-13 | Codex | Verified M0 generation and unsigned Simulator compilation; documentation-only evidence update; no app source or storage changes | Both scripts exited 0 on Xcode 26.6 / macOS 26.5; iPad install and runtime NOT RUN | User selects signing Team/bundle ID, then install and launch on iPad; keep #1 open |
| 2026-10-13 | ChatGPT | Published all 30 source, config, and documentation files to private GitHub main; verified remote tree and Issues #1–#6 | Remote tree count + file fetch, local Swift parse/YAML pass; Xcode/iPad NOT RUN | Issue #1: build on Mac and validate on iPad |
| 2026-10-13 | ChatGPT | Created GitHub repo and issues #1–#6; published initial docs | GitHub writes confirmed; no Xcode build | Mac build for #1 |
| 2026-10-13 | ChatGPT | Initial local source scaffold and collaboration docs | Swift syntax parse + YAML checks + local Git commit; Xcode not available | Mac build, device test, push remote |
