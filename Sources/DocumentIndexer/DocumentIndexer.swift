///
/// This file is part of the DocumentIndexer package.
/// (c) Serhiy Butz <serhiybutz@gmail.com>
///
/// For the full copyright and license information, please view the LICENSE
/// file that was distributed with this source code.
///

import Foundation
import CoreServices
import os.log

fileprivate let log = OSLog(subsystem: ModuleIdentifier,
                            category: "Document Indexer")

/// A base class for document indexers that implement wrappers around Search Kit's `SKIndex`.
///
/// - See Also: [Search Kit](https://developer.apple.com/documentation/coreservices/search_kit), [SKIndex](https://developer.apple.com/documentation/coreservices/skindex)
open class DocumentIndexer {
    // MARK: - State

    private var _index: IndexProvider!

    private let _writeLock = NSRecursiveLock()

    let autoflushStrategy: AutoflushStrategy
    let fragmentationStatePreserver: FragmentationStatePreserver?

    private var _areTextImportersLoaded: Bool = false

    // MARK: - Initialization

    init?(autoflushStrategy: AutoflushStrategy = .none,
          fragmentationStatePreserver: FragmentationStatePreserver? = nil)
    {
        self.autoflushStrategy = autoflushStrategy
        self.fragmentationStatePreserver = fragmentationStatePreserver
        guard let index = makeIndex() else { return nil }
        self._index = index
    }

    // MARK: - Life cycle

    func makeIndex() -> IndexProvider? {
        preconditionFailure("Must Override")
    }
}

// MARK: - Helpers

extension DocumentIndexer {
    private func loadTextImportersIfNeeded() {
        if !_areTextImportersLoaded {
            SKLoadDefaultExtractorPlugIns()
            _areTextImportersLoaded = true
        }
    }
}

// MARK: - DocumentSearching

extension DocumentIndexer: DocumentSearching {
    /// Creates a document searcher sequence that provides search result hits in `hitsAtATime`-sized blocks for the given `query` string.
    ///
    /// - Parameters:
    ///   - query: The search query string. For the query formatting see [SKSearchCreate](https://developer.apple.com/documentation/coreservices/1443079-sksearchcreate)
    ///   - options: The search options
    ///   - hitsAtATime: The number of hits to return at a time. If the search time has exceeded `maximumTime` seconds the returned search hits block may be incomplete. By default it is 256
    ///   - maximumTime: The maximum number of seconds to wait for the search results, whether or not `hitsAtATime` items have been found. Setting `maximumTime` to 0 tells the search to return quickly. By default it is 5 seconds
    /// - Returns: A document searcher sequence, an instance of `Search`.

    ///
    /// - See Also: [SKSearchCreate](https://developer.apple.com/documentation/coreservices/1443079-sksearchcreate), [SKSearchFindMatches](https://developer.apple.com/documentation/coreservices/1448608-sksearchfindmatches)
    public func makeSearch(for query: String,
                           options: SearchOptions = .default,
                           hitsAtATime: Int = 256,
                           maximumTime: TimeInterval = 5) -> Search
    {
        if case .beforeEachSearch = autoflushStrategy {
            do {
                try flush()
            } catch {
                os_log("Failed to flush", log: log, type: .error)
            }
        }
        return Search(for: query, options: options, hitsAtATime: hitsAtATime, maximumTime: maximumTime, index: _index)
    }

