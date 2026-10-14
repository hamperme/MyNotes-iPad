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
| Signed iOS device build | User-configured local project / iOS SDK 26.5 | **Pass** | Lower-I/O retry exit 0; signature verification exit 0 |
| iPad device install | Paired iPad Pro 11-inch (3rd generation) | **Pass** | After Developer Mode enabled: install exit 0; installed-app query exit 0 and MyNotes present |
| iPad app launch | Same iPad | **Pass (process)** | After user confirmed trust: launch exit 0; later process query confirms same MyNotes process |
| Visible app UI | Same iPad; user observation | **Pass (user reported)** | User replied “已看到界面” to the library/new-note screen question; not assistant visual inspection |
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

## M0 signed-device follow-up (2026-10-13, America/Toronto)

- User reported signing configured; the existing generated project was reused without bootstrap/regeneration. Signing identities and device identifiers stay local and are not committed.
- `./scripts/check.sh` against that project: exit 0, `** BUILD SUCCEEDED **`.
- Device build command: `xcodebuild -project MyNotes.xcodeproj -scheme MyNotes -configuration Debug -sdk iphoneos -destination 'generic/platform=iOS' build`: exit 65; first compiler error contained `No space left on device`. Dependent-module failures followed this storage error.
- Changed retry command: same command with `-jobs 2 COMPILER_INDEX_STORE_ENABLE=NO` before `build`: exit 0, final stdout `** BUILD SUCCEEDED **`, stderr empty. No app source or signing configuration was changed to obtain this result; no user files were deleted.
- `codesign --verify --deep --strict APP_PATH`: exit 0, stdout/stderr empty. APP_PATH refers to the local signed Debug-iphoneos/MyNotes.app, not an unsigned archive.
- `xcrun devicectl device install app --device DEVICE APP_PATH --timeout 60 --json-output LOCAL_RESULT`: exit 1. Literal error: `ERROR: The operation failed because Developer Mode is disabled. (com.apple.dt.CoreDeviceError error 10005 (0x2715))`.
- Target inventory: iPad Pro 11-inch (3rd generation), reported iPadOS 26.6.2; device identifiers omitted. The device tunnel was acquired before installation was rejected.
- Current blocker: user must enable Developer Mode on the iPad, restart and confirm, then retry installation of the existing signed build. No App launch or Pencil/persistence tests were performed.
- Device build warnings: AppIntents metadata extraction skipped; all interface orientations must be supported unless full screen is required. These are not runtime acceptance results.
- Local generated settings also report device family `1,2`, whereas tracked project.yml targets `2`; no local user settings were overwritten or committed. Revisit intended iPad-only targeting separately without destroying signing configuration.

## M0 installed-app follow-up (2026-10-13, America/Toronto)

- User reported Developer Mode enabled; reused the existing signed MyNotes.app without rebuilding or regenerating the project.
- `xcrun devicectl device install app --device DEVICE APP_PATH --timeout 60 --json-output LOCAL_RESULT`: exit 0, stdout reports `App installed:`, stderr empty.
- `xcrun devicectl device info apps --device DEVICE --bundle-id BUNDLE_ID --timeout 30 --json-output LOCAL_RESULT`: exit 0; the installed-app result contains MyNotes; stderr empty.
- `xcrun devicectl device process launch --device DEVICE BUNDLE_ID --timeout 60 --json-output LOCAL_RESULT`: exit 1, CoreDeviceError 10002, nested FBSOpenApplicationErrorDomain error 3 / Security. The device says the code signature, entitlements, or explicit user trust may be responsible; this is not a successful launch or a proven single root cause.
- Local follow-up checks: `codesign --verify --deep --strict APP_PATH` exit 0; embedded provisioning profile is unexpired and includes the target iPad; application-identifier and team-identifier match between app entitlements and profile. These checks do not establish on-device trust or exhaust all entitlement checks.
- Next: user inspects their own developer account in Settings → General → VPN & Device Management; confirms trust only for their intended signing account if prompted. If no trust entry appears, obtain the exact alert shown by opening MyNotes. Retry launch after user confirmation; no trust safeguards are bypassed.
- Raw logs remain local because they contain signing and device identifiers. Repository documentation records only sanitized results.
- Still not run: successful app launch, Pencil behavior, page switching/persistence, PDF, backups. Issue #1 remains open.

## M0 successful-launch follow-up (2026-10-13, America/Toronto)

