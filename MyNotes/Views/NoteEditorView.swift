import SwiftUI
import PencilKit

struct NoteEditorView: View {
    let noteID: UUID
    @ObservedObject var store: NoteStore
    @Environment(\.dismiss) private var dismiss

    @State private var pageID: UUID
    @State private var drawing = PKDrawing()
    @State private var tool: DrawingTool = .pen
    @State private var eraserMode: EraserMode = .stroke
    @State private var color: Color = .black
    @State private var width: Double = 4
    @State private var paperSize = CGSize(width: 595, height: 595 * 297 / 210)
    @State private var toolbarAnchor = CGPoint(x: 0.5, y: 0.07)
    @State private var verticalToolbar = false
    @State private var dragStart: CGPoint?
    @State private var settingsVisible = false
    @State private var zoomRequest = 0
    @State private var fitWholePage = false

    init(noteID: UUID, store: NoteStore) {
        self.noteID = noteID
        self.store = store
        _pageID = State(initialValue: store.note(id: noteID)?.pages.first?.id ?? UUID())
    }

    private var note: NoteRecord? { store.note(id: noteID) }
    private var page: PageRecord? { note?.pages.first(where: { $0.id == pageID }) }

    var body: some View {
        GeometryReader { geometry in
            if let note, let page {
                let vertical = verticalToolbar || geometry.size.width < 520
                let barSize = CGSize(
                    width: vertical ? 68 : min(480, geometry.size.width - 24),
                    height: vertical ? (tool == .eraser ? 438 : 350) : (tool == .eraser ? 108 : 64)
                )
                ZStack(alignment: .bottomTrailing) {
                    ZoomablePaper(size: paperSize, request: zoomRequest, fitWholePage: fitWholePage) {
                        ZStack {
                            if page.pdfPageIndex != nil {
                                if let pdfPage = store.pdfPage(noteID: noteID, pageID: page.id) {
                                    PDFPageBackground(page: pdfPage)
                                } else {
                                    Color.white.overlay {
                                        Text("PDF 原文件无法读取，请保留笔记并从备份恢复原文件。")
                                            .foregroundStyle(.red).padding()
                                    }
                                }
                            } else {
                                PaperBackground(style: page.style)
                            }
                            PencilCanvas(drawing: drawing, tool: tool, color: UIColor(color),
                                         width: CGFloat(width), eraserMode: eraserMode) { edited in
                                guard page.id == pageID else { return }
                                drawing = edited
                                store.saveDrawing(edited, noteID: noteID, pageID: page.id)
                            }
                        }
                        .frame(width: paperSize.width, height: paperSize.height)
                        .environment(\.colorScheme, .light)
                        .clipped()
                    }
                    .id(pageID)
                    .accessibilityIdentifier("paperViewport")

                    floatingToolbar(vertical: vertical, geometry: geometry, barSize: barSize)
                        .frame(width: barSize.width, height: barSize.height)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.primary.opacity(0.1)))
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("floatingToolbar")
                        .accessibilityValue(vertical ? "竖向" : "横向")
                        .position(toolbarCenter(in: geometry, size: barSize))

                    pageControls(note)
                        .padding(.trailing, max(16, geometry.safeAreaInsets.trailing))
                        .padding(.bottom, max(16, geometry.safeAreaInsets.bottom))
                }
                .coordinateSpace(name: "editor")
            } else {
                ContentUnavailableView("笔记不存在", systemImage: "exclamationmark.triangle")
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .onAppear(perform: loadPage)
        .onChange(of: pageID) { _, _ in loadPage() }
    }

