import Foundation
import CoreServices

public protocol DocumentURLProtocol: CustomStringConvertible, CustomDebugStringConvertible {
    var wrappee: SKDocument { get }
    var asURL: URL { get }
    var name: String { get }
    var schemeName: String { get }
}

extension DocumentURLProtocol {
    /// Returns document URL object as `URL`.
    public var asURL: URL { SKDocumentCopyURL(wrappee)!.takeRetainedValue() as URL }

    /// The document name.
    public var name: String {
        SKDocumentGetName(wrappee)!.takeUnretainedValue() as String
    }

    /// The URI scheme.
    public var schemeName: String {
        SKDocumentGetSchemeName(wrappee)!.takeUnretainedValue() as String
    }
}

// MARK: - CustomStringConvertible

extension DocumentURLProtocol {
    public var description: String { asURL.description }
}

// MARK: - CustomDebugStringConvertible

extension DocumentURLProtocol {
    public var debugDescription: String { asURL.debugDescription }
}

// MARK: - URL+fromDocumentURL

extension URL {
    /// Creates URL from a document URL.
    /// - Parameter documentURL: The document URL.
    /// - Returns: An URL instance.
    public static func fromDocumentURL(_ documentURL: DocumentURLProtocol) -> URL {
        SKDocumentCopyURL(documentURL.wrappee)!.takeRetainedValue() as URL
    }
}
