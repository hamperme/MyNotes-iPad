# Architecture decision log

## ADR-001 — Native SwiftUI + PencilKit, not a web wrapper (2026-10-13)
**Status:** accepted for prototype.  
**Reason:** Native PencilKit drawing/eraser/lasso behavior and low latency matter more than cross-platform portability.  
**Consequence:** Must build/test with Mac Xcode and an iPad.

## ADR-002 — Editable per-page strokes separated from background/PDF (2026-10-13)
**Status:** accepted.  
**Reason:** Supports future edits, erasing, moving strokes, template changes and PDF export without destroying original documents.  
**Consequence:** Maintain stable per-page identifiers and coordinate transforms.

## ADR-003 — XcodeGen for reproducible project scaffold (2026-10-13)
**Status:** accepted for prototype, revisit after first Mac build.  
**Reason:** Avoid merging generated `.pbxproj` project-file noise and allow agents to collaborate via plain text.  
**Consequence:** Mac contributors run `brew install xcodegen` once, then `./scripts/bootstrap.sh`.

## ADR-004 — JSON index + drawing files for first prototype (2026-10-13)
**Status:** provisional.  
**Reason:** Low complexity for first handwritten-page smoke test.  
**Consequence:** Must decide SwiftData migration, proper backup/recovery, error handling and async persistence before long-term use.

## ADR-005 — GitHub is canonical collaboration hub (2026-10-13)
**Status:** accepted.  
**Reason:** Issues record tasks, PRs/commits record reviewed changes, `handoff.md` bridges agents without losing context.  
**Consequence:** Every contribution updates `handoff.md` and `PROGRESS.md`, with explicit evidence.


## 2026-10-13 — Fixed white portrait paper and literal ink (Issues #2 / #3)

White paper uses a light-only PKCanvasView so PencilKit does not invert black ink in Dark Mode. Resolve picker colors in light traits and disable opacity selection. Only the paper/canvas is forced light; surrounding app chrome follows system appearance.

New blank paper uses a fixed 595 × 841.5 logical coordinate space (210:297 portrait aspect). Scale the complete paper plus ink to fit the available viewport with a margin, border and shadow; rotation/resizing never changes stroke coordinates. Disable independent PKCanvasView scrolling/zooming to keep templates registered to ink. Interactive zoom is deferred; this is a portrait notebook sheet, not implemented PDF import/export.

Legacy viewport-sized drawings are not transformed or re-encoded for layout. On page load, expand the logical portrait sheet to contain existing positive-coordinate ink bounds plus a margin, then fit it uniformly. No storage schema change or automatic migration; test covers a 1,100-point-wide legacy stroke retaining original bytes. Negative-coordinate legacy ink is not migrated. Revisit a versioned page-size model before adding persistent zoom/crop/page-size options.

Reference: Apple’s [Introducing PencilKit](https://developer.apple.com/videos/play/wwdc2019/221/) explains dark-appearance ink conversion and opting out with `overrideUserInterfaceStyle`; verified here with the platform color conversion API and actual canvas traits.
