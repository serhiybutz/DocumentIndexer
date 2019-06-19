///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

// TODO: rename to InMemoryDocumentIndexer?

/// An in-memory document indexer that is a wrapper around Search Kit's `SKIndex`.
///
/// - See Also: [Search Kit](https://developer.apple.com/documentation/coreservices/search_kit), [SKIndex](https://developer.apple.com/documentation/coreservices/skindex), [SKIndexCreateWithMutableData](https://developer.apple.com/documentation/coreservices/1447500-skindexcreatewithmutabledata)
open class InMemoryDocumentIndexer: DocumentIndexer {
    // MARK: - State

    let indexType: IndexType
    let textAnalysisProperties: TextAnalysisProperties

    // MARK: - Initialization

    /// Creates an instance of an in-memory document indexer, which is a wrapper around `SKIndex` (see more [SKIndex](https://developer.apple.com/documentation/coreservices/skindex), [SKIndexCreateWithMutableData](https://developer.apple.com/documentation/coreservices/1447500-skindexcreatewithmutabledata)) or returns `nil` on failure.
    ///
    /// - Parameters:
    ///   - indexType: The type of the index.
    ///   - autoflushStrategy: The auto-flush strategy.
    ///   - textAnalysisProperties: The text analysis properties.
    ///   - fragmentationStatePreserver: The fragmentation state provider.
    ///
    /// - See Also: [SKIndex](https://developer.apple.com/documentation/coreservices/skindex), [SKIndexCreateWithMutableData](https://developer.apple.com/documentation/coreservices/1447500-skindexcreatewithmutabledata)
    public init?(indexType: IndexType = .inverted,
                 autoflushStrategy: AutoflushStrategy = .none,
                 textAnalysisProperties: TextAnalysisProperties = .default,
                 fragmentationStatePreserver: FragmentationStatePreserver? = nil)
    {
        self.indexType = indexType
        self.textAnalysisProperties = textAnalysisProperties
        super.init(autoflushStrategy: autoflushStrategy, fragmentationStatePreserver: fragmentationStatePreserver)
    }

    // MARK: - Life cycle

    override func makeIndex() -> IndexProvider? {
        let index = InMemoryIndex(indexType: indexType, textAnalysisProperties: textAnalysisProperties)
        fragmentationStatePreserver?.preserve((maximumDocumentID, documentCount))
        return index
    }
}
