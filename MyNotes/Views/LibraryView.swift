import SwiftUI

struct LibraryView: View {
    @ObservedObject var store: NoteStore
    @State private var path: [UUID] = []

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
    }
}
