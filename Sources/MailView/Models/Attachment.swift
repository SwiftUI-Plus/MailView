import Foundation
import UniformTypeIdentifiers

/// Represents an attachement associated with a `Mail` instance
public struct Attachment: Codable, Sendable, CustomStringConvertible, Identifiable, Hashable {
    public private(set) var id: UUID
    public private(set) var bookmark: Data
    public let contentType: UTType
    public let filename: String

    public var description: String {
        "\(filename), \(contentType)"
    }

    /// Makes a new attachment to be associated with a `Mail` instance
    /// - Parameters:
    ///   - data: The underlying data representation of this attachment
    ///   - contentType: The content type representing the data in this attachment
    ///   - filename: The preferred filename to use for this attachment (excluding extension)
    ///
    ///   - Note: The data will be written to local storage and then referenced by this attachment
    ///   ensuring low-memory consumption and efficient storage when encoded.
    public init(_ data: Data, contentType: UTType, filename: String) async throws {
        self.id = .init()
        self.contentType = contentType
        self.filename = filename

        bookmark = try await withCheckedThrowingContinuation { [id] continuation in
            DispatchQueue.global().async {
                do {
                    let url = URL(filename: id.uuidString)
                    try data.write(to: url, options: .atomicWrite)
                    let bookmark = try url.bookmarkData(options: .minimalBookmark)
                    continuation.resume(returning: bookmark)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Makes a new attachment to be associated with a `Mail` instance
    /// - Parameter url: A file URL referencing the attachment data
    /// - throws: A an error if the URL does not represent a local file URL or is not readable
    public init(file: URL) throws {
        _ = file.startAccessingSecurityScopedResource()
        defer { file.stopAccessingSecurityScopedResource() }

        guard FileManager.default.fileExists(atPath: file.path) else {
            throw CocoaError(.fileNoSuchFile)
        }

        guard FileManager.default.isReadableFile(atPath: file.path) else {
            throw CocoaError(.fileReadNoPermission)
        }

        id = .init()
        contentType = UTType(filenameExtension: file.pathExtension) ?? .text
        filename = file.lastPathComponent

        // in case the URL is outside of our sandbox, we try security scoping
        // if this fails, we'll still try and create the bookmark but it will
        // likely fail and throw accordingly

        bookmark = try file.bookmarkData(options: .minimalBookmark)
    }
}

extension Attachment {
    public func url() throws -> URL {
        var isStale: Bool = false
        do {
            let url = try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
            guard !isStale else {
                // if the bookmark is stale, we need to generate a new one
                let bookmark = try url.bookmarkData(options: .minimalBookmark)
                return try URL(resolvingBookmarkData: bookmark, bookmarkDataIsStale: &isStale)
            }
            return url
        }
    }

    @available(swift, obsoleted: 1, message: "Data will no longer be stored directly on the attachment.")
    public var data: Data { .init() }

    @available(swift, deprecated: 1, renamed: "filename")
    public var preferredFilename: String { filename }
    @available(swift, deprecated: 1, renamed: "contentType.preferredMIMEType")
    public var mimeType: String { contentType.preferredMIMEType ?? contentType.identifier }

    @available(swift, deprecated: 1, message: "Use init(:contentType:filename:) instead")
    public init(data: Data, mimeType: String, preferredFilename: String) {
        self.id = .init()
        self.contentType = .init(mimeType: mimeType) ?? .data
        self.filename = preferredFilename

        do {
            let url = URL(filename: preferredFilename)
            self.bookmark = try url.bookmarkData(options: .minimalBookmark)
            try data.write(to: url, options: .atomicWrite)
        } catch {
            self.bookmark = .init()
            print(error)
        }
    }
}
