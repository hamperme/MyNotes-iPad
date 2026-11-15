import XCTest
final class PDFCapabilityTests: XCTestCase {
    func testExternalPDFDocumentRegistration() {
        let types = Bundle.main.object(forInfoDictionaryKey: "CFBundleDocumentTypes") as? [[String: Any]] ?? []
        XCTAssertTrue(types.contains { ($0["LSItemContentTypes"] as? [String] ?? []).contains("com.adobe.pdf") }, "External PDF type must be registered")
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "LSSupportsOpeningDocumentsInPlace") as? Bool, true)
        print("PDF_CAPABILITY document types=\(types.count)")
    }
}
