# MyNotes-iPad — Codex / Claude / ChatGPT current handoff

**Updated:** 2026-11-15  
**Current work:** integrate formerly stacked PRs #7 #8 #9 #11 #12 without importing outdated project-direction docs. **Native app remains canonical; PWA cancelled.**  
**Canonical repo:** https://github.com/hamperme/MyNotes-iPad  
**Deployment feasibility:** [Issue #10](https://github.com/hamperme/MyNotes-iPad/issues/10).  
**Runbook for brother's Windows Codex:** [docs/WINDOWS_CODEX_SIDESTORE_DEPLOY.md](docs/WINDOWS_CODEX_SIDESTORE_DEPLOY.md)

## Test truth

- Previous contributors report real Mac/owner-iPad and Simulator tests (recorded in PR bodies and docs/TEST_PLAN.md), including 16 XCTest tests for PDF import, 8 validator tests, signed in-place device install with previously stored test data preserved.
- **ChatGPT review here is code inspection and GitHub ref/tree comparison only. Xcode, SideStore and recipient device NOT RUN in this review.**
- Installation/refresh via SideStore, real WeChat share sheet, third-party Pencil, complete backup/restore, full PDF export are **NOT DONE**. Do not imply they passed.

## Current constraints

- Developer owns Mac; recipient brother has **Windows PC + iPad**, no Mac, in Mississauga; his clone stylus works in Goodnotes/Notability (owner's report), not yet tested with this PKCanvasView.
- No paid Apple Developer Program. Apple free app signatures expire in seven days; SideStore requires initial Windows pairing and may need re-pairing.
- Preserve signed existing app and private notes. Use distinct MyNotes Trial Bundle ID for experiment. **No uninstall or overwrites**. Apple sign-in/2FA and device trust are exclusively the human user's actions.
- Main at previous baseline used stale "never built" statement, but earlier stacked PRs document actual testing. This integration preserves current instructions and acknowledges verified previous evidence.

## Change set

The integration takes 26 code, test and historical technical docs files from PR #12 final branch, covering PDF importer and stable per-page ink, full-screen portrait editor, colors, lasso, eraser modes, unsigned IPA packaging and tests. It adds the Windows Codex SideStore deployment guide and reconciles README/PROGRESS/handoff; it preserves current AGENTS.md/CLAUDE.md/ROADMAP.md and native deployment route in main.

## Required next steps

1. On Mac, pull current merged main; run build/test/packager with a separate clean output directory. Add actual run results to the Issue and docs.
2. Windows Codex and student follow the complete runbook; **first manually refresh SideStore before installing Trial IPA**, then test Trial build 1 → 2 retaining disposable notes.
3. If actual third-party stylus produces no ink, investigate PencilKit `.pencilOnly` vs `.anyInput` plus palm rejection. Do not switch untested silently.
4. Complete backup/restore + visible saving errors prior to using this app for irreplaceable class notes.
5. Keep one task per PR, update PROGRESS.md and handoff.md with actual commands and verification, not assumptions.

## Safety

Never collect/sign into student's Apple Account or transmit pairing files, certificates, backup notes, UDIDs, passwords, or full device logs in GitHub. A ZIP-validated unsigned IPA is not evidence of successful SideStore signing, install or refresh.

## Log

| Date | Actor | Outcome | Verification | Next |
|---|---|---|---|---|
| 2026-11-15 | ChatGPT | Static code review and integrated 5 stacked PR changes; authored Windows Codex deployment runbook | GitHub file/commit/tree inspection; prior PR test evidence; macOS/iPad/Windows not run by reviewer | Build merged main on Mac; first SideStore sign/refresh on student's device |
| 2026-10-14 | Codex (per PR records) | Native Mac/iPad build, editor and IPA packaging prototype | See #7–#11 PR tests and docs/TEST_PLAN.md | On-device SideStore trial |
