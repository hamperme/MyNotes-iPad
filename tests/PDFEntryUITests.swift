import XCTest
final class PDFEntryUITests: XCTestCase {
    func testPDFImportButtonOpensFilePicker() {
        let app = XCUIApplication(); app.launch(); defer { app.terminate() }
        let button = app.buttons["importPDF"]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Library needs PDF import entry")
        guard button.exists else { return }
        button.tap()
        XCTAssertTrue(app.navigationBars["Browse"].waitForExistence(timeout: 5) || app.buttons["Browse"].exists || app.buttons["Cancel"].exists || app.buttons["取消"].exists, "System document picker must open")
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); attachment.name = "pdf-files-picker"; attachment.lifetime = .keepAlways; add(attachment)
        print("PDF_CAPABILITY Files picker opened PASS")
    }
}
