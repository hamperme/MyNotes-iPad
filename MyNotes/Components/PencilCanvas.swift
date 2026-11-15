import SwiftUI
import PencilKit

/// Editable PencilKit drawing. Callers keep editable ink separate from paper/PDF.
enum DrawingTool: String, CaseIterable {
    case pen, eraser, lasso
}

enum EraserMode: String, CaseIterable {
    case stroke, partial
}

struct PencilCanvas: UIViewRepresentable {
    var drawing: PKDrawing
    var tool: DrawingTool
    var color: UIColor
    var width: CGFloat
    var eraserMode: EraserMode = .stroke
    var onDrawingChanged: (PKDrawing) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        // White paper must not invert black ink when the app uses Dark Mode.
        canvas.overrideUserInterfaceStyle = .light
        canvas.isScrollEnabled = false
        // Only the outer paper viewport may handle finger navigation.
        canvas.pinchGestureRecognizer?.isEnabled = false
        canvas.panGestureRecognizer.isEnabled = false
        canvas.minimumZoomScale = 1
        canvas.maximumZoomScale = 1
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .pencilOnly
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.overrideUserInterfaceStyle = .light
        context.coordinator.parent = self
        if canvas.drawing.dataRepresentation() != drawing.dataRepresentation() {
            canvas.drawing = drawing
        }
        switch tool {
        case .pen:
            canvas.tool = PKInkingTool(.pen, color: color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).withAlphaComponent(1), width: width)
        case .eraser:
            canvas.tool = PKEraserTool(eraserMode == .stroke ? .vector : .bitmap)
        case .lasso:
            canvas.tool = PKLassoTool()
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvas
        init(parent: PencilCanvas) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.onDrawingChanged(canvasView.drawing)
        }
    }
}
