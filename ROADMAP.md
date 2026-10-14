> **PROJECT PIVOT (2026-10-14): This Swift/iPadOS prototype is paused, retained for reference only.** The active no-signing iPad PWA project, Issues, PRs and cross-AI handoff are now in [hamperme/maplehub-study](https://github.com/hamperme/maplehub-study), with [migration plan](https://github.com/hamperme/maplehub-study/blob/main/docs/MAPLENOTES_PWA_PLAN.md) and [active handoff](https://github.com/hamperme/maplehub-study/blob/main/handoff.md). Do not develop two separate deployed web copies. No working PWA or real iPad test has been completed yet.

# Roadmap and acceptance criteria

Scope: native **iPad-only**, offline-first, personal-use Notability-inspired app. No App Store listing, collaboration, recording, AI recognition or cloud sync in MVP.

**Milestone sequence:** M0 → M1 → M2 → M3 → M4 → M5. Estimated effort is planning guidance, not a delivery commitment.

## M0 — Build & device bootstrap (first issue)
- [ ] Generate `.xcodeproj` using `./scripts/bootstrap.sh`.
- [ ] `./scripts/check.sh` succeeds on Mac.
- [ ] App installs via Xcode Personal Team on target iPad.
- [ ] Log Xcode version, iPad model, iPadOS and results in test plan.

## M1 — PencilKit (Apple Pencil, eraser, colors, widths, lasso)
- [ ] Pencil drawing with smooth latency; finger does not accidentally ink.
- [ ] Pen color/width persist during tool switches.
- [ ] Eraser works; clarify pixel vs vector mode in UI.
- [ ] Basic lasso select + move works on real iPad; determine whether selection scaling is available or needs custom implementation.
- [ ] Close/reopen App and confirm editable strokes remain.

## M2 — Pages & templates
- [ ] Four styles: blank/ruled/grid/dotted.
- [ ] Add, delete, reorder, navigate pages with separate ink files.
- [ ] Switching paper style never destroys/editably flattens ink.
- [ ] A 20-page document survives relaunch with page order and content correct.

## M3 — Note library & folders
- [ ] Rename, delete (confirm), search and sort notes.
- [ ] Create/rename/move folders; move notes between folders.
- [ ] Thumbnails and updated timestamps refresh reliably.
- [ ] Storage schema migration documented and tested.

## M4 — PDF import & editable annotation
- [ ] Import from Files via security-scoped file URL; copy into app-managed storage.
- [ ] Render multi-page PDF with PDFKit.
- [ ] Overlay independently persisted PKDrawing per PDF page (stable identifier).
- [ ] Verify correct ink location when zooming, switching pages and rotating iPad.
- [ ] Export annotated PDF, preserving original PDF and editable source ink.
- [ ] Test 50-page file with edits on widely separated pages.

## M5 — Stability, undo, backups and release-ready personal build
- [ ] Undo/redo per page; test switching pages during editing.
- [ ] Debounced/background saves with explicit error reporting and recovery.
- [ ] Backup and restore format verified; avoid accidental data loss when reinstalling.
- [ ] Test large documents and stress scenarios; review memory/performance.
- [ ] Document direct Xcode installation, provisioning expiration, and iPad setup.

## Issue decomposition when GitHub repo is created

Create one issue per milestone first; split implementation further (e.g., PDF import, PDF overlay, PDF export) as work starts. All issues require:
- **Acceptance criteria** with a user-visible behavior.
- **Test evidence** (command, device, expected/actual).
- **Definition of done:** implementation + tests + docs + `handoff.md`/`PROGRESS.md` update.