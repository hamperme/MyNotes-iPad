import Foundation

enum PaperStyle: String, Codable, CaseIterable, Identifiable {
    case blank, ruled, grid, dotted
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .blank: "空白"
        case .ruled: "横线"
        case .grid: "方格"
        case .dotted: "点阵"
        }
    }
}

struct PageRecord: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var style: PaperStyle = .ruled
}

struct NoteRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var createdAt: Date = .now
    var updatedAt: Date = .now
    var pages: [PageRecord] = [PageRecord()]
}
