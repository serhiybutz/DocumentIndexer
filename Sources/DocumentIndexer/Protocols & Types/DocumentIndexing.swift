///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

public protocol DocumentIndexing {
    func indexDocument(at url: DocumentURLProtocol, withText text: String) throws
    func indexFileDocument(at url: FileDocumentURL, mimeTypeHint: String?) throws
    func removeDocument(at url: DocumentURLProtocol) throws
    func flush() throws
    var documentCount: Int { get }
    func setDocumentProperties(at url: DocumentURLProtocol, properties: [AnyHashable: Any])
    func getDocumentProperties(at url: DocumentURLProtocol) -> [AnyHashable: Any]?
}
