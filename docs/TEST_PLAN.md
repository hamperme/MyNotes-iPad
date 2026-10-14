# Test plan / 验收记录

## Evidence rules

For every test: record **date, actor, device, OS, Xcode version, command/action, result, notes**. Do not turn `Not run` into `Pass` unless tested. Android/web evidence is not valid for Apple Pencil behavior.

## Current evidence (2026-10-13)

| Check | Environment | Status | Evidence |
| --- | --- | --- | --- |
| Source files & docs created | Local non-macOS environment | Prepared | Static Swift syntax parse (`swiftc -frontend -parse`) and YAML parsing passed; no iOS typecheck |
| Git initial commit | Local git CLI | Completed | `git log -1` / repository archive |
| Xcode project generation | Mac required | **Not run** | Need XcodeGen |
| iOS simulator build | Mac required | **Not run** | `./scripts/check.sh` |
| iPad device install | Mac + iPad required | **Not run** | Xcode Run |
| Apple Pencil ink, eraser, lasso | iPad + Pencil required | **Not run** | M1 test |
| App restart & drawing persistence | iPad required | **Not run** | M1 test |

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
| 2026-10-13 | ChatGPT | Xcode & iPad tests | Unavailable in this runtime | Not run | Must be executed on owner's Mac |
