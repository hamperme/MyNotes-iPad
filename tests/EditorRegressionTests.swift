import XCTest
import SwiftUI
import PencilKit
@testable import MyNotes

@MainActor
final class EditorRegressionTests: XCTestCase {
    private var window: UIWindow!
    private var host: UIViewController!

    private func show<V: View>(_ view: V, size: CGSize = CGSize(width: 1200, height: 800)) async throws -> PKCanvasView {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        window = UIWindow(windowScene: scene)
        window.overrideUserInterfaceStyle = .dark
        let root = UIViewController()
        window.rootViewController = root
        window.makeKeyAndVisible()
        let controller = UIHostingController(rootView: view.environment(\.colorScheme, .dark))
        root.addChild(controller)
        root.view.addSubview(controller.view)
        controller.didMove(toParent: root)
        host = controller
        controller.view.frame = CGRect(origin: .zero, size: size)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
        try await Task.sleep(for: .milliseconds(350))
        return try XCTUnwrap(findCanvas(controller.view))
    }

    private func findCanvas(_ view: UIView) -> PKCanvasView? {
        if let canvas = view as? PKCanvasView { return canvas }
        return view.subviews.lazy.compactMap { self.findCanvas($0) }.first
    }

    private func closeHost() {
        window?.isHidden = true
        window?.rootViewController = nil
        host = nil
        window = nil
    }

    func testBlackInkRemainsBlackInDarkMode() async throws {
        defer { closeHost() }
        let canvas = try await show(PencilCanvas(drawing: PKDrawing(), tool: .pen, color: .black, width: 4, onDrawingChanged: { _ in }))
        let tool = try XCTUnwrap(canvas.tool as? PKInkingTool)
        let effective = PKInkingTool.convertColor(tool.color, from: .light, to: canvas.traitCollection.userInterfaceStyle)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        XCTAssertTrue(effective.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        print("INK_BLACK style=\(canvas.traitCollection.userInterfaceStyle.rawValue) effectiveRGB=\(red),\(green),\(blue) alpha=\(alpha)")
        XCTAssertEqual(canvas.traitCollection.userInterfaceStyle, .light)
        XCTAssertLessThan(max(red, green, blue), 0.05)
        XCTAssertEqual(alpha, 1, accuracy: 0.001)
    }

    func testCustomInkAndToolWidthRemainLiteral() async throws {
        defer { closeHost() }
        let expected = UIColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1)
        let canvas = try await show(PencilCanvas(drawing: PKDrawing(), tool: .pen, color: expected, width: 7, onDrawingChanged: { _ in }))
        let tool = try XCTUnwrap(canvas.tool as? PKInkingTool)
        XCTAssertEqual(tool.color, expected)
        XCTAssertEqual(tool.width, 7)
        XCTAssertEqual(canvas.drawingPolicy, .pencilOnly)
        XCTAssertEqual(canvas.traitCollection.userInterfaceStyle, .light)
    }

    func testPortraitPageAndCoordinatesSurviveResize() async throws {
        defer { closeHost() }
        let store = NoteStore()
        let id = try XCTUnwrap(store.createNote())
        let canvas = try await show(NoteEditorView(noteID: id, store: store))
        let original = canvas.bounds.size
        for size in [CGSize(width: 1200, height: 800), CGSize(width: 800, height: 1200), CGSize(width: 600, height: 900)] {
            host.view.frame = CGRect(origin: .zero, size: size)
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(150))
            let logical = canvas.bounds.size
            let visible = canvas.convert(canvas.bounds, to: host.view)
            print("PAGE viewport=\(size) logical=\(logical) visible=\(visible.size)")
            XCTAssertEqual(logical.width / logical.height, 210.0 / 297.0, accuracy: 0.001)
            XCTAssertEqual(logical.width, original.width, accuracy: 0.01)
            XCTAssertEqual(logical.height, original.height, accuracy: 0.01)
            XCTAssertLessThanOrEqual(visible.maxX, size.width + 1)
            XCTAssertLessThanOrEqual(visible.maxY, size.height + 1)
            XCTAssertFalse(canvas.isScrollEnabled)
            XCTAssertEqual(canvas.minimumZoomScale, canvas.maximumZoomScale)
        }
    }

    func testLegacyWideInkIsNotCroppedOrRewritten() async throws {
        defer { closeHost() }
        let points = [CGPoint(x: 50, y: 100), CGPoint(x: 1100, y: 400)].enumerated().map { i, p in
            PKStrokePoint(location: p, timeOffset: Double(i) * 0.1, size: CGSize(width: 4, height: 4), opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2)
        }
        let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: PKStrokePath(controlPoints: points, creationDate: Date()))
        let drawing = PKDrawing(strokes: [stroke])
        let store = NoteStore()
        let id = try XCTUnwrap(store.createNote())
        let pageID = try XCTUnwrap(store.note(id: id)?.pages.first?.id)
        store.saveDrawing(drawing, noteID: id, pageID: pageID)
        let before = store.drawing(noteID: id, pageID: pageID).dataRepresentation()
        let canvas = try await show(NoteEditorView(noteID: id, store: store))
        print("LEGACY inkBounds=\(drawing.bounds) canvas=\(canvas.bounds)")
        XCTAssertGreaterThanOrEqual(canvas.bounds.maxX, drawing.bounds.maxX)
        XCTAssertGreaterThanOrEqual(canvas.bounds.maxY, drawing.bounds.maxY)
        XCTAssertEqual(canvas.bounds.width / canvas.bounds.height, 210.0 / 297.0, accuracy: 0.001)
        XCTAssertEqual(canvas.drawing.strokes.count, 1)
        XCTAssertEqual(canvas.drawing.bounds, drawing.bounds)
        XCTAssertEqual(store.drawing(noteID: id, pageID: pageID).dataRepresentation(), before)
    }
}
