///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import CoreServices

/// A file-restricted wrapper around Search Kit's document URL object.
///
/// - See Also: [SKDocument](https://developer.apple.com/documentation/coreservices/skdocument)
public struct FileDocumentURL: DocumentURLProtocol {
    // MARK: - State

    public let wrappee: SKDocument

    // MARK: - Initialization

    /// Creates an instance of `FileDocumentURL` from a document URL object.
    /// - Parameter documentURLObject: The document URL object.
    public init?(_ documentURLObject: SKDocument) {
        let url = SKDocumentCopyURL(documentURLObject)!.takeRetainedValue() as URL
        guard url.isFileURL else { return nil }
        self.wrappee = documentURLObject
    }

    /// Creates an instance of `FileDocumentURL` from a document URL object.
    /// - Parameter url: The document URL.
    public init?(_ url: URL) {
        guard url.isFileURL else { return nil }
        guard let documentURLObject = SKDocumentCreateWithURL(url as CFURL)?.takeRetainedValue() else { return nil }
        self.wrappee = documentURLObject
    }

    /// Create an instance of `FileDocumentURL` by its components.
    ///
    /// - Parameters:
    ///   - scheme: The URI scheme.
    ///   - parent: The parent document URL.
    ///   - name: The document name.
    public init?(scheme: String, parent: FileDocumentURL, name: String) {
        guard parent.asURL.isFileURL else { return nil }
        guard let documentURLObject = SKDocumentCreate(scheme as CFString, parent.wrappee, name as CFString)?.takeRetainedValue() else { return nil }
        self.wrappee = documentURLObject
    }

    // MARK: - Properties

    /// The parent file document URL.
    public var parent: FileDocumentURL? {
        (SKDocumentGetParent(wrappee)?.takeUnretainedValue()).map { FileDocumentURL($0)! }
    }
}

// MARK: - Equatable, Comparable, Identifiable, Hashable

extension FileDocumentURL: Equatable, Identifiable, Hashable {
    public static func == (lhs: FileDocumentURL, rhs: FileDocumentURL) -> Bool { lhs.id == rhs.id }
    public static func < (lhs: FileDocumentURL, rhs: FileDocumentURL) -> Bool { lhs.asURL.absoluteString < rhs.asURL.absoluteString }
    public var id: String { asURL.absoluteString }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
