# Test plan / 验收记录

## Evidence rules

For every test: record **date, actor, device, OS, Xcode version, command/action, result, notes**. Do not turn `Not run` into `Pass` unless tested. Android/web evidence is not valid for Apple Pencil behavior.

## Current evidence (2026-10-13)

| Check | Environment | Status | Evidence |
| --- | --- | --- | --- |
| Source files & docs created | Local non-macOS environment | Prepared | Static Swift syntax parse (`swiftc -frontend -parse`) and YAML parsing passed; no iOS typecheck |
| Git initial commit | Local git CLI | Completed | `git log -1` / repository archive |
| Xcode project generation | macOS 26.5 / XcodeGen 2.45.4 | **Pass** | `./scripts/bootstrap.sh`, exit 0; generated `MyNotes.xcodeproj` |
| iOS simulator build | Xcode 26.6 / Simulator SDK 26.5 | **Pass** | `./scripts/check.sh`, exit 0; `** BUILD SUCCEEDED **`; unsigned Debug generic Simulator |
| iPad device install | Mac + iPad required | **Not run** | Xcode Run |
| Apple Pencil ink, eraser, lasso | iPad + Pencil required | **Not run** | M1 test |
| App restart & drawing persistence | iPad required | **Not run** | M1 test |

## M0 Mac build evidence (2026-10-13, America/Toronto)

- Actor: Codex. Baseline: remote `main` commit `25dffffc634d4005922abb0fe53490dec508e9a7`.
- Host: macOS 26.5 (25F71); Xcode 26.6 (17F113); XcodeGen 2.45.4. Existing tools were reused, not reinstalled.
- Inputs: unchanged `project.yml` and Swift sources; scheme MyNotes, Debug, `-sdk iphonesimulator`, `-destination 'generic/platform=iOS Simulator'`, `CODE_SIGNING_ALLOWED=NO`; no stdin.
- `./scripts/bootstrap.sh`: exit 0, stdout reports project generation; stderr empty.
- `./scripts/check.sh`: exit 0, final stdout `** BUILD SUCCEEDED **`; stderr empty. The stdout includes `warning: Metadata extraction skipped. No AppIntents.framework dependency found.`
- Device discovery reported a paired, available iPad Pro 11-inch (3rd generation); this is discovery only, not installation evidence. Its iPadOS version was not recorded. No device identifiers or account information are included here.
- Xcode open command succeeded. Personal Team and unique Bundle ID still require user setup; no signing credentials were read or changed.
- Not run: Simulator launch/UI tests, iPad installation/launch, Apple Pencil tools, persistence/relaunch, PDF, backup/restore. Issue #1 stays open.
- No application code, data format or project specification changes were necessary for this build.

## Manual test matrix

- **T01:** Create note → draw 20 strokes → change color/width → draw more → verify variation.
- **T02:** Erase part/all of several strokes; confirm remaining strokes remain editable.
- **T03:** Lasso select + move stroke(s); try resize and record available native behavior.
- **T04:** Change paper between blank/ruled/grid/dotted; strokes keep position/identity.
- **T05:** Create 20 pages and place distinct content on pages 1, 10, 20. Close/reopen; all retained.
- **T06:** Simulate abrupt app exit while drawing; reopen and inspect for corrupt index/ink loss.
- **T07:** Import 50-page PDF, annotate pages 2/15/40, zoom/pan/rotate. Reopen and export; coordinates should match.
- **T08:** Backup → delete/reinstall only **after backup** → restore → all metadata and drawings identical.
- **T09:** Confirm no unexpectedly generated network traffic or user document files committed to Git.

## Build commands

```bash
./scripts/bootstrap.sh
./scripts/check.sh
```

## Test execution log (append newest above older)

| Date | Actor | Test | Device / tool | Result | Details |
| --- | --- | --- | --- | --- | --- |
| 2026-10-13 | Codex | M0 project generation + unsigned Simulator build | macOS 26.5 / Xcode 26.6 / XcodeGen 2.45.4 | Pass (build only) | Both scripts exit 0; signing and device/runtime checks pending |
| 2026-10-13 | ChatGPT | Xcode & iPad tests | Unavailable in this runtime | Not run | Must be executed on owner's Mac |
