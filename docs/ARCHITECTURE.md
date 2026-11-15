# Architecture (draft)

## Guiding principles

- Native iPadOS 17+, SwiftUI for app shell, `PKCanvasView` for editable Apple Pencil ink, PDFKit for imported PDF rendering.
- Offline-first; no server, analytics or cloud dependency.
- **Never flatten editable ink into the background.** Original PDFs must remain immutable.
- Per-page storage isolates changes, improves recovery and avoids loading an entire notebook at once.

## Current structure

```text
MyNotesApp
  └─ LibraryView (SwiftUI)
       └─ NoteEditorView
            ├─ PaperBackground / PDFPageBackground (render-only)
            └─ PencilCanvas (PKCanvasView / PKDrawing)
                      ⇅
               NoteStore (@MainActor)
                 ├─ index.json          (note metadata)
                 ├─ <note-id>/source.pdf (immutable imported original)
                 └─ <note-id>/<page-id>.drawing
```

`NoteStore` currently writes into the app's Application Support/MyNotes directory. `PKDrawing.dataRepresentation()` is stored per page and rehydrated with `PKDrawing(data:)`. Source is a **draft** and currently uses direct synchronous writes; not production-safe.

## PDF import architecture (2026-11-15)

- `PDFImportService`: security-scoped import and copy of original into app-controlled storage.
- `PDFDocument` from PDFKit to render the original.
- `PDFPageBackground` uses a noninteractive single-page `PDFView` under the existing `PKCanvasView`; one outer viewport transforms both. This replaces the earlier planned `PDFPageOverlayViewProvider` approach and retains the existing toolbar/paging/gesture model.
- Each PDF page maintains stable ID → `PKDrawing` path mapping; do not key durable ink solely by visible page number.
- Export remains planned: derive a new PDF without changing original/source ink. Import details and additive optional-field schema: [PDF_IMPORT.md](PDF_IMPORT.md).
- Validate normalization of PencilKit view coordinates against PDF page bounds including rotation, crop/media boxes and zoom.

## Planned metadata

`NoteRecord`: UUID, title, folderID, type (blank/PDF), createdAt, updatedAt, page IDs, source PDF location. `PageRecord`: UUID, order, template style, reference to source PDF page, drawing file path. Folder metadata stored with migration support (SwiftData may replace JSON after M0/M1). Avoid schema changes without documented migration.

## Known risks

- `PKCanvasView` delegate changes every stroke; current on-main-thread synchronous saving causes potential lag and I/O races. Introduce debounced, coordinated per-page asynchronous saves and flush on lifecycle changes.
- General persistence has no recovery UI or in-app backup (PDF import has an atomic index commit and failure cleanup); do not store irreplaceable notes yet.
- `PKLassoTool` selection interactions, especially scaling selected strokes, require actual Pencil/iPadOS validation.
- PDF page overlay and touch arbitration (two-finger pan/zoom vs drawing) require real-device regression tests.
