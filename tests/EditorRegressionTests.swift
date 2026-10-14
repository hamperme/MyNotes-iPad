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

    private func segmentedControls(in view: UIView) -> [UISegmentedControl] {
        (view as? UISegmentedControl).map { [$0] } ?? view.subviews.flatMap { segmentedControls(in: $0) }
    }

    private func select(_ index: Int, in control: UISegmentedControl) async throws {
        control.selectedSegmentIndex = index
        control.sendActions(for: .valueChanged)
        try await Task.sleep(for: .milliseconds(200))
    }

    func testEraserOffersWholeStrokeAndPartialModes() async throws {
        defer { closeHost() }
        let store = NoteStore()
        let id = try XCTUnwrap(store.createNote())
        let canvas = try await show(NoteEditorView(noteID: id, store: store))
        let tools = try XCTUnwrap(segmentedControls(in: host.view).first { $0.titleForSegment(at: 0) == "画笔" })
        try await select(1, in: tools)
        XCTAssertEqual((canvas.tool as? PKEraserTool)?.eraserType, .vector)
        let modes = segmentedControls(in: host.view).first { $0.titleForSegment(at: 0) == "整笔擦除" }
        print("ERASER partialSelectorPresent=\(modes != nil) default=\(String(describing: (canvas.tool as? PKEraserTool)?.eraserType))")
        let picker = try XCTUnwrap(modes, "Eraser must offer whole-stroke and partial modes")
        XCTAssertEqual(picker.numberOfSegments, 2)
        XCTAssertEqual(picker.titleForSegment(at: 1), "局部擦除")
        try await select(1, in: picker)
        XCTAssertEqual((canvas.tool as? PKEraserTool)?.eraserType, .bitmap)
        print("ERASER partial=\(String(describing: (canvas.tool as? PKEraserTool)?.eraserType))")
        try await select(0, in: tools)
        XCTAssertTrue(canvas.tool is PKInkingTool)
        try await select(1, in: tools)
        XCTAssertEqual((canvas.tool as? PKEraserTool)?.eraserType, .bitmap, "Keep eraser mode across tool switches")
        let restoredPicker = try XCTUnwrap(segmentedControls(in: host.view).first { $0.titleForSegment(at: 0) == "整笔擦除" })
        try await select(0, in: restoredPicker)
        XCTAssertEqual((canvas.tool as? PKEraserTool)?.eraserType, .vector)
        XCTAssertEqual(canvas.drawingPolicy, .pencilOnly)
        print("ERASER switchedBack=vector pencilOnly=true")
    }

    func testPageZoomKeepsInkCoordinatesAndSurvivesResize() async throws {
        defer { closeHost() }
        let store = NoteStore()
        let id = try XCTUnwrap(store.createNote())
        let pageID = try XCTUnwrap(store.note(id: id)?.pages.first?.id)
        let points = [CGPoint(x: 50, y: 100), CGPoint(x: 300, y: 400)].enumerated().map { i, p in
            PKStrokePoint(location: p, timeOffset: Double(i) * 0.1, size: CGSize(width: 4, height: 4), opacity: 1, force: 1, azimuth: 0, altitude: .pi / 2)
        }
        let drawing = PKDrawing(strokes: [PKStroke(ink: PKInk(.pen, color: .black), path: PKStrokePath(controlPoints: points, creationDate: Date()))])
        store.saveDrawing(drawing, noteID: id, pageID: pageID)
        let before = store.drawing(noteID: id, pageID: pageID).dataRepresentation()
        let canvas = try await show(NoteEditorView(noteID: id, store: store))
        var ancestor = canvas.superview
        var outer: UIScrollView?
        while let view = ancestor {
            if let scroll = view as? UIScrollView { outer = scroll; break }
            ancestor = view.superview
        }
        print("ZOOM outerScrollPresent=\(outer != nil)")
        let scroll = try XCTUnwrap(outer, "The whole paper needs a zoomable viewport")
        let hit = host.view.hitTest(CGPoint(x: host.view.bounds.midX, y: host.view.bounds.midY), with: nil)
        print("ZOOM hitTest=\(String(describing: hit)) inViewport=\(hit?.isDescendant(of: scroll) == true)")
        XCTAssertTrue(hit?.isDescendant(of: scroll) == true, "Blank paper must receive touches, not its overlays")
        XCTAssertTrue(scroll.isScrollEnabled)
        XCTAssertTrue(scroll.gestureRecognizers?.contains { $0 is UIPinchGestureRecognizer && $0.isEnabled } == true)
        XCTAssertEqual(scroll.panGestureRecognizer.minimumNumberOfTouches, 2)
        XCTAssertGreaterThanOrEqual(scroll.maximumZoomScale / scroll.minimumZoomScale, 4)
        let original = canvas.bounds
        let fit = scroll.minimumZoomScale
        let initial = canvas.convert(canvas.bounds, to: scroll)
        XCTAssertGreaterThanOrEqual(initial.width, scroll.bounds.width - 1)
        XCTAssertGreaterThanOrEqual(initial.height, scroll.bounds.height - 1)
        scroll.setZoomScale(fit, animated: false)
        let visible = canvas.convert(canvas.bounds, to: host.view).size
        scroll.setZoomScale(fit * 2, animated: false)
        try await Task.sleep(for: .milliseconds(150))
        XCTAssertEqual(canvas.convert(canvas.bounds, to: host.view).width, visible.width * 2, accuracy: 1)
        XCTAssertEqual(canvas.bounds, original)
        let tools = try XCTUnwrap(segmentedControls(in: host.view).first { $0.titleForSegment(at: 0) == "画笔" })
        try await select(1, in: tools)
        XCTAssertEqual(scroll.zoomScale / scroll.minimumZoomScale, 2, accuracy: 0.01, "Tool changes must not reset zoom")
        for size in [CGSize(width: 800, height: 1200), CGSize(width: 600, height: 900)] {
            host.view.frame = CGRect(origin: .zero, size: size)
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(200))
            print("ZOOM viewport=\(size) relative=\(scroll.zoomScale / scroll.minimumZoomScale) logical=\(canvas.bounds.size)")
            XCTAssertEqual(scroll.zoomScale / scroll.minimumZoomScale, 2, accuracy: 0.01)
            XCTAssertEqual(canvas.bounds, original)
        }
        scroll.setZoomScale(scroll.minimumZoomScale, animated: false)
        try await Task.sleep(for: .milliseconds(150))
        let fitted = canvas.convert(canvas.bounds, to: scroll)
        let viewport = scroll.bounds
        XCTAssertGreaterThanOrEqual(fitted.minX, viewport.minX - 1)
        XCTAssertGreaterThanOrEqual(fitted.minY, viewport.minY - 1)
        XCTAssertLessThanOrEqual(fitted.maxX, viewport.maxX + 1)
        XCTAssertLessThanOrEqual(fitted.maxY, viewport.maxY + 1)
        XCTAssertEqual(canvas.drawing.dataRepresentation(), before)
        XCTAssertEqual(store.drawing(noteID: id, pageID: pageID).dataRepresentation(), before)
        print("ZOOM fittedAgain=true drawingBytesUnchanged=true")
    }
}
