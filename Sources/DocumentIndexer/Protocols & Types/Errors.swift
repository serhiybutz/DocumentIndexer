///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

public enum DocumentIndexingError: Error {
    case failedToIndex(DocumentURLProtocol)
    case failedToRemove(DocumentURLProtocol)
    case failedToSetDocumentProperties(DocumentURLProtocol)
    case failedToGetDocumentProperties(DocumentURLProtocol)
}

public enum DocumentIndexingExtraError: Error {
    case failedToFlush
    case failedToCompact
}