    /// Searches the indexed documents for the given `query` string calling the `completion` handler with `hitsAtATime` hits at a time.
    ///
    /// - Parameters:
    ///   - query: The search query string. For the query formatting see [SKSearchCreate](https://developer.apple.com/documentation/coreservices/1443079-sksearchcreate)
    ///   - options: The search options
    ///   - hitsAtATime: The maximum number of hits to return at a time. If the search time has exceeded `maximumTime` seconds the returned search hits may be incomplete. By default it is 256
    ///   - maximumTime: The maximum number of seconds to wait for the search results, whether or not `hitsAtATime` items have been found. Setting `maximumTime` to 0 tells the search to return quickly. By default it is 5 seconds
    ///   - completion: The completion handler that is called asynchronously with the resulted `hits` array, the `hasMore` flag to indicate the search is still in progress, and the `shouldStop` flag reference for breaking the search
    ///   - hits: The search hits array
    ///   - hasMore: The flag indicating the search is still in progress
    ///   - shouldStop: The reference to the flag for breaking the search
    ///
    /// - See Also: [SKSearchCreate](https://developer.apple.com/documentation/coreservices/1443079-sksearchcreate), [SKSearchFindMatches](https://developer.apple.com/documentation/coreservices/1448608-sksearchfindmatches)
    public func search(for query: String,
                       options: SearchOptions = .default,
                       hitsAtATime: Int = 256,
                       maximumTime: TimeInterval = 5,
                       completion: (_ hits: [SearchHit], _ hasMore: Bool, _ shouldStop: inout Bool) -> Void)
    {
        // 1. The `hitsAtATime` should be a reasonable value, because it determines the size of preallocated result arrays.
        // 2. Since `search` is designed for asynchronous work scenarios, the `completion` closure must be called *at least once*.

        guard hitsAtATime > 0 else {
            // return early
            var shouldStop = false
            completion([], false, &shouldStop)
            return
        }

        let search = makeSearch(for: query, hitsAtATime: hitsAtATime, maximumTime: maximumTime)

        var shouldStop: Bool = false
        let iterator = search.makeIterator()
        repeat {
            let hits = iterator.next()
            completion(hits ?? [], iterator.isInProgress, &shouldStop)
        } while iterator.isInProgress && !shouldStop
    }
}

// MARK: - DocumentIndexing

extension DocumentIndexer: DocumentIndexing {
    /// Performs an operation of document (re)indexing by adding an arbitrary document URL object `url`, and the associated document’s textual content `text`, to an index.
    ///
    /// - Parameters:
    ///     - url: The document URL object that the indexed document is associated with.
    ///     - text: The textual document content to (re)index.
    /// - Throws:
    ///     - `DocumentIndexingError.failedToIndex(DocumentURL)`
    ///     in case of failure.
    ///
    /// - See Also: [SKIndexAddDocumentWithText](https://developer.apple.com/documentation/coreservices/1444518-skindexadddocumentwithtext)
    public func indexDocument(at url: DocumentURLProtocol, withText text: String) throws {
        _writeLock.lock()
        defer { _writeLock.unlock() }
        guard SKIndexAddDocumentWithText(_index.index, url.wrappee, text as CFString, true) else { throw DocumentIndexingError.failedToIndex(url) }
        if case .afterEachUpdate = autoflushStrategy {
            try flush()
        }
    }

    /// Performs an operation of document (re)indexing by adding location information for a file-based document `url`, and the document’s textual content, to an index.
    ///
    /// - Parameters:
    ///     - url: The file document URL object that the (re)indexed file-based document is located at.
    ///     - mimeTypeHint: The MIME type hint for the specified file-based document.
    /// - Throws:
    ///     - `DocumentIndexingError.failedToIndex(DocumentURL)`
    ///     in case of failure.
    ///
    /// - See Also: [SKIndexAddDocument](https://developer.apple.com/documentation/coreservices/1444897-skindexadddocument)
    public func indexFileDocument(at url: FileDocumentURL, mimeTypeHint: String? = "text/plain") throws {
        _writeLock.lock()
        defer { _writeLock.unlock() }
        loadTextImportersIfNeeded()
        guard SKIndexAddDocument(_index.index, url.wrappee, mimeTypeHint as CFString?, true) else { throw DocumentIndexingError.failedToIndex(url) }
        if case .afterEachUpdate = autoflushStrategy {
            try flush()
        }
    }

    /// Performs an operation of removing of a document and its children, if any, from an index.
    ///
    /// - Parameter url: The document URL object that the removed document is associated with.
    /// - Throws:
    ///     - `DocumentIndexingError.failedToRemove(DocumentURL)`
    ///     in case of failure.
    ///
    /// - See Also: [SKIndexRemoveDocument](https://developer.apple.com/documentation/coreservices/1444375-skindexremovedocument)
    public func removeDocument(at url: DocumentURLProtocol) throws {
        _writeLock.lock()
        defer { _writeLock.unlock() }
        guard SKIndexRemoveDocument(_index.index, url.wrappee) else { throw DocumentIndexingError.failedToRemove(url) }
        if case .afterEachUpdate = autoflushStrategy {
            try flush()
        }
    }

