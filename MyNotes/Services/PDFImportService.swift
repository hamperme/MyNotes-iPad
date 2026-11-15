import Foundation
import PDFKit

enum PDFImportError: LocalizedError {
    case notAFile, invalidPDF, encrypted, tooLarge, tooManyPages, invalidPage, busy, storageUnavailable

    var errorDescription: String? {
        switch self {
        case .notAFile: "请选择 PDF 文件，不能导入网页链接。"
        case .invalidPDF: "无法读取这个 PDF，文件可能损坏或不是 PDF。"
        case .encrypted: "暂不支持加密 PDF。请先在原应用中导出可直接打开的 PDF 副本。"
        case .tooLarge: "PDF 超过 100 MB，请拆分后再导入。"
        case .tooManyPages: "PDF 超过 1000 页，请拆分后再导入。"
        case .invalidPage: "PDF 含有无法读取或尺寸异常的页面，未导入。"
        case .busy: "正在导入另一个 PDF，请完成后再试。"
        case .storageUnavailable: "笔记索引不可用，请先备份并排查，未导入文件。"
        }
    }
}

struct PreparedPDF: Sendable {
    let id: UUID
    let stagingURL: URL
    let title: String
    let pageCount: Int
}

enum PDFImportService {
    static let maximumBytes = 100 * 1024 * 1024

    /// Runs off the main actor. The caller holds security-scoped access until this returns.
    static func prepare(from source: URL, root: URL) throws -> PreparedPDF {
        guard source.isFileURL else { throw PDFImportError.notAFile }
        let id = UUID()
        let staging = root.appendingPathComponent(".import-\(id.uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: false)
        var keepStaging = false
        defer { if !keepStaging { try? FileManager.default.removeItem(at: staging) } }
        let copy = staging.appendingPathComponent("source.pdf")
        var coordinationError: NSError?
        var readError: Error?
        NSFileCoordinator().coordinate(readingItemAt: source, options: .withoutChanges, error: &coordinationError) { readable in
            do {
                let values = try readable.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
                guard values.isRegularFile == true else { throw PDFImportError.notAFile }
                guard let size = values.fileSize, size > 0 else { throw PDFImportError.invalidPDF }
                guard size <= maximumBytes else { throw PDFImportError.tooLarge }
                try FileManager.default.copyItem(at: readable, to: copy)
            } catch { readError = error }
        }
        if let coordinationError { throw coordinationError }
        if let readError { throw readError }
        let size = try copy.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size > 0, size <= maximumBytes else { throw PDFImportError.tooLarge }
        guard let document = PDFDocument(url: copy) else { throw PDFImportError.invalidPDF }
        guard !document.isEncrypted else { throw PDFImportError.encrypted }
        guard document.pageCount > 0 else { throw PDFImportError.invalidPDF }
        guard document.pageCount <= 1000 else { throw PDFImportError.tooManyPages }
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index), validSize(pageSize(page)) else { throw PDFImportError.invalidPage }
        }
        let filename = source.deletingPathExtension().lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines)
        keepStaging = true
        return PreparedPDF(id: id, stagingURL: staging, title: filename.isEmpty ? "导入的 PDF" : String(filename.prefix(200)), pageCount: document.pageCount)
    }

    static func pageSize(_ page: PDFPage) -> CGSize {
        let box = page.bounds(for: .cropBox)
        let rotation = ((page.rotation % 360) + 360) % 360
        return rotation == 90 || rotation == 270
            ? CGSize(width: box.height, height: box.width) : box.size
    }

    private static func validSize(_ size: CGSize) -> Bool {
        size.width.isFinite && size.height.isFinite && size.width >= 1 && size.height >= 1 && size.width <= 14400 && size.height <= 14400
    }
}
