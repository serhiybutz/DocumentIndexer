///
/// This file is part of the DocumentIndexer package.
/// (c) Serge Bouts <sergebouts@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import os.log

fileprivate let log = OSLog(subsystem: ModuleIdentifier,
                            category: "Search")

public final class Search: Sequence {
    // MARK: - Types

    final public class Iterator: IteratorProtocol {
        // MARK: - State

        let search: Search
        lazy var documentIDs: [SKDocumentID] = Array(repeating: 0, count: search.hitsAtATime)
        lazy var scores: [Float] = Array(repeating: 0, count: search.hitsAtATime)
        lazy var documentURLs: [Unmanaged<SKDocument>?] = Array(repeating: nil, count: search.hitsAtATime)
        public var isInProgress: Bool = true
        var occurrences = 0

        // MARK: - Initialization

        init(search: Search) {
            self.search = search
        }

        // MARK: - IteratorProtocol

        public func next() -> [SearchHit]? {
            guard isInProgress else { return nil }

            var result: [SearchHit]?

            isInProgress = SKSearchFindMatches(search.search, search.hitsAtATime, &documentIDs, &scores, search.maximumTime, &occurrences)

            if occurrences > 0 {
                SKIndexCopyDocumentRefsForDocumentIDs(search.index.index, occurrences, &documentIDs, &documentURLs)

                let documentURLsAndScores: [(Unmanaged<SKDocument>?, Float)] = Array(zip(documentURLs[0..<occurrences], scores))
                result = documentURLsAndScores.compactMap { documentURLObject, score in
                    guard let documentURL = (documentURLObject?.takeRetainedValue()).map({ DocumentURL($0) }) else { return nil }
                    return SearchHit(documentURL: documentURL, score: score)
                }
            } else {
                if isInProgress {
                    os_log("Search returned with no matches found while it's still in progress! Perhaps it's exceeded the maximum allowed time (%f sec).", log: log, type: .info, search.maximumTime)
                    result = [] // return an empty array
                }
            }

            return result
        }
    }

    // MARK: - State

    let index: IndexProvider
    let query: String
    let options: SearchOptions
    let hitsAtATime: Int
    let maximumTime: TimeInterval
    let search: SKSearch

    // MARK: - Initialization
    
    init(for query: String,
         options: SearchOptions,
         hitsAtATime: Int,
         maximumTime: TimeInterval,
         index: IndexProvider)
    {
        self.query = query
        self.options = options
        self.hitsAtATime = hitsAtATime
        self.maximumTime = maximumTime
        self.index = index
        let searchOptions = SKSearchOptions(options.rawValue)
        self.search = SKSearchCreate(index.index, query as CFString, searchOptions).takeRetainedValue()
    }

    deinit {
        /// Cancels an outstanding search operation.
        SKSearchCancel(search)
    }

    // MARK: - Sequance

    public func makeIterator() -> Iterator {
        return Iterator(search: self)
    }
}
