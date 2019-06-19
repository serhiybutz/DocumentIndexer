///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// A search hit.
public struct SearchHit {
    /// A document URL object.
    public let documentURL: DocumentURL
    /// A hit relevance score (not normalized).
    public let score: Float
    
    public init(documentURL: DocumentURL, score: Float) {
        self.documentURL = documentURL
        self.score = score
    }
}
