# MyNotes-iPad — verified development status

Reviewed: **2026-11-15**. Canonical app is **native SwiftUI + PencilKit + PDFKit**, not PWA. This update reconciles native changes from former stacked PRs #7, #8, #9, #11, #12.

## GitHub Release delivery checkpoint — 2026-11-15

- [Private test prerelease](https://github.com/hamperme/MyNotes-iPad/releases/tag/sidestore-trial-pdf-2026-11-15) exists with **two unsigned arm64 iPad IPA files** for `com.example.mynotes.sidestoretrial`, builds 1 and 2; two manifests; a common SHA256SUMS file. GitHub asset metadata supplies per-asset SHA256 and sizes. Owner reports downloading and verifying all bytes again; this review verified metadata, not the binary independently.
- Release source commit is #12 `7f73f7e4`; App sources/project.yml match current merged main `c274de8f` by Git blob identity. Mac **rebuild not required** for first SideStore trial.
- Windows Codex can download with a private-repo **read-permitted** GitHub account, or owner transfers downloaded assets to iPad/Windows. No GitHub edits required for student. [Release-first runbook](docs/WINDOWS_CODEX_SIDESTORE_DEPLOY.md).
- **NOT RUN:** SideStore signing, actual IPA install, refresh, update preserving test note data, later 7-day refresh. Upload and SHA verification do not satisfy these gates.

## Review and evidence

- **Native build / launch:** PR #7 records macOS 26.5 / Xcode 26.6, Simulator success, signed device build, codesign check, USB install, device process launch, and owner-confirmed visible library UI. Evidence comes from PR logs and docs; ChatGPT did NOT re-run Xcode.
- **Ink/editor:** #8 and #9 report simulator XCTest and iPad signed in-place install, literal black-ink/dark-mode fix, portrait paper, zoom/pinch, floating toolbar and whole-stroke/partial erasers. On-recipient third-party stylus use is NOT tested.
- **Unsigned IPA package:** #11 records Xcode unsigned device IPA builds 1 and 2, validator PASS and **8 Python unit tests**. This is only an unsigned source artifact, NOT a SideStore installation. SideStore first sign/refresh/update still **NOT RUN**.
- **PDF import:** #12 reports **16 Xcode tests** (12 unit + 4 UI), 50-page fixture, independent ink, simulator Open-In and signed owner-iPad install with note-file hash comparison. WeChat's real share sheet, physical Pencil PDF markup, large-file performance, PDF export and remote recipient tests still NOT verified.
- **This integration:** GitHub tree/blob inspection and static reasoning review; no local macOS, iPad device, Windows, signing or actual re-run by ChatGPT. No GitHub Actions status checks on PR tips.
- The reviewed code was imported to a single integration branch instead of merging outdated stacked documentation from #7–#12; the latest main app-routing docs remain intact. The PR review and integration merge are *not* equivalent to new device testing.

## Product stage

| Area | Status | Next |
|---|---|---|
| N0 Mac startup | Verified in previous PR logs (not rerun) | Rebuild integrated main with the Mac |
| N1 Pencil/eraser/lasso | Implemented partially; real recipient pen untested | Test clone pen and palm rejection, especially PencilKit pencilOnly |
| N2 Portrait pages / zoom / floating UI | Editor branch tested on simulator; manual recipient acceptance pending | Third-party pen, zoom and relaunch tests |
| N3 Folder organization | Not implemented | Later issue #4 |
| N4 PDF import | Implemented; test records for owner device and simulator | Real WeChat Open In / PDF export / performance later |
| N5 Safe durable notes and backup/restore | **NOT COMPLETE** | Add visible save failure and restore verification BEFORE real school use |
| D0 SideStore Windows install and 7-day refresh | **NOT RUN** | [Issue #10](https://github.com/hamperme/MyNotes-iPad/issues/10) and [Windows Codex guide](docs/WINDOWS_CODEX_SIDESTORE_DEPLOY.md) |

## Known risks / release blockers

1. SideStore signing, installed bundle ID, first refresh, in-place Trial v1→v2 update, expiry behavior and pairing recovery require actual iPad testing.
2. Current PencilCanvas defaults to **.pencilOnly**; the third-party stylus may be reported as touch even if Goodnotes accepts it. Avoid promising working pen until tested on the student's iPad.
3. NoteStore's normal drawing saving is currently synchronous and reports failure primarily via NSLog, not a recovery UI. A failure can be silent to the student; backups and proper error handling remain required.
4. Index metadata writes for ordinary notes can fail after in-memory state changed. Backup/restore and transactional reliability still to be addressed.
5. PDF export and full backup/restore are not implemented; importing PDF and verified source preservation do not imply release-readiness.
6. Do not uninstall an app that may contain valuable data, change installed Bundle ID or approve certificate revocation silently.

## Next concrete tasks

1. Use already released IPA builds 1 and 2 for current Windows/iPad test; rebuild with Mac Codex only after a code change or if the published artifact fails verification.
2. Windows Codex + student: follow [docs/WINDOWS_CODEX_SIDESTORE_DEPLOY.md](docs/WINDOWS_CODEX_SIDESTORE_DEPLOY.md); first install/refresh SideStore, then Trial-1, then in-place Trial-2; report sanitized statuses to #10.
3. Record any integration bugs before any real class note-taking. Build data backup/restore before production adoption.

Historical native plan: [docs/NATIVE_DEPLOYMENT_PLAN.md](docs/NATIVE_DEPLOYMENT_PLAN.md). All planned tasks remain open until their functional acceptance is actually performed.
