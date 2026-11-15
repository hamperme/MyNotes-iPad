import XCTest
import UIKit

/// Public XCTest URL launch exercises the same onOpenURL receiver as Open In.
/// WeChat's own share sheet remains a separate physical-device acceptance step.
final class PDFOpenInUITests: XCTestCase {
    func testExternalFileURLImportPagingPinchAndRelaunch() throws {
        let title = "OpenIn-\(UUID().uuidString.prefix(8))"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(title + ".pdf")
        defer { try? FileManager.default.removeItem(at: url) }
        try UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)).writePDF(to: url) { context in
            for index in 0..<3 {
                let rect = index == 1 ? CGRect(x: 0, y: 0, width: 842, height: 595) : CGRect(x: 0, y: 0, width: 595, height: 842)
                context.beginPage(withBounds: rect, pageInfo: [:])
                UIColor.white.setFill(); context.cgContext.fill(rect)
                UIColor.red.setFill(); context.cgContext.fill(CGRect(x: 25, y: 25, width: 40, height: 40))
                UIColor.blue.setFill(); context.cgContext.fill(CGRect(x: rect.maxX - 65, y: rect.maxY - 65, width: 40, height: 40))
                ("External PDF / Page \(index + 1)" as NSString).draw(at: CGPoint(x: 80, y: 80), withAttributes: [.font: UIFont.systemFont(ofSize: 24), .foregroundColor: UIColor.black])
            }
        }
        let app = XCUIApplication(); app.terminate(); XCUIDevice.shared.orientation = .portrait
        defer { app.terminate(); XCUIDevice.shared.orientation = .portrait }
        app.open(url)
        func element(_ id: String) -> XCUIElement { app.descendants(matching: .any).matching(identifier: id).firstMatch }
        let pager = element("pageNumber")
        XCTAssertTrue(pager.waitForExistence(timeout: 15), "External file should open as a notebook")
        XCTAssertEqual(pager.value as? String, "1 / 3")
        app.buttons["下一页"].tap(); XCTAssertEqual(pager.value as? String, "2 / 3")
        element("editorSettings").tap(); element("fitWholePage").tap()
        let scroll = element("zoomScrollView")
        func zoom() -> Int { Int((scroll.value as? String ?? "").components(separatedBy: "%")[0].filter { $0.isNumber }) ?? 0 }
        XCTAssertEqual(zoom(), 100)
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); screenshot.name = "external-pdf-landscape-page"; screenshot.lifetime = .keepAlways; add(screenshot)
        scroll.pinch(withScale: 1.5, velocity: 1); XCTAssertGreaterThan(zoom(), 100)
        XCUIDevice.shared.orientation = .landscapeLeft
        app.buttons["下一页"].tap(); XCTAssertEqual(pager.value as? String, "3 / 3")
        // Delete temporary source; the imported notebook must remain independently readable.
        try FileManager.default.removeItem(at: url)
        app.terminate(); app.launch()
        let note = app.staticTexts[title].firstMatch
        XCTAssertTrue(note.waitForExistence(timeout: 5)); note.tap()
        XCTAssertTrue(pager.waitForExistence(timeout: 5)); XCTAssertEqual(pager.value as? String, "1 / 3")
        app.buttons["下一页"].tap(); XCTAssertEqual(pager.value as? String, "2 / 3")
        XCTAssertFalse(app.staticTexts["PDF 原文件无法读取，请保留笔记并从备份恢复原文件。"].exists)
        print("PDF_OPEN_IN cold file URL / 3 pages / pinch / rotation / source removed / app relaunch PASS")
    }
}
