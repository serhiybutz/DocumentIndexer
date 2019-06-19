///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import CoreServices

protocol IndexProvider {
    var index: SKIndex { get }
    var maximumDocumentID: Int { get }
    var documentCount: Int { get }
}

extension IndexProvider {
    var maximumDocumentID: Int { SKIndexGetMaximumDocumentID(index) }
    var documentCount: Int { SKIndexGetDocumentCount(index) }
}
