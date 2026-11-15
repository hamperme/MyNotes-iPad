import XCTest
import PDFKit
import PencilKit
import SwiftUI
@testable import MyNotes

@MainActor
final class PDFImportTests: XCTestCase {
    private var directory: URL!
    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    override func tearDownWithError() throws { try FileManager.default.removeItem(at: directory) }
    private func store() -> NoteStore { NoteStore(rootURL: directory.appendingPathComponent("notes")) }

    private func fixture(pages: Int = 3, rotation: Int = 0) throws -> URL {
        let url = directory.appendingPathComponent("External Lesson.pdf")
        let data = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)).pdfData { context in
            for index in 0..<pages {
                let rect = index == 1 ? CGRect(x: 0, y: 0, width: 842, height: 595) : CGRect(x: 0, y: 0, width: 595, height: 842)
                context.beginPage(withBounds: rect, pageInfo: [:])
                UIColor.white.setFill(); context.cgContext.fill(rect)
                UIColor.red.setFill(); context.cgContext.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
                UIColor.blue.setFill(); context.cgContext.fill(CGRect(x: rect.maxX - 40, y: rect.maxY - 40, width: 40, height: 40))
                ("External PDF - page \(index + 1)" as NSString).draw(at: CGPoint(x: 50, y: 60), withAttributes: [.font: UIFont.systemFont(ofSize: 24), .foregroundColor: UIColor.black])
            }
        }
        if rotation != 0 {
            let document = try XCTUnwrap(PDFDocument(data: data))
            document.page(at: 0)?.rotation = rotation
            document.page(at: 0)?.setBounds(CGRect(x: 20, y: 30, width: 500, height: 700), for: .cropBox)
            XCTAssertTrue(document.write(to: url))
        } else { try data.write(to: url) }
        return url
    }

    func testImportsImmutableOriginalAndStablePagesAcrossReopen() async throws {
        let original = try fixture(pages: 50)
        let before = try Data(contentsOf: original)
        let store = store(); let old = try XCTUnwrap(store.createNote())
        let oldPage = try XCTUnwrap(store.note(id: old)?.pages.first?.id)
        let id = try await store.importPDF(from: original)
        let note = try XCTUnwrap(store.note(id: id))
        XCTAssertEqual(note.title, "External Lesson")
        XCTAssertEqual(note.pages.count, 50)
        XCTAssertEqual(note.pages.compactMap(\.pdfPageIndex), Array(0..<50))
        XCTAssertEqual(Set(note.pages.map(\.id)).count, 50)
        let copy = directory.appendingPathComponent("notes/\(id.uuidString)/source.pdf")
        XCTAssertEqual(try Data(contentsOf: copy), before)
        XCTAssertEqual(try Data(contentsOf: original), before)
        for number in [1, 14, 39] {
            let point = PKStrokePoint(location: CGPoint(x: 100, y: 150), timeOffset: 0, size: CGSize(width: 4, height: 4), opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2)
            let ink = PKDrawing(strokes: [PKStroke(ink: PKInk(.pen, color: .black), path: PKStrokePath(controlPoints: [point], creationDate: Date()))])
            store.saveDrawing(ink, noteID: id, pageID: note.pages[number].id)
            XCTAssertEqual(store.drawing(noteID: id, pageID: note.pages[number].id).strokes.count, 1)
        }
        try FileManager.default.removeItem(at: original) // No dependency on temporary external access.
        let reopened = self.store()
        XCTAssertEqual(reopened.note(id: id)?.pages.map(\.id), note.pages.map(\.id))
        XCTAssertEqual(reopened.pdfDocument(noteID: id)?.pageCount, 50)
        XCTAssertEqual(reopened.note(id: old)?.pages.first?.id, oldPage)
        for number in [1, 14, 39] { XCTAssertEqual(reopened.drawing(noteID: id, pageID: note.pages[number].id).strokes.count, 1) }
        XCTAssertEqual(try Data(contentsOf: copy), before)
        print("PDF_IMPORT 50 pages, original bytes preserved, stable IDs, ink pages 2/15/40 survive reopen PASS")
    }

    func testLegacyIndexStillDecodesAndDuplicateNamesDoNotOverwrite() async throws {
        let root = directory.appendingPathComponent("notes")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let id = UUID(), page = UUID()
        let legacy = "[{\"id\":\"\(id)\",\"title\":\"Legacy\",\"createdAt\":0,\"updatedAt\":0,\"pages\":[{\"id\":\"\(page)\",\"style\":\"ruled\"}]}]"
        try Data(legacy.utf8).write(to: root.appendingPathComponent("index.json"))
        let store = self.store(); XCTAssertNil(store.loadError)
        XCTAssertNil(store.note(id: id)?.sourcePDF)
        let file = try fixture(); let first = try await store.importPDF(from: file); let second = try await store.importPDF(from: file)
        XCTAssertNotEqual(first, second); XCTAssertEqual(store.notes.count, 3)
        XCTAssertEqual(store.note(id: id)?.pages.first?.id, page)
        let appended = try XCTUnwrap(store.addPage(to: first))
        XCTAssertNil(store.note(id: first)?.pages.first(where: { $0.id == appended })?.pdfPageIndex)
    }

    func testRejectsBadOrEncryptedOrRemoteInputWithoutChangingIndex() async throws {
        let store = store(); _ = store.createNote()
        let index = directory.appendingPathComponent("notes/index.json"); let before = try Data(contentsOf: index)
        let bad = directory.appendingPathComponent("bad.pdf"); try Data("not a PDF".utf8).write(to: bad)
        let encrypted = directory.appendingPathComponent("locked.pdf")
        let document = try XCTUnwrap(PDFDocument(url: fixture()))
        XCTAssertTrue(document.write(to: encrypted, withOptions: [.userPasswordOption: "fixture-password", .ownerPasswordOption: "fixture-owner"]))
        for url in [bad, encrypted, URL(string: "https://example.invalid/file.pdf")!] {
            do { _ = try await store.importPDF(from: url); XCTFail("Expected rejection") } catch { print("PDF_REJECT \(error.localizedDescription)") }
            XCTAssertEqual(try Data(contentsOf: index), before)
            XCTAssertFalse(store.isImporting)
        }
        XCTAssertFalse(try FileManager.default.contentsOfDirectory(atPath: directory.appendingPathComponent("notes").path).contains { $0.hasPrefix(".import-") })
    }

    func testFailedIndexCommitRollsBackCopiedDocument() async throws {
        let store = store(); let root = directory.appendingPathComponent("notes")
        try FileManager.default.createDirectory(at: root.appendingPathComponent("index.json"), withIntermediateDirectories: true)
        do { _ = try await store.importPDF(from: fixture()); XCTFail("Expected index-write failure") } catch {}
        XCTAssertTrue(store.notes.isEmpty)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path), ["index.json"])
    }

    func testPDFBackgroundCropRotationAndOverlayGeometry() async throws {
        let store = store(); let file = try fixture(rotation: 90); let id = try await store.importPDF(from: file)
        let pageID = try XCTUnwrap(store.note(id: id)?.pages.first?.id)
        let page = try XCTUnwrap(store.pdfPage(noteID: id, pageID: pageID))
        XCTAssertEqual(PDFImportService.pageSize(page), CGSize(width: 700, height: 500))
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        let host = UIHostingController(rootView: NoteEditorView(noteID: id, store: store))
        window.rootViewController = host; window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }
        func find<T: UIView>(_ view: UIView, _: T.Type) -> T? {
            (view as? T) ?? view.subviews.lazy.compactMap { find($0, T.self) }.first
        }
        try await Task.sleep(for: .milliseconds(500))
        let pdf = try XCTUnwrap(find(host.view, PDFView.self))
        let canvas = try XCTUnwrap(find(host.view, PKCanvasView.self))
        for size in [CGSize(width: 1200, height: 800), CGSize(width: 800, height: 1200)] {
            host.view.frame = CGRect(origin: .zero, size: size); host.view.setNeedsLayout(); host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(250))
            XCTAssertEqual(canvas.bounds.size, CGSize(width: 700, height: 500))
            XCTAssertEqual(pdf.bounds.size, canvas.bounds.size)
            let rendered = pdf.convert(page.bounds(for: .cropBox), from: page)
            XCTAssertEqual(rendered.minX, 0, accuracy: 2); XCTAssertEqual(rendered.minY, 0, accuracy: 2)
            XCTAssertEqual(rendered.width, pdf.bounds.width, accuracy: 2)
            XCTAssertEqual(rendered.height, pdf.bounds.height, accuracy: 2)
        }
        let screenshot = UIGraphicsImageRenderer(bounds: host.view.bounds).image { _ in host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true) }
        let attachment = XCTAttachment(image: screenshot); attachment.name = "pdf-crop-rotation-overlay"; attachment.lifetime = .keepAlways; add(attachment)
        print("PDF_LAYOUT crop/90-degree rotation/ink geometry/resize measured")
    }
}
