import XCTest

final class EditorUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
        app.launch()
        let create = app.buttons["新建笔记"].firstMatch
        XCTAssertTrue(create.waitForExistence(timeout: 10))
        create.tap()
    }

    override func tearDownWithError() throws {
        app.terminate()
        XCUIDevice.shared.orientation = .portrait
    }

    private func element(_ id: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    private func screenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testFullscreenToolbarMovesToBothEdgesAndPagesAreBottomRight() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        let bar = element("floatingToolbar")
        XCTAssertTrue(bar.waitForExistence(timeout: 5))
        let screen = app.frame
        let viewport = element("zoomScrollView")
        XCTAssertEqual(viewport.frame.width, screen.width, accuracy: 2)
        XCTAssertEqual(viewport.frame.height, screen.height, accuracy: 2)
        XCTAssertGreaterThan(bar.frame.width, bar.frame.height)
        let pager = element("pageControls")
        XCTAssertGreaterThan(pager.frame.midX, screen.midX)
        XCTAssertGreaterThan(pager.frame.midY, screen.midY)
        XCTAssertLessThanOrEqual(screen.maxX - pager.frame.maxX, 32)
        XCTAssertLessThanOrEqual(screen.maxY - pager.frame.maxY, 32)
        let add = element("addPage")
        XCTAssertTrue(pager.frame.contains(add.frame))
        add.tap()
        XCTAssertEqual(element("pageNumber").value as? String, "2 / 2")
        app.buttons["上一页"].tap()
        XCTAssertEqual(element("pageNumber").value as? String, "1 / 2")
        app.buttons["下一页"].tap()
        XCTAssertEqual(element("pageNumber").value as? String, "2 / 2")
        screenshot("01-fullscreen-horizontal")

        let handle = element("toolbarDragHandle")
        handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.4)))
        XCTAssertGreaterThan(bar.frame.height, bar.frame.width)
        XCTAssertGreaterThan(bar.frame.midX, screen.width * 0.8)
        app.buttons["橡皮擦"].tap()
        app.buttons["局部擦除"].tap()
        XCTAssertTrue(app.buttons["局部擦除"].isSelected)
        screenshot("02-right-vertical-partial-eraser")
        handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.2)))
        XCTAssertGreaterThan(bar.frame.height, bar.frame.width)
        XCTAssertLessThan(bar.frame.midX, screen.width * 0.2)
        app.buttons["整笔擦除"].tap()
        XCTAssertTrue(app.buttons["整笔擦除"].isSelected)
        screenshot("03-left-vertical")
        handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12)))
        XCTAssertGreaterThan(bar.frame.width, bar.frame.height)
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.frame.insetBy(dx: -1, dy: -1).contains(bar.frame))
        screenshot("04-portrait-horizontal")
        print("LAYOUT fullscreen; toolbar dragged right/left/center; vertical eraser modes; page add/previous/next; rotation PASS")
        element("backToLibrary").tap()
        XCTAssertTrue(app.buttons["新建笔记"].waitForExistence(timeout: 5))
    }

    func testActualPinchAndFitFillActions() throws {
        let scroll = element("zoomScrollView")
        XCTAssertTrue(scroll.waitForExistence(timeout: 5))
        func zoom() -> Int { Int((scroll.value as? String ?? "").components(separatedBy: "%")[0].filter { $0.isNumber }) ?? 0 }
        screenshot("00-before-pinch")
        print("VIEWPORT app=\(app.frame) viewport=\(scroll.frame) initial=\(scroll.value ?? "nil")")
        let initial = zoom()
        scroll.pinch(withScale: 1.5, velocity: 1)
        screenshot("00-after-pinch")
        print("GESTURE_AFTER \(scroll.value ?? "nil")")
        let enlarged = zoom()
        XCTAssertGreaterThan(enlarged, initial)
        scroll.pinch(withScale: 0.7, velocity: -1)
        XCTAssertLessThan(zoom(), enlarged)
        element("editorSettings").tap()
        element("fitWholePage").tap()
        XCTAssertEqual(zoom(), 100)
        element("editorSettings").tap()
        element("fillScreen").tap()
        XCTAssertGreaterThan(zoom(), 100)
        let filled = zoom()
        screenshot("05-pinch-fill")
        XCUIDevice.shared.orientation = .landscapeLeft
        // Screenshots can store portrait pixels with a landscape orientation tag.
        let rotated = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            let image = XCUIScreen.main.screenshot().image
            guard let pixels = image.cgImage else { return false }
            switch image.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                return pixels.height > pixels.width
            default:
                return pixels.width > pixels.height
            }
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [rotated], timeout: 5), .completed)
        screenshot("06-landscape-before-pinch")
        let landscape = zoom()
        scroll.pinch(withScale: 1.3, velocity: 1)
        XCTAssertGreaterThan(zoom(), landscape)
        print("GESTURE landscape before=\(landscape)% after=\(zoom())% PASS")
        print("GESTURE pinch initial=\(initial)% enlarged=\(enlarged)% fit=100% fill=\(filled)% PASS")
    }
}