- User reported the developer signing account trusted. Reused the installed app; no reinstallation or rebuild.
- `xcrun devicectl device process launch --device DEVICE BUNDLE_ID --timeout 60 --json-output LOCAL_RESULT`: exit 0; stdout reports the application launched, stderr empty.
- `xcrun devicectl device info processes --device DEVICE --timeout 30 --json-output LOCAL_RESULT`: exit 0; returned the same MyNotes executable and process identifier as the launch result. The check occurred after launch, not merely from a saved build output.
- App installation, launch and process existence are now observed successes. No claim of long-term crash freedom, visible UI correctness or handwriting/persistence acceptance is made.
- User was asked “iPad 上现在是否显示 MyNotes 的笔记列表或新建笔记界面？” and replied “已看到界面”. This is user-reported visual confirmation, not an assistant screenshot inspection. M0 startup acceptance is satisfied; M1 and later functionality remain untested.
- Previous Developer Mode and trust failures are retained above as historical evidence, not current blockers. PR #7 remains open for review; no merge performed.

## Editor ink and portrait regression (2026-10-13)

- User reported black selected but white ink visible, and a landscape-shaped notebook instead of portrait paper. Baseline: commit `55174f839aacf97e07e73800692fcd642a0287fd` (M0 PR #7).
- Same hosted iPad Simulator tests were run against baseline, modified copy and a separately restored rollback copy. Host cases: 1200×800, 800×1200 and 600×900; Dark Mode; black/custom color; synthetic legacy drawing reaching x=1100.
- **BASELINE:** xcodebuild test exit 65; 4 tests / 14 assertions failed. Canvas style=2 (dark), PencilKit black conversion RGB=1,1,1. Landscape logical canvas 1200×661 (ratio 1.8154), with coordinates changing on resize.
- **MODIFIED:** xcodebuild test exit 0; 4 tests, zero failures. Canvas style=1 (light), black RGB=0,0,0; custom color and width remain literal. New paper logical size 595×841.5 at every host size (210:297); templates/ink scale as one sheet. Legacy test drawing expands the sheet to 1127×1594 without changing its saved drawing bytes.
- **ROLLBACK:** embedded rollback executed on a separate modified copy, exit 0, all 30 original tracked-file SHA-256 values restored. Same tests again exit 65 with the same 14 assertions and original black-to-white/landscape behavior. The patch reconstructs the modified copy; rollback is not an iPad downgrade command.
- The delivered `scripts/check-editor.sh SIMULATOR_UUID` was executed after correcting its generated-project path: exit 0, 4 tests / zero failures. A separate generated test project allows reruns without touching the user's signed production project. Run on a dedicated simulator: tests create synthetic notes in the isolated regression bundle.
- Signed device build, `codesign --verify --deep --strict`, in-place iPad installation, launch and subsequent process query all exit 0. Existing app bundle identifier retained; no uninstall performed. Existing notes were backed up locally before updating; private data/signing metadata are not committed.
- Subsequent user confirmation: “两项都正常” for black handwriting and portrait paper/rotation. Broader M1 eraser/lasso/relaunch-persistence acceptance remains open. The follow-up below implements interactive zoom; PDF import/export remains unimplemented.
- Test-harness setup errors (relative source path / explicit Swift self capture / generated test-source path) were observed and repaired in the test tooling; they are retained in the local literal evidence ledger, not attributed to application behavior.

## Full-screen zoom, floating tools and dual erasers (2026-10-14)

- Baseline: PR #8, commit `e89f5c3be2ccf0493b69e09320e2691dba0c6984`. User confirmed black ink and portrait paper, then requested pinch zoom, whole-stroke/partial erasing, full-screen paper, a movable palette that becomes vertical at the sides, and bottom-right page/add controls.
- Environment: Xcode 26.6, dedicated iPad Simulator / iOS 26.5; isolated regression bundle. The same frozen 6 unit + 2 UI test fixtures ran against pristine baseline, modified source and a separate rollback copy. All three runs have matching fixture SHA-256 records in local evidence.
- **BASELINE:** `xcodebuild test` exit 65, 8 tests / 4 failures. Previous black/portrait/legacy-data checks still pass. No zoom viewport or floating toolbar; eraser remains `.vector` with no partial selector.
- **MODIFIED:** `xcodebuild test` exit 0, 8 tests / zero failures. Unit tests verify vector → bitmap → vector switching, remembered eraser mode, fill/fit bounds, stable logical page coordinates and unchanged stored synthetic drawing bytes after zoom/rotation/tool switches. XCUITest injects actual pinch gestures (portrait 103% → 148%, shrink and fit-to-page 100%), a further pinch after requesting rotation, moves the palette to both sides and back, selects both vertical eraser buttons, adds/navigates pages at bottom-right, and returns to the library. Whole-screen test screenshots were visually inspected for white paper, floating controls and unobstructed remaining page space.
- **ROLLBACK:** executable self-contained source rollback exit 0, all 33 pristine tracked-file SHA-256 values restored. Identical tests again exit 65 with the same 4 failures, while the preceding black/portrait repair remains intact. This restores source copies, not iPad note data or an installed app. Original checkout remains unchanged.
- `./scripts/check.sh`: exit 0, `** BUILD SUCCEEDED **`. Signed iphoneos build and `codesign --verify --deep --strict`: exit 0. Generated project copy retains user signing; only explicit orientation keys were added, without regenerating the original signed project. Build-only warnings are not runtime acceptance.
- Before the update, a fresh local app-data backup succeeded. In-place iPad installation, launch and subsequent running-process query all exit 0 on 2026-10-14. Same app identity, no uninstall; private notes, device identifiers and signing logs remain local.
- Development failures retained in local evidence: initial UI-test drag call used an element/coordinate overload incorrectly (compile exit 65); corrected to coordinate-to-coordinate dragging. Several native-zoom attempts recognized pinches but did not advance zoomScale, including a diagnostic copy with canvas input disabled. Final explicit public pinch handling preserves the focal point and passes actual gesture tests. The diagnostic disabled-input code and event counters are not shipped. An unavailable handle icon was replaced with a supported ellipsis.
- **Repository runner / stricter orientation check:** `./scripts/check-editor.sh SIMULATOR_UUID` finally exits 0 with 6 unit + 2 UI tests passing, including rendered landscape orientation and real landscape pinch (205% → 257%). Earlier stricter runs failed because no interface-rotation event arrived, despite the rotation request; opening Simulator alone did not fix this. Restarting the dedicated simulator (shutdown → boot → bootstatus) restored actual portrait/landscape events without any app-source change. Do not silently skip the assertion or infer a fixed product bug from this environment recovery. Retain earlier exit-65 logs; if reproduced, check the simulator environment before changing the app. The shipped source matches the signed app already installed at 09:41.
- **Project routing:** remote main added a PWA pivot during this work. After being asked, the owner explicitly replied “继续原生 iPad 版”; this branch continues native work only, leaves the PWA repository untouched, and requires explicit reconciliation of main’s routing docs at review.
- **Still pending:** user confirmation on the physical iPad of two-finger zoom/pan, actual Pencil whole-stroke vs partial erasing, palette placement and bottom-right page actions. Automated tool-type selection is not proof of pixel-level Pencil erasure quality. Long-session Pencil latency, lasso editing and restart persistence remain separate acceptance; do not close the whole M1/M2 issue.

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
- **T10:** Full-screen editor: pinch in/out, two-finger pan, fit/fill settings, draw and erase at several zoom scales; rotate and verify unchanged ink/template registration. Drag palette left/right (vertical) and center/top/bottom (horizontal). Test page/add overlay at bottom-right; confirm prior pages retain their own ink.

## Build commands

```bash
./scripts/bootstrap.sh
./scripts/check.sh
```

## Test execution log (append newest above older)

| Date | Actor | Test | Device / tool | Result | Details |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Codex | Full-screen zoom, dual erasers, floating palette and paging | Dedicated iPad Simulator + signed iPad update | Automated pass; physical interaction pending | Baseline/rollback 8 tests, 4 failures; modified 8 tests, zero failures. Signed update installed/launched, local backup retained |
| 2026-10-13 | Codex | Black ink / portrait page regression | Dedicated iPad Simulator, iOS 26.5 | Baseline+rollback fail as expected; modified pass | 4 tests; 14 → 0 → 14 assertions. Signed update installed/launched; user subsequently confirmed both fixes |
| 2026-10-13 | Codex | M0 launch after user trust / process query | Same iPad; already installed app | Pass (process only) | Launch/query exit 0 and same process observed; user confirmed visible UI; Pencil/persistence pending |
| 2026-10-13 | Codex | M0 physical iPad install / launch | Same paired iPad; existing signed app | Install pass; launch blocked | Install/query exit 0; launch exit 1 Security; local signature/profile checks passed |
| 2026-10-13 | Codex | M0 signed device build / install | Xcode 26.6; iPad inventory reports 26.6.2 | Build pass; install blocked | First build 65 (disk full), retry 0, codesign 0; install 1 (Developer Mode disabled); launch not run |
| 2026-10-13 | Codex | M0 project generation + unsigned Simulator build | macOS 26.5 / Xcode 26.6 / XcodeGen 2.45.4 | Pass (build only) | Both scripts exit 0; signing and device/runtime checks pending |
| 2026-10-13 | ChatGPT | Xcode & iPad tests | Unavailable in this runtime | Not run | Must be executed on owner's Mac |