    /// Commits all in-memory changes to backing store.
    ///
    /// - Throws:
    ///     - `DocumentIndexingError.failedToFlush`
    ///     in case of failure.
    ///
    /// - See Also: [SKIndexFlush](https://developer.apple.com/documentation/coreservices/1450667-skindexflush)
    public func flush() throws {
        _writeLock.lock()
        defer { _writeLock.unlock() }

        guard SKIndexFlush(_index.index) else { throw DocumentIndexingExtraError.failedToFlush }
    }

    /// Gets the total number of documents represented in an index.
    ///
    /// - See Also: [SKIndexGetDocumentCount](https://developer.apple.com/documentation/coreservices/1449093-skindexgetdocumentcount)
    public var documentCount: Int { _index.documentCount }

    /// Sets the custom (application-defined) properties of a document URL object.
    ///
    /// - Parameters:
    ///   - url: The document URL object.
    ///   - properties: A dictionary containing the properties to apply to the document URL object.
    ///
    /// - See Also: [SKIndexSetDocumentProperties](https://developer.apple.com/documentation/coreservices/1444576-skindexsetdocumentproperties)
    public func setDocumentProperties(at url: DocumentURLProtocol, properties: [AnyHashable: Any]) {
        _writeLock.lock()
        defer { _writeLock.unlock() }
        SKIndexSetDocumentProperties(_index.index, url.wrappee, properties as CFDictionary)
    }

    /// Obtains the custom (application-defined) properties of an indexed document.
    ///
    /// - Parameter url: The document URL object.
    /// - Returns: A dictionary containing the document’s properties, or `nil` if no custom properties have been set on the specified document URL object.
    ///
    /// - See Also: [SKIndexCopyDocumentProperties](https://developer.apple.com/documentation/coreservices/1449500-skindexcopydocumentproperties)
    public func getDocumentProperties(at url: DocumentURLProtocol) -> [AnyHashable: Any]? {
        return SKIndexCopyDocumentProperties(_index.index, url.wrappee)?.takeRetainedValue() as! [AnyHashable: Any]?
    }
}

// MARK: - DocumentIndexingExtra

extension DocumentIndexer: DocumentIndexingExtra {
    /// Tells how many uncompacted documents have been tracked at the moment of call. It only works if the fragmentation state preservation is maintained by the user, otherwise it returns `nil`.
    ///
    /// The fragmentation state preservation is done by the user's implemented state preserver, which conforms to the protocol `FragmentationStatePreserver`. Its instance is provided at the time of index creating (for an on-disk indexer - both creating and opening) the document indexer. The preserver's only responsibility is to persist the provided piece of information in any way by being able of storing and restoring it at request. Knowing the number of uncompacted documents is useful when you need to determine somehow the time to perform index compaction.
    ///
    /// # Example:
    /// ```
    /// let uncompactedDocumentsAllowance = 50
    /// if indexer.uncompactedDocuments! > uncompactedDocumentsAllowance {
    ///     DispatchQueue.global().async {
    ///         try indexer.compact()
    ///     }
    /// }
    /// ```
    public var uncompactedDocuments: Int? {
        guard let fragmentationStatePreserver = self.fragmentationStatePreserver else { return nil }
        let (prevMaximumDocumentID, prevDocumentCount) = fragmentationStatePreserver.restore()
        return(maximumDocumentID - prevMaximumDocumentID) - (documentCount - prevDocumentCount)
    }

    /// The highest-numbered document ID in an index.
    ///
    /// - See Also: [SKIndexGetMaximumDocumentID](https://developer.apple.com/documentation/coreservices/1444628-skindexgetmaximumdocumentid)
    public var maximumDocumentID: Int { _index.maximumDocumentID }

    /// Compacts the search index to reduce fragmentation and commits changes to backing store.
    ///
    /// - Warning: Compacting can take a considerable amount of time, so it's not recommended to call this method on the main thread.
    /// - See Also: [SKIndexCompact](https://developer.apple.com/documentation/coreservices/1443628-skindexcompact)
    public func compact() throws {
        _writeLock.lock()
        defer { _writeLock.unlock() }

        guard SKIndexCompact(_index.index) else { throw DocumentIndexingExtraError.failedToCompact }

        fragmentationStatePreserver?.preserve((maximumDocumentID, documentCount))
    }
}
