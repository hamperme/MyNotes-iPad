# Architecture (draft)

## Guiding principles

- Native iPadOS 17+, SwiftUI for app shell, `PKCanvasView` for editable Apple Pencil ink, PDFKit for future PDF rendering.
- Offline-first; no server, analytics or cloud dependency.
- **Never flatten editable ink into the background.** Original PDFs must remain immutable.
- Per-page storage isolates changes, improves recovery and avoids loading an entire notebook at once.

## Current structure

```text
MyNotesApp
  └─ LibraryView (SwiftUI)
       └─ NoteEditorView
            ├─ PaperBackground (render-only)
            └─ PencilCanvas (PKCanvasView / PKDrawing)
                      ⇅
               NoteStore (@MainActor)
                 ├─ index.json          (note metadata)
                 └─ <note-id>/<page-id>.drawing
```

`NoteStore` currently writes into the app's Application Support/MyNotes directory. `PKDrawing.dataRepresentation()` is stored per page and rehydrated with `PKDrawing(data:)`. Source is a **draft** and currently uses direct synchronous writes; not production-safe.

## Planned PDF architecture

- `PDFImportService`: security-scoped import and copy of original into app-controlled storage.
- `PDFDocument` from PDFKit to render the original.
- `PDFPageOverlayViewProvider` supplies a `PKCanvasView` per PDF page.
- Each PDF page maintains stable ID → `PKDrawing` path mapping; do not key durable ink solely by visible page number.
- Export with a new PDF document/raster-safe or PDF annotation workflow; preserve original as source and editable overlay for continued note edits.
- Validate normalization of PencilKit view coordinates against PDF page bounds including rotation, crop/media boxes and zoom.

## Planned metadata

`NoteRecord`: UUID, title, folderID, type (blank/PDF), createdAt, updatedAt, page IDs, source PDF location. `PageRecord`: UUID, order, template style, reference to source PDF page, drawing file path. Folder metadata stored with migration support (SwiftData may replace JSON after M0/M1). Avoid schema changes without documented migration.

## Known risks

- `PKCanvasView` delegate changes every stroke; current on-main-thread synchronous saving causes potential lag and I/O races. Introduce debounced, coordinated per-page asynchronous saves and flush on lifecycle changes.
- Persistence has no recovery UI, atomic index transaction or backup; do not store irreplaceable notes yet.
- `PKLassoTool` selection interactions, especially scaling selected strokes, require actual Pencil/iPadOS validation.
- PDF page overlay and touch arbitration (two-finger pan/zoom vs drawing) require real-device regression tests.
