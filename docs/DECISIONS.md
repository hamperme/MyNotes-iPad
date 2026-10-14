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

## 2026-10-13 — Full-screen paper viewport and movable tools (Issues #2 / #3)

The user confirmed the preceding black-ink and portrait fixes, then requested pinch zoom, whole-stroke/partial erasing, full-screen paper, movable edge-adaptive tools, and bottom-right page/add controls. This supersedes the previous fit-only, fixed-chrome layout; it is not PDF import/export.

Keep logical portrait coordinates and the existing drawing storage unchanged. A native outer UIScrollView pans and scales the complete paper+ink hosting view; disable the inner PKCanvasView scroll/pinch gestures so they cannot compete. Actual XCUITest pinches were recognized but did not advance the outer native zoom scale, even with canvas hit testing disabled in a diagnostic copy. The final viewport therefore uses its own public UIPinchGestureRecognizer to set the native zoom scale and preserve the pinch focal point; it does not modify or enumerate private PencilKit subviews. Default to filling the viewport without stretching; excess paper is reachable by two-finger panning. Minimum zoom fits the entire page. Settings offer explicit fit/fill actions. Retain relative user zoom and visible center on rotation; a new page starts at the selected fit/fill mode. Finger input navigates, Apple Pencil still writes.

The floating palette is moved by its dedicated handle, not by dragging tool buttons. It becomes vertical within 90 points of either side (also in narrow windows), otherwise horizontal; clamp it within the current viewport on rotation. Put previous/page menu/next/add in one bottom-right overlay. No edge docking persistence, storage migration, new dependencies or backend is introduced.

Use PKEraserTool(.vector) for whole strokes and .bitmap for local erasing. This does not mean clearing every stroke on the page. Remember the selected eraser mode during pen/eraser switching. Declare all four iPad interface orientations explicitly in generated project settings and the isolated test project. Preserve user signing in existing local generated projects; apply orientation keys without regenerating those projects.

API references: Apple [UIScrollView](https://developer.apple.com/documentation/uikit/uiscrollview) and [PKCanvasView](https://developer.apple.com/documentation/pencilkit/pkcanvasview).
