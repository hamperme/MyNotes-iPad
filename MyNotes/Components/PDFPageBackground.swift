import SwiftUI
import PDFKit

/// PDFKit renders the immutable original (including its annotations); the existing
/// outer paper viewport transforms this background and editable PencilKit ink together.
struct PDFPageBackground: UIViewRepresentable {
    let page: PDFPage

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.displayMode = .singlePage
        view.displayBox = .cropBox
        view.displaysPageBreaks = false
        view.pageBreakMargins = .zero
        view.pageShadowsEnabled = false
        // The outer viewport owns zoom. PDFKit auto-fit adds its own padding,
        // which would offset ink relative to the PDF (caught by crop/rotation tests).
        view.autoScales = false
        view.minScaleFactor = 1
        view.maxScaleFactor = 1
        view.scaleFactor = 1
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        view.accessibilityIdentifier = "pdfPageBackground"
        view.overrideUserInterfaceStyle = .light
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        if view.document !== page.document { view.document = page.document }
        if view.currentPage !== page { view.go(to: page) }
        view.accessibilityLabel = "PDF 第 \((page.document?.index(for: page) ?? 0) + 1) 页"
    }
}
