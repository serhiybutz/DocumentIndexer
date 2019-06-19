///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import CoreServices

/// A wrapper around Search Kit's document URL object.
///
/// - See Also: [SKDocument](https://developer.apple.com/documentation/coreservices/skdocument)
public struct DocumentURL: DocumentURLProtocol {
    // MARK: - State

    public let wrappee: SKDocument

    // MARK: - Initialization

    /// Create an instance of `DocumentURL` from a document URL object.
    /// - Parameter documentURLObject: The document URL object.
    public init(_ documentURLObject: SKDocument) {
        self.wrappee = documentURLObject
    }

    /// Create an instance of `DocumentURL` from a document URL.
    /// - Parameter url: The document URL.
    public init?(_ url: URL) {
        guard let documentURLObject = SKDocumentCreateWithURL(url as CFURL)?.takeRetainedValue() else { return nil }
        self.wrappee = documentURLObject
    }

    /// Create an instance of `DocumentURL` by its components.
    /// - Parameters:
    ///   - scheme: The URI scheme.
    ///   - parent: The parent document URL.
    ///   - name: The document name.
    public init?(scheme: String, parent: DocumentURLProtocol, name: String) {
        guard let documentURLObject = SKDocumentCreate(scheme as CFString, parent.wrappee, name as CFString)?.takeRetainedValue() else { return nil }
        self.wrappee = documentURLObject
    }

    // MARK: - Properties

    /// The parent document URL.
    public var parent: DocumentURL? {
        (SKDocumentGetParent(wrappee)?.takeUnretainedValue()).map { DocumentURL($0) }
    }
}

// MARK: - Equatable, Comparable, Identifiable, Hashable

extension DocumentURL: Equatable, Identifiable, Hashable {
    public static func == (lhs: DocumentURL, rhs: DocumentURL) -> Bool { lhs.id == rhs.id }
    public static func < (lhs: DocumentURL, rhs: DocumentURL) -> Bool { lhs.asURL.absoluteString < rhs.asURL.absoluteString }
    public var id: String { asURL.absoluteString }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
