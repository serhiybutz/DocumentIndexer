///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// A backing wrapper for an in-memory `SKIndex`.
final class InMemoryIndex: Index {
    // MARK: - State

    // The wrapped `SKIndex`.
    private var _index: SKIndex!

    override var index: SKIndex { _index }

    // MARK: - Initialization

    init?(indexType: IndexType, textAnalysisProperties: TextAnalysisProperties) {
        super.init()

        // create an index in memory
        guard let index = SKIndexCreateWithMutableData(
                NSMutableData(),
                nil,
                indexType.asSKIndexType,
                NSDictionary(textAnalysisProperties))?.takeRetainedValue()
        else {
            return nil
        }

        self._index = index
    }
}
