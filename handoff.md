# Cross-agent handoff — MyNotes native iPad app

**Updated:** 2026-10-14  
**Last actor:** ChatGPT — direction/issue/docs update only  
**Canonical repo:** https://github.com/hamperme/MyNotes-iPad  
**Product:** independent native iPad app, SwiftUI + PencilKit + PDFKit. **PWA is cancelled.**  
**Current branch:** main (documentation and issue changes)  
**Active work:** [#1 Mac build](https://github.com/hamperme/MyNotes-iPad/issues/1) + EARLY delivery gate [#10 SideStore feasibility](https://github.com/hamperme/MyNotes-iPad/issues/10).  
**Actual verification:** GitHub docs/Issues updated; Apple and SideStore docs researched. **No Xcode build, installable IPA, SideStore installation, real iPad input test, backup or restore executed.**

## Recipient logistics

- Developer: Mac available.
- Student: in Mississauga, **iPad only**, third-party Pencil works in Goodnotes/Notability according to user.
- No paid Apple Developer Program and no public App Store listing.
- **A computer physically paired to the student's iPad is necessary for first SideStore setup**; may be needed later if pairing file fails. Do not claim zero-touch remote install.
- SideStore uses 7-day signing refreshed on-device; auto-refresh cannot be guaranteed. Apple free Personal Team expires after 7 days.

## Next agent's first task

1. Pull current main, read [docs/NATIVE_DEPLOYMENT_PLAN.md](docs/NATIVE_DEPLOYMENT_PLAN.md), PROGRESS.md, AGENTS.md, ROADMAP.md, relevant source and open PRs.
2. Run on **actual Mac**: `./scripts/bootstrap.sh`, `./scripts/check.sh`. Fix build issues under #1; report exact Xcode version and commands.
3. Identify and test IPA export/build path without paid Apple Developer Program. Do **not** claim archive/export works without actual test.
4. Prepare SideStore installation/refresh test instructions and realistic requirements under #10. Arrange first pairing with a temporary trusted computer physically accessible to student's iPad; if impossible, mark BLOCKED rather than invent an OTA-only path.
5. Then test `PKCanvasView` with third-party Pencil using both `.pencilOnly` and `.anyInput`, recording palm rejection and lasso.
6. Maintain a strict 'not for irreplaceable class notes' warning until backup/restore is proven.

## Work already in repository

Current project includes editable PKDrawing, paper templates, page switch/create and basic editor scaffold; these are **draft source implementations, not proven working app features**. Original PWA documents in https://github.com/hamperme/maplehub-study are archived history; original StudyHub website remains a separate site.

## Non-negotiable collaboration rules

- Do not ask for or store student's Apple Account password, signing keys, device pairing files, private PDFs or notes in GitHub.
- Work in one Issue branch per task; PR reviews and actual test commands/results.
- Never change app Bundle ID unnecessarily, uninstall to upgrade, or overwrite notebook data. Add backup/restore before relying on update/re-sign cycle.
- Every change updates PROGRESS.md and this handoff, including files changed, tests PASS/FAIL/NOT RUN, migration impacts and the next exact action.
- Use [deployment plan](docs/NATIVE_DEPLOYMENT_PLAN.md) for installation facts. Do not represent the PWA as still active.

## Handoff log (newest first)

| Date | Actor | Work | Verified | Next |
|---|---|---|---|---|
| 2026-10-14 | ChatGPT | Reinstated native plan, revived native Issues and added SideStore feasibility task | GitHub docs/Issues only; NO Xcode/device test | Issue #1 build; #10 SideStore feasibility and physical pairing plan |
| 2026-10-14 | ChatGPT | Earlier PWA plan created in maplehub-study (now superseded) | No PWA code built | Native-first per latest owner request |
