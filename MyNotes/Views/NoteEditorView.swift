import SwiftUI
import PencilKit

struct NoteEditorView: View {
    let noteID: UUID
    @ObservedObject var store: NoteStore

    @State private var pageID: UUID
    @State private var drawing = PKDrawing()
    @State private var tool: DrawingTool = .pen
    @State private var color: Color = .black
    @State private var width: Double = 4
    @State private var paperSize = CGSize(width: 595, height: 595 * 297 / 210)

    init(noteID: UUID, store: NoteStore) {
        self.noteID = noteID
        self.store = store
        _pageID = State(initialValue: store.note(id: noteID)?.pages.first?.id ?? UUID())
    }

    private var note: NoteRecord? { store.note(id: noteID) }
    private var page: PageRecord? { note?.pages.first(where: { $0.id == pageID }) }

    var body: some View {
        VStack(spacing: 0) {
            if let note, let page {
                HStack(spacing: 12) {
                    Picker("工具", selection: $tool) {
                        Text("画笔").tag(DrawingTool.pen)
                        Text("橡皮擦").tag(DrawingTool.eraser)
                        Text("套索").tag(DrawingTool.lasso)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 255)

                    ColorPicker("颜色", selection: $color, supportsOpacity: false)
                        .frame(maxWidth: 100)
                    Slider(value: $width, in: 1...20)
                        .frame(maxWidth: 140)
                        .accessibilityLabel("笔粗")
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Divider()

                GeometryReader { geometry in
                    let scale = max(0.01, min(
                        (geometry.size.width - 32) / paperSize.width,
                        (geometry.size.height - 32) / paperSize.height
                    ))
                    ZStack {
                        Color(uiColor: .secondarySystemBackground)
                        ZStack {
                            PaperBackground(style: page.style)
                            PencilCanvas(
                                drawing: drawing,
                                tool: tool,
                                color: UIColor(color),
                                width: CGFloat(width)
                            ) { editedDrawing in
                                drawing = editedDrawing
                                store.saveDrawing(editedDrawing, noteID: noteID, pageID: pageID)
                            }
                            .id(pageID)
                        }
                        // Scale the complete page, not its drawing coordinates.
                        .frame(width: paperSize.width, height: paperSize.height)
                        .environment(\.colorScheme, .light)
                        .clipped()
                        .overlay(Rectangle().stroke(Color.black.opacity(0.12), lineWidth: 1))
                        .shadow(color: .black.opacity(0.16), radius: 6, y: 2)
                        .scaleEffect(scale)
                        .frame(width: paperSize.width * scale, height: paperSize.height * scale)
                    }
                }

                HStack {
                    Picker("页面", selection: $pageID) {
                        ForEach(note.pages.indices, id: \.self) { index in
                            Text("第 \(index + 1) 页").tag(note.pages[index].id)
                        }
                    }
                    .frame(maxWidth: 160)

                    Picker("纸张", selection: Binding(
                        get: { page.style },
                        set: { store.setPaperStyle($0, noteID: noteID, pageID: pageID) }
                    )) {
                        ForEach(PaperStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .frame(maxWidth: 130)

                    Spacer()
                    Text("\(note.pages.count) 页").foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            } else {
                ContentUnavailableView("笔记不存在", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(note?.title ?? "笔记")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let next = store.addPage(to: noteID) { pageID = next }
                } label: {
                    Label("添加页面", systemImage: "plus.rectangle.on.rectangle")
                }
            }
        }
        .onAppear(perform: loadPage)
        .onChange(of: pageID) { _, _ in loadPage() }
    }

    private func loadPage() {
        drawing = store.drawing(noteID: noteID, pageID: pageID)
        // Legacy pages had viewport-sized coordinates. Expand the portrait sheet
        // to contain their existing positive-coordinate ink, without rewriting it.
        let bounds = drawing.bounds
        let ratio: CGFloat = 210 / 297
        let width = bounds.isNull ? 595 : max(595, bounds.maxX + 24, (bounds.maxY + 24) * ratio)
        paperSize = CGSize(width: width, height: width / ratio)
    }
}
