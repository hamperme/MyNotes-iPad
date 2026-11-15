import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @ObservedObject var store: NoteStore
    @State private var path: [UUID] = []
    @State private var importPresented = false
    @State private var importError: String?

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let error = store.loadError {
                    ContentUnavailableView(
                        "无法读取笔记",
                        systemImage: "externaldrive.badge.exclamationmark",
                        description: Text(error)
                    )
                } else if store.notes.isEmpty {
                    ContentUnavailableView(
                        "还没有笔记",
                        systemImage: "square.and.pencil",
                        description: Text("点击右上角加号开始手写")
                    )
                } else {
                    List(store.notes) { note in
                        NavigationLink(value: note.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title).font(.headline)
                                Text("\(note.pages.count) 页 · \(note.updatedAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("MyNotes")
            .toolbar {
                Button {
                    importPresented = true
                } label: {
                    Label("导入 PDF", systemImage: "square.and.arrow.down")
                }
                .accessibilityIdentifier("importPDF")
                .disabled(store.loadError != nil || store.isImporting)
                Button {
                    if let id = store.createNote() { path.append(id) }
                } label: {
                    Label("新建笔记", systemImage: "plus")
                }
                .disabled(store.loadError != nil)
            }
            .navigationDestination(for: UUID.self) { noteID in
                NoteEditorView(noteID: noteID, store: store)
            }
        }
        .fileImporter(isPresented: $importPresented, allowedContentTypes: [.pdf]) { result in
            switch result {
            case .success(let url): receivePDF(url)
            case .failure(let error): importError = error.localizedDescription
            }
        }
        .onOpenURL(perform: receivePDF)
        .overlay {
            if store.isImporting {
                ProgressView("正在导入 PDF…")
                    .padding(24).background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityIdentifier("pdfImportProgress")
            }
        }
        .alert("无法导入 PDF", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
            Button("好", role: .cancel) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }

    private func receivePDF(_ url: URL) {
        Task { @MainActor in
            do {
                let id = try await store.importPDF(from: url)
                importPresented = false
                path = [id]
            } catch { importError = error.localizedDescription }
        }
    }
}
