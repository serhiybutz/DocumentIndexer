///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation

/// A backing wrapper of a persistent (on-disk) `SKIndex`.
final class PersistentIndex: Index {
    // MARK: - State

    // The backing `SKIndex`.
    private var _index: SKIndex!

    override var index: SKIndex { _index }

    // MARK: - Initialization

    init?(creatingAtURL url: URL, indexType: IndexType, textAnalysisProperties: TextAnalysisProperties) {
        super.init()

        // create a persistent index at given URL
        guard let index = SKIndexCreateWithURL(
                url as CFURL,
                nil,
                indexType.asSKIndexType,
                NSDictionary(textAnalysisProperties))?.takeRetainedValue()
        else {
            return nil
        }

        self._index = index
    }

    init?(openingAtURL url: URL) {
        super.init()

        // open a persistent index at given URL
        guard let index = SKIndexOpenWithURL(
                url as CFURL,
                nil,
                true)?.takeRetainedValue()
        else {
            return nil
        }

        self._index = index
    }
}
