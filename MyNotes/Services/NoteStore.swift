import Foundation
import PencilKit
import PDFKit

/// v0 storage: JSON metadata and one editable PKDrawing binary per page.
/// TODO: move heavy writes off the main thread and debounce drawing changes.
@MainActor
final class NoteStore: ObservableObject {
    @Published private(set) var notes: [NoteRecord] = []
    @Published private(set) var loadError: String?
    @Published private(set) var isImporting = false
    private var cachedPDF: (id: UUID, document: PDFDocument)?

    private let rootURL: URL
    private var indexURL: URL { rootURL.appendingPathComponent("index.json") }

    init(rootURL customRoot: URL? = nil) {
        let support = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        )[0]
        rootURL = customRoot ?? support.appendingPathComponent("MyNotes", isDirectory: true)
        do {
            try FileManager.default.createDirectory(
                at: rootURL, withIntermediateDirectories: true
            )
            if FileManager.default.fileExists(atPath: indexURL.path) {
                let data = try Data(contentsOf: indexURL)
                notes = try JSONDecoder().decode([NoteRecord].self, from: data)
            }
        } catch {
            // Prevent new changes from overwriting a possibly corrupt index.
            loadError = "读取笔记索引失败：\(error.localizedDescription)。请先备份应用数据再排查。"
            NSLog("MyNotes: failed to load note index: %@", String(describing: error))
        }
    }

    func note(id: UUID) -> NoteRecord? { notes.first { $0.id == id } }

    /// Copy/validate first; commit metadata atomically before publishing the new note.
    /// Existing notes and the external source are never rewritten by this transaction.
    @discardableResult
    func importPDF(from url: URL) async throws -> UUID {
        guard loadError == nil else { throw PDFImportError.storageUnavailable }
        guard !isImporting else { throw PDFImportError.busy }
        isImporting = true
        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped { url.stopAccessingSecurityScopedResource() }
            isImporting = false
        }
        let root = rootURL
        let prepared = try await Task.detached(priority: .userInitiated) {
            try PDFImportService.prepare(from: url, root: root)
        }.value
        let destination = rootURL.appendingPathComponent(prepared.id.uuidString, isDirectory: true)
        var moved = false
        do {
            try Task.checkCancellation()
            try FileManager.default.moveItem(at: prepared.stagingURL, to: destination)
            moved = true
            let note = NoteRecord(id: prepared.id, title: prepared.title,
                                  pages: (0..<prepared.pageCount).map { PageRecord(style: .blank, pdfPageIndex: $0) },
                                  sourcePDF: "source.pdf")
            let next = [note] + notes
            try JSONEncoder().encode(next).write(to: indexURL, options: .atomic)
            notes = next
            return note.id
        } catch {
            try? FileManager.default.removeItem(at: moved ? destination : prepared.stagingURL)
            throw error
        }
    }

    func pdfDocument(noteID: UUID) -> PDFDocument? {
        guard note(id: noteID)?.sourcePDF == "source.pdf" else { return nil }
        if cachedPDF?.id == noteID { return cachedPDF?.document }
        let url = rootURL.appendingPathComponent(noteID.uuidString, isDirectory: true).appendingPathComponent("source.pdf")
        guard let document = PDFDocument(url: url), !document.isLocked else { return nil }
        cachedPDF = (noteID, document) // Retain at most the current imported document.
        return document
    }

    func pdfPage(noteID: UUID, pageID: UUID) -> PDFPage? {
        guard let index = note(id: noteID)?.pages.first(where: { $0.id == pageID })?.pdfPageIndex else { return nil }
        return pdfDocument(noteID: noteID)?.page(at: index)
    }

    @discardableResult
    func createNote() -> UUID? {
        guard loadError == nil else { return nil }
        let note = NoteRecord(title: "新笔记")
        notes.insert(note, at: 0)
        persistIndex()
        return note.id
    }

    @discardableResult
    func addPage(to noteID: UUID) -> UUID? {
        guard loadError == nil else { return nil }
        guard let index = notes.firstIndex(where: { $0.id == noteID }) else { return nil }
        let page = PageRecord()
        var next = notes
        next[index].pages.append(page)
        next[index].updatedAt = .now
        notes = next
        persistIndex()
        return page.id
    }

    func setPaperStyle(_ style: PaperStyle, noteID: UUID, pageID: UUID) {
        guard loadError == nil else { return }
        guard let index = notes.firstIndex(where: { $0.id == noteID }),
              let pageIndex = notes[index].pages.firstIndex(where: { $0.id == pageID })
        else { return }
        var next = notes
        next[index].pages[pageIndex].style = style
        next[index].updatedAt = .now
        notes = next
        persistIndex()
    }

    func drawing(noteID: UUID, pageID: UUID) -> PKDrawing {
        let url = drawingURL(noteID: noteID, pageID: pageID)
        guard let data = try? Data(contentsOf: url),
              let drawing = try? PKDrawing(data: data) else { return PKDrawing() }
        return drawing
    }

    func saveDrawing(_ drawing: PKDrawing, noteID: UUID, pageID: UUID) {
        guard loadError == nil else { return }
        guard notes.contains(where: { $0.id == noteID && $0.pages.contains(where: { $0.id == pageID }) })
        else { return }
        let url = drawingURL(noteID: noteID, pageID: pageID)
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            try drawing.dataRepresentation().write(to: url, options: .atomic)
        } catch {
            NSLog("MyNotes: failed to save drawing: %@", String(describing: error))
        }
    }

    private func drawingURL(noteID: UUID, pageID: UUID) -> URL {
        rootURL.appendingPathComponent(noteID.uuidString, isDirectory: true)
            .appendingPathComponent("\(pageID.uuidString).drawing")
    }

    private func persistIndex() {
        guard loadError == nil else { return }
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: indexURL, options: .atomic)
        } catch {
            NSLog("MyNotes: failed to save index: %@", String(describing: error))
        }
    }
}