    @ViewBuilder
    private func floatingToolbar(vertical: Bool, geometry: GeometryProxy, barSize: CGSize) -> some View {
        let layout = vertical ? AnyLayout(VStackLayout(spacing: 4)) : AnyLayout(HStackLayout(spacing: 8))
        VStack(spacing: 4) {
            layout {
                Image(systemName: vertical ? "line.3.horizontal" : "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: vertical ? 44 : 28, height: 40)
                    .contentShape(Rectangle())
                    .accessibilityLabel("拖动工具栏")
                    .accessibilityIdentifier("toolbarDragHandle")
                    .gesture(DragGesture(coordinateSpace: .named("editor"))
                        .onChanged { value in
                            let start = dragStart ?? toolbarCenter(in: geometry, size: barSize)
                            dragStart = start
                            let point = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                            toolbarAnchor = CGPoint(x: point.x / max(1, geometry.size.width), y: point.y / max(1, geometry.size.height))
                            verticalToolbar = point.x < 90 || point.x > geometry.size.width - 90
                        }
                        .onEnded { _ in
                            let center = toolbarCenter(in: geometry, size: CGSize(
                                width: (verticalToolbar || geometry.size.width < 520) ? 68 : min(480, geometry.size.width - 24),
                                height: (verticalToolbar || geometry.size.width < 520) ? (tool == .eraser ? 438 : 350) : (tool == .eraser ? 108 : 64)))
                            toolbarAnchor = CGPoint(x: center.x / max(1, geometry.size.width), y: center.y / max(1, geometry.size.height))
                            dragStart = nil
                        })
                Button { dismiss() } label: { Image(systemName: "chevron.left") }
                    .frame(width: 36, height: 44)
                    .accessibilityLabel("返回笔记列表")
                    .accessibilityIdentifier("backToLibrary")

                if vertical {
                    toolButton(.pen, title: "画笔", icon: "pencil.tip")
                    toolButton(.eraser, title: "橡皮擦", icon: "eraser")
                    toolButton(.lasso, title: "套索", icon: "lasso")
                } else {
                    Picker("工具", selection: $tool) {
                        Text("画笔").tag(DrawingTool.pen)
                        Text("橡皮擦").tag(DrawingTool.eraser)
                        Text("套索").tag(DrawingTool.lasso)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("drawingTools")
                }
                ColorPicker("颜色", selection: $color, supportsOpacity: false)
                    .labelsHidden().frame(width: 36, height: 44)
                    .accessibilityLabel("选择画笔颜色")
                Button { settingsVisible = true } label: { Image(systemName: "slider.horizontal.3") }
                    .frame(width: 36, height: 44)
                    .accessibilityLabel("笔粗、纸张与缩放")
                    .accessibilityIdentifier("editorSettings")
                    .popover(isPresented: $settingsVisible) { settingsPanel }
            }
            if tool == .eraser {
                if vertical {
                    eraserButton(.stroke, title: "整笔", icon: "eraser.fill")
                    eraserButton(.partial, title: "局部", icon: "eraser.line.dashed.fill")
                } else {
                    Picker("擦除方式", selection: $eraserMode) {
                        Text("整笔擦除").tag(EraserMode.stroke)
                        Text("局部擦除").tag(EraserMode.partial)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("eraserModes")
                }
            }
        }
        .padding(10)
        .buttonStyle(.plain)
    }

    private func toolButton(_ value: DrawingTool, title: String, icon: String) -> some View {
        Button { tool = value } label: {
            Image(systemName: icon).frame(width: 44, height: 44)
                .background(tool == value ? Color.accentColor.opacity(0.16) : .clear, in: RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel(title)
        .accessibilityAddTraits(tool == value ? .isSelected : [])
    }

    private func eraserButton(_ value: EraserMode, title: String, icon: String) -> some View {
        Button { eraserMode = value } label: {
            VStack(spacing: 1) { Image(systemName: icon); Text(title).font(.caption2) }
                .frame(width: 44, height: 40)
                .background(eraserMode == value ? Color.accentColor.opacity(0.16) : .clear, in: RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityLabel(title + "擦除")
        .accessibilityAddTraits(eraserMode == value ? .isSelected : [])
    }

    private var settingsPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("书写设置").font(.headline)
            Text("笔粗 \(width, specifier: "%.0f")")
            Slider(value: $width, in: 1...20).accessibilityLabel("笔粗")
            if let page, page.pdfPageIndex == nil {
                Picker("纸张", selection: Binding(get: { page.style }, set: {
                    store.setPaperStyle($0, noteID: noteID, pageID: pageID)
                })) {
                    ForEach(PaperStyle.allCases) { Text($0.displayName).tag($0) }
                }.pickerStyle(.segmented)
            }
            HStack {
                Button("适合整页") { requestZoom(fit: true) }.accessibilityIdentifier("fitWholePage")
                Spacer()
                Button("铺满屏幕") { requestZoom(fit: false) }.accessibilityIdentifier("fillScreen")
            }
            Text("双指捏合缩放，双指拖动页面。拖动工具栏上的圆点或横线可移动它；靠近左右边缘会竖排。")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .padding(24).frame(width: 320)
        .presentationCompactAdaptation(.popover)
    }

    private func pageControls(_ note: NoteRecord) -> some View {
        let index = note.pages.firstIndex(where: { $0.id == pageID }) ?? 0
        return HStack(spacing: 4) {
            Button { switchPage(note.pages[index - 1].id) } label: { Image(systemName: "chevron.left") }
                .disabled(index == 0).accessibilityLabel("上一页")
            Menu {
                ForEach(Array(note.pages.enumerated()), id: \.element.id) { offset, item in
                    Button("第 \(offset + 1) 页") { switchPage(item.id) }
                }
            } label: {
                Text("\(index + 1) / \(note.pages.count)").font(.subheadline.monospacedDigit()).frame(minWidth: 56)
            }.accessibilityLabel("选择页面").accessibilityValue("\(index + 1) / \(note.pages.count)").accessibilityIdentifier("pageNumber")
            Button { switchPage(note.pages[index + 1].id) } label: { Image(systemName: "chevron.right") }
                .disabled(index + 1 == note.pages.count).accessibilityLabel("下一页")
            Divider().frame(height: 22).padding(.horizontal, 4)
            Button {
                if let next = store.addPage(to: noteID) { switchPage(next) }
            } label: { Image(systemName: "plus.rectangle.on.rectangle") }
                .accessibilityLabel("新增一页").accessibilityIdentifier("addPage")
        }
        .buttonStyle(PageControlButtonStyle())
        .padding(6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.primary.opacity(0.1)))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("pageControls")
    }

    private func toolbarCenter(in geometry: GeometryProxy, size: CGSize) -> CGPoint {
        let inset: CGFloat = 12
        let x = min(max(toolbarAnchor.x * geometry.size.width, size.width / 2 + inset), max(size.width / 2 + inset, geometry.size.width - size.width / 2 - inset))
        let y = min(max(toolbarAnchor.y * geometry.size.height, size.height / 2 + max(inset, geometry.safeAreaInsets.top)), max(size.height / 2 + inset, geometry.size.height - size.height / 2 - max(inset, geometry.safeAreaInsets.bottom)))
        return CGPoint(x: x, y: y)
    }

    private func requestZoom(fit: Bool) {
        fitWholePage = fit
        zoomRequest += 1
        settingsVisible = false
    }

    private func switchPage(_ id: UUID) {
        // Load the selected drawing together with its identity before rendering it.
        pageID = id
        loadPage()
    }

    private func loadPage() {
        drawing = store.drawing(noteID: noteID, pageID: pageID)
        if let pdfPage = store.pdfPage(noteID: noteID, pageID: pageID) {
            paperSize = PDFImportService.pageSize(pdfPage)
            return
        }
        let bounds = drawing.bounds
        let ratio: CGFloat = 210 / 297
        let width = bounds.isNull ? 595 : max(595, bounds.maxX + 24, (bounds.maxY + 24) * ratio)
        paperSize = CGSize(width: width, height: width / ratio)
    }
}

private struct PageControlButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.frame(minWidth: 40, minHeight: 44)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

/// Zoom the template and ink together; the PKCanvasView keeps fixed page coordinates.
private struct ZoomablePaper<Content: View>: UIViewControllerRepresentable {
    var size: CGSize
    var request: Int
    var fitWholePage: Bool
    @ViewBuilder var content: () -> Content

    func makeUIViewController(context: Context) -> PaperScrollController<Content> {
        PaperScrollController(content: content(), size: size)
    }

    func updateUIViewController(_ controller: PaperScrollController<Content>, context: Context) {
        controller.update(content: content(), size: size, request: request, fit: fitWholePage)
    }
}

private final class PaperScrollController<Content: View>: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    private let scroll = UIScrollView()
    private let paper: UIHostingController<Content>
    private var paperSize: CGSize
    private var lastViewport = CGSize.zero
    private var needsPaperLayout = true
    private var adjusting = false
    private let pinch = UIPinchGestureRecognizer()
    private var pinchStartScale: CGFloat = 1
    private var pinchAnchor = CGPoint.zero
    private var lastRequest = -1
    private var pendingFit: Bool?
    private var zoomPolicy: Bool? = false // false=fill, true=fit, nil=user zoom

    init(content: Content, size: CGSize) {
        paper = UIHostingController(rootView: content)
        paperSize = size
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        scroll.frame = view.bounds
        scroll.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scroll.delegate = self
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.panGestureRecognizer.minimumNumberOfTouches = 2
        scroll.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        pinch.addTarget(self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        pinch.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        scroll.addGestureRecognizer(pinch)
        scroll.accessibilityIdentifier = "zoomScrollView"
        scroll.accessibilityLabel = "笔记页面"
        view.addSubview(scroll)
        addChild(paper)
        paper.view.backgroundColor = .white
        // Do not inset paper content for the iPad safe areas; overlays handle them.
        paper.safeAreaRegions = []
        scroll.addSubview(paper.view)
        paper.didMove(toParent: self)
    }

    func update(content: Content, size: CGSize, request: Int, fit: Bool) {
        paper.rootView = content
        if size != paperSize { paperSize = size; needsPaperLayout = true }
        if request != lastRequest { lastRequest = request; pendingFit = fit }
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let viewport = scroll.bounds.size
        guard viewport.width > 0, viewport.height > 0 else { return }
        let resized = viewport != lastViewport || needsPaperLayout
        guard resized || pendingFit != nil else { return }
        let relative = scroll.minimumZoomScale > 0 ? scroll.zoomScale / scroll.minimumZoomScale : 1
        let center = scroll.convert(CGPoint(x: scroll.bounds.midX, y: scroll.bounds.midY), to: paper.view)
        let initial = lastViewport == .zero || needsPaperLayout
        adjusting = true
        scroll.minimumZoomScale = 0.01
        scroll.maximumZoomScale = 100
        scroll.zoomScale = 1
        paper.view.frame = CGRect(origin: .zero, size: paperSize)
        paper.view.setNeedsLayout()
        paper.view.layoutIfNeeded()
        scroll.contentSize = paperSize
        let fit = min(viewport.width / paperSize.width, viewport.height / paperSize.height)
        let fill = max(viewport.width / paperSize.width, viewport.height / paperSize.height)
        scroll.minimumZoomScale = fit
        scroll.maximumZoomScale = max(fit * 6, fill * 4)
        // Own the pinch transform explicitly: native nested/hosted zoom did not
        // advance zoomScale in the device-style gesture regression.
        scroll.pinchGestureRecognizer?.isEnabled = false
        if let pendingFit { zoomPolicy = pendingFit }
        let target = zoomPolicy.map { $0 ? fit : fill } ?? fit * relative
        scroll.zoomScale = min(scroll.maximumZoomScale, max(fit, target))
        centerPaper()
        if initial || pendingFit != nil {
            scroll.contentOffset = CGPoint(x: max(-scroll.contentInset.left, (scroll.contentSize.width - viewport.width) / 2), y: -scroll.contentInset.top)
        } else {
            let x = center.x * scroll.zoomScale - viewport.width / 2
            let y = center.y * scroll.zoomScale - viewport.height / 2
            scroll.contentOffset = CGPoint(
                x: min(max(-scroll.contentInset.left, x), max(-scroll.contentInset.left, scroll.contentSize.width - viewport.width + scroll.contentInset.right)),
                y: min(max(-scroll.contentInset.top, y), max(-scroll.contentInset.top, scroll.contentSize.height - viewport.height + scroll.contentInset.bottom)))
        }
        lastViewport = viewport
        needsPaperLayout = false
        pendingFit = nil
        adjusting = false
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { paper.view }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if !adjusting { zoomPolicy = nil }
        centerPaper()
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            pinchStartScale = scroll.zoomScale
            pinchAnchor = paper.view.convert(gesture.location(in: scroll), from: scroll)
            zoomPolicy = nil
        case .changed:
            let location = gesture.location(in: scroll)
            let focus = CGPoint(x: location.x - scroll.bounds.minX, y: location.y - scroll.bounds.minY)
            let scale = min(scroll.maximumZoomScale, max(scroll.minimumZoomScale, pinchStartScale * gesture.scale))
            scroll.setZoomScale(scale, animated: false)
            centerPaper()
            scroll.contentOffset = clampedOffset(CGPoint(x: pinchAnchor.x * scale - focus.x, y: pinchAnchor.y * scale - focus.y))
        case .ended, .cancelled:
            scroll.contentOffset = clampedOffset(scroll.contentOffset)
        default:
            break
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        (gestureRecognizer === pinch && otherGestureRecognizer === scroll.panGestureRecognizer) ||
        (otherGestureRecognizer === pinch && gestureRecognizer === scroll.panGestureRecognizer)
    }

    private func clampedOffset(_ point: CGPoint) -> CGPoint {
        CGPoint(
            x: min(max(-scroll.contentInset.left, point.x), max(-scroll.contentInset.left, scroll.contentSize.width - scroll.bounds.width + scroll.contentInset.right)),
            y: min(max(-scroll.contentInset.top, point.y), max(-scroll.contentInset.top, scroll.contentSize.height - scroll.bounds.height + scroll.contentInset.bottom)))
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerPaper()
    }

    private func centerPaper() {
        let horizontal = max(0, (scroll.bounds.width - paperSize.width * scroll.zoomScale) / 2)
        let vertical = max(0, (scroll.bounds.height - paperSize.height * scroll.zoomScale) / 2)
        scroll.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        scroll.accessibilityValue = "缩放 \(Int((scroll.zoomScale / max(0.01, scroll.minimumZoomScale) * 100).rounded()))%"
    }
}
