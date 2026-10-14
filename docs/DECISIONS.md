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
