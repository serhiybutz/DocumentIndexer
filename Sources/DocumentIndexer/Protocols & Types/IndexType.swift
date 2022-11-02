///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// A type of index.
public enum IndexType {
    /// An unknown index type.
    /// - See More: [kSKIndexUnknown](https://developer.apple.com/documentation/coreservices/kskindexunknown)
    case unknown
    /// An inverted index, mapping terms to documents.
    /// - See More: [kSKIndexInverted](https://developer.apple.com/documentation/coreservices/skindextype/kskindexinverted)
    case inverted
    /// A vector index, mapping documents to terms.
    /// - See More: [kSKIndexVector](https://developer.apple.com/documentation/coreservices/skindextype/kskindexvector)
    case vector
    /// An index type with all the capabilities of both inverted and vector index.
    /// - See More: [kSKIndexInvertedVector](https://developer.apple.com/documentation/coreservices/skindextype/kskindexinvertedvector)
    case invertedVector
    var asSKIndexType: SKIndexType {
        switch self {
        case .unknown: return kSKIndexUnknown
        case .inverted: return kSKIndexInverted
        case .vector: return kSKIndexVector
        case .invertedVector: return kSKIndexInvertedVector
        }
    }
}
