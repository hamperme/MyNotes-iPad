import SwiftUI

struct PaperBackground: View {
    let style: PaperStyle
    private let step: CGFloat = 28

    var body: some View {
        Canvas { context, size in
            let ink = GraphicsContext.Shading.color(.gray.opacity(0.22))
            var path = Path()

            switch style {
            case .blank:
                break
            case .ruled:
                for y in stride(from: step, through: size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: ink, lineWidth: 0.7)
            case .grid:
                for y in stride(from: step, through: size.height, by: step) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                for x in stride(from: step, through: size.width, by: step) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: ink, lineWidth: 0.6)
            case .dotted:
                for x in stride(from: step, through: size.width, by: step) {
                    for y in stride(from: step, through: size.height, by: step) {
                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2)),
                            with: ink
                        )
                    }
                }
            }
        }
        .background(.white)
        .accessibilityHidden(true)
    }
}
