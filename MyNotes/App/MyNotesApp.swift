import SwiftUI

@main
struct MyNotesApp: App {
    @StateObject private var store = NoteStore()

    var body: some Scene {
        WindowGroup {
            LibraryView(store: store)
        }
    }
}
