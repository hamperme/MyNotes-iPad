# MyNotes-iPad — native iPad app and remote no-fee installation plan

**Date:** 2026-10-14  
**Status:** chosen direction, **planning only**. The Swift/Xcode scaffold exists but has NOT been built on macOS and has NOT been tested on the student's iPad.

## Goal and non-negotiable constraints

- Build a **real standalone native iPad app** (SwiftUI + PencilKit + PDFKit). The user wants an app icon and app-like native usage, **not** a PWA/browser window.
- Mac available to the developer. The student lives separately in Mississauga, owns an iPad and a third-party stylus, but **no Mac/computer**. Native Goodnotes/Notability reportedly work with that stylus; actual PencilKit behavior still requires validation.
- Do **not** require the USD $99/yr Apple Developer Program, and do not submit to App Store.
- Preserve user notes across installation, app upgrades, resuming after missed refresh, and storage errors. Data durability is a hard requirement.
- The existing learning site https://maplehub.study stays operational as a separate StudyHub and could later optionally host a release download/help page. A domain **does not bypass iPad app signatures**.

## Distribution reality — no false "permanent sideload" promise

Apple's official free Personal Team provisioning profiles expire after **7 days**: https://developer.apple.com/help/account/basics/about-your-developer-account. An independently installed native app does not become permanently usable simply because the .ipa is uploaded to maplehub.study.

**Primary experimental distribution: SideStore**, https://docs.sidestore.io/docs/installation/install (third-party sideload tool, not an Apple-official distribution program).
- SideStore installs and re-signs an IPA with the user's free Apple account and local-device mechanism; refresh apps within each 7-day period, possibly automatic, not guaranteed.
- **Crucial first-time blocker:** SideStore requires a computer (Mac or Windows) physically paired to **the student's iPad** for initial setup and pairing file. Developer's remote Mac, without the iPad connected, is insufficient. The student may need to borrow a trusted computer locally one time, or send/bring iPad for setup. Developer must not request or store student's Apple Account password.
- **Crucial ongoing blocker:** pairing files may expire or become invalid, sometimes unexpectedly or after iPadOS updates/resets; SideStore would then need computer access again. Source: https://docs.sidestore.io/docs/advanced/pairing-file.
- Test SideStore and each signing/update flow with disposable data **before** using the app for schoolwork. If missing a refresh stops launch, do not advise deleting the app: preserve data and backup first.
- Alternate last-resort no-subscription delivery is a **shared Swift Playgrounds app project** run in Swift Playground itself; per Apple docs it launches in its own window, but does **not** satisfy independent install / home-screen app icon requirement. https://support.apple.com/en-gb/guide/playgrounds-ipad/itc650868b1f/ipados

**Gate:** If no temporary computer can ever be paired with the student's iPad, do not represent SideStore deployment as ready. With all strict constraints simultaneously (zero Apple fee, standalone native app, no computer ever at recipient, permanent no-re-sign), there is currently no supported reliable general-purpose installation path.

## Implementation structure

- Keep current project as canonical app: MyNotes/App, Models, Services, Components; use XcodeGen to generate .xcodeproj.
- SwiftUI for note library/folders/editor UI.
- PencilKit PKCanvasView for handwriting, eraser, ink options, selection; test third-party stylus with `.pencilOnly` AND `.anyInput` drawing policy since native Goodnotes compatibility does **not** prove PencilKit will classify it as Apple Pencil.
- Paper rendering is separate from editable PKDrawing; page IDs stable.
- PDFKit reads immutable PDF originals with editable per-page overlays; PDF export renders a derived copy, never destroys source.
- Persist locally, add versions/migrations/error reporting, and implement export-to-Files/iCloud Drive and import/restore. Do not trust iPad app container as an irreplaceable sole copy.

## Phases, checks and ownership

| Order | Issue | Work | Gate to pass |
|---|---|---|---|
| N0 | [#1](https://github.com/hamperme/MyNotes-iPad/issues/1) | Xcode build, signing-independent local app compilation | Actual Mac build, logged exact commands/errors; never claim build tested until run |
| N1 | [#2](https://github.com/hamperme/MyNotes-iPad/issues/2) | Stylus, eraser, pen sizes/colors, lasso on student's iPad | Student's third-party pen and palm rejection pass in native PKCanvasView |
| N2 | [#3](https://github.com/hamperme/MyNotes-iPad/issues/3) | Pages + ruled/grid/dotted templates | 20 pages survive relaunch with correct ink |
| N3 | [#4](https://github.com/hamperme/MyNotes-iPad/issues/4) | Folders/library | Notebook metadata and folder migration pass |
| N4 | [#5](https://github.com/hamperme/MyNotes-iPad/issues/5) | PDF import + annotation + export | 50-page PDF, edits on 2/15/40 remain aligned |
| N5 | [#6](https://github.com/hamperme/MyNotes-iPad/issues/6) | Durable save, undo/redo, backup/restore | Export and restore using Files tested on iPad |
| D0 | [#7](https://github.com/hamperme/MyNotes-iPad/issues/10) | Build/install/refresh via SideStore (or another no-subscription route) | Real installed icon, reopen, in-place IPA update, 7-day refresh, pairing-recovery documented |

D0 hardware feasibility should be evaluated EARLY (in parallel with N0), before large engineering investment. D0 final regression depends on installable app + persistence validation. Target first native proof: working handwriting view compiled on Mac -> temporary remote install -> student third-party Pencil test.

## Build and IPA packaging exploration

1. Mac: `brew install xcodegen`, `./scripts/bootstrap.sh`, `./scripts/check.sh`. Fix any Xcode compile errors and capture toolchain versions.
2. For SideStore distribution, determine reproducible IPA build path **without a paid distribution certificate**. A possible experimental route is device-target build with code signing disabled -> package the built .app inside `Payload/` as an .ipa -> install/re-sign via SideStore. **Not yet verified**, may require adjustments to entitlements/frameworks and current Xcode/iPadOS. Never imply the current repo already exports a working IPA.
3. SideStore installation instructions should be verified against its official guide and recorded with software versions; user personally handles Apple Account sign-in, device trust and developer mode. No Apple ID sharing.
4. Upload versioned binary only after reproducible build and reproducible backup test; private GitHub Releases or controlled distribution can transport the .ipa, but a website link does not independently install it.
5. Upgrade with same Bundle ID; verify data survives update, expiry/refresh, missed refresh, and pairing-file refresh. Test with a disposable notebook and an exported backup.

## Risk / rollback

- Third-party stylus might not be reported as Pencil to PencilKit; accommodate selectable finger drawing only if palm rejection remains acceptable.
- SideStore is not official Apple distribution and may break after iPadOS updates. Do not represent this as a zero-maintenance choice.
- Both PWA and native work so far are only planning/scaffold; no truthful on-device build evidence.
- Retain archived PWA documents in https://github.com/hamperme/maplehub-study for history only; its website stays untouched.
- For no-computer-ever receiver, stop and discuss the physical setup requirement rather than shipping an uninstallable IPA.

## Agent protocol

This is now the **canonical native app** repo. Start at `handoff.md` and `PROGRESS.md`; one Issue/PR at a time, report checks run and NOT RUN. Keep `docs/NATIVE_DEPLOYMENT_PLAN.md` aligned with deployment evidence. Never store user PDFs, account credentials, certificates, provisioning assets or personal notes in GitHub. Do not claim SideStore, build/export, backup or iPad tests are complete without evidence.
