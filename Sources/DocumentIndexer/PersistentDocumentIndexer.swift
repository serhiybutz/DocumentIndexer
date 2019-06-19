///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import Combine

/// A persistent (on-disk) document indexer that is a wrapper around Search Kit's `SKIndex`.
///
/// - See Also: [Search Kit](https://developer.apple.com/documentation/coreservices/search_kit), [SKIndex](https://developer.apple.com/documentation/coreservices/skindex), [SKIndexCreateWithURL](https://developer.apple.com/documentation/coreservices/1446111-skindexcreatewithurl), [SKIndexOpenWithURL](https://developer.apple.com/documentation/coreservices/1449017-skindexopenwithurl)
open class PersistentDocumentIndexer: DocumentIndexer {
    // MARK: - Types

    enum IndexConstruction {
        case creatingAtURL(URL)
        case openingAtURL(URL)
    }

    // MARK: - State

    let indexConstruction: IndexConstruction
    let indexType: IndexType?
    let textAnalysisProperties: TextAnalysisProperties?

    // MARK: - Initialization

    /// Creates a new instance of a persistent (on-disk) document indexer at the `url` or returns `nil` on failure.
    ///
    /// This document indexer is a wrapper around `SKIndex` (see more [SKIndex](https://developer.apple.com/documentation/coreservices/skindex)).
    ///
    /// - Parameters:
    ///   - url: The URL of the index location.
    ///   - indexType: The type of the index.
    ///   - autoflushStrategy: The auto-flush strategy.
    ///   - textAnalysisProperties: The text analysis properties.
    ///   - fragmentationStatePreserver: The fragmentation state provider.
    ///
    /// - See Also: [SKIndex](https://developer.apple.com/documentation/coreservices/skindex), [SKIndexCreateWithURL](https://developer.apple.com/documentation/coreservices/1446111-skindexcreatewithurl)
    public init?(creatingAtURL url: URL,
                 indexType: IndexType = .inverted,
                 autoflushStrategy: AutoflushStrategy = .none,
                 textAnalysisProperties: TextAnalysisProperties = .default,
                 fragmentationStatePreserver: FragmentationStatePreserver? = nil)
    {
        self.indexConstruction = .creatingAtURL(url)
        self.indexType = indexType
        self.textAnalysisProperties = textAnalysisProperties
        super.init(autoflushStrategy: autoflushStrategy, fragmentationStatePreserver: fragmentationStatePreserver)
    }

    /// Opens an existing persistent (on-disk) document indexer at the `url` or returns `nil` on failure.
    ///
    /// This document indexer is a wrapper around `SKIndex` (see more [SKIndex](https://developer.apple.com/documentation/coreservices/skindex).
    ///
    /// - Parameters:
    ///   - url: The URL of the index location.
    ///   - autoflushStrategy: The auto-flush strategy.
    ///   - fragmentationStatePreserver: The fragmentation state provider.
    ///
    /// - See Also: [SKIndex](https://developer.apple.com/documentation/coreservices/skindex), [SKIndexOpenWithURL](https://developer.apple.com/documentation/coreservices/1449017-skindexopenwithurl)
    public init?(openingAtURL url: URL,
                 autoflushStrategy: AutoflushStrategy = .none,
                 fragmentationStatePreserver: FragmentationStatePreserver? = nil)
    {
        self.indexConstruction = .openingAtURL(url)
        self.indexType = nil // not used
        self.textAnalysisProperties = nil // not used
        super.init(autoflushStrategy: autoflushStrategy, fragmentationStatePreserver: fragmentationStatePreserver)
    }

    // MARK: - Life cycle

    override func makeIndex() -> IndexProvider? {
        switch indexConstruction {
        case .creatingAtURL(let url):
            guard let index = PersistentIndex(creatingAtURL: url, indexType: indexType!, textAnalysisProperties: textAnalysisProperties!) else { return nil }
            fragmentationStatePreserver?.preserve((index.maximumDocumentID, index.documentCount))
            return index
        case .openingAtURL(let url):
            return PersistentIndex(openingAtURL: url)
        }
    }
}
