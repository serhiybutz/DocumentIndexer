///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

public protocol DocumentIndexingExtra {
    var uncompactedDocuments: Int? { get }
    var maximumDocumentID: Int { get }
    func compact() throws
}
