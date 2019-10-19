import XCTest
@testable import DocumentIndexer

final class DocumentIndexingTests: XCTestCase {
    // MARK: - Test Data

    let documentURL1 = DocumentURL(URL(string: ":1")!)!
    let documentURL2 = DocumentURL(URL(string: ":2")!)!
    let documentURL3 = DocumentURL(URL(string: ":3")!)!

    // MARK: - State

    var sut: DocumentIndexer?

    // MARK: - Life Cycle

    override func tearDown() {
        sut = nil
    }

    // MARK: - Helpers

    func populate() throws {
        guard let sut = sut else {
            XCTFail()
            return
        }
        try sut.indexDocument(at: documentURL1, withText: "foo bar")
        try sut.indexDocument(at: documentURL2, withText: "baz bar")
        try sut.indexDocument(at: documentURL3, withText: "baz foo")
    }

    func assertPositiveResultUsingSequenceSearch(line: UInt = #line) {
        var resultHits: [SearchHit] = []

        for hits in sut!.makeSearch(for: "bar") {
            resultHits += hits
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, Set([documentURL1, documentURL2]), line: line)
    }

    func assertNegativeResultUsingSequenceSearch(line: UInt = #line) {
        var resultHits: [SearchHit] = []

        for hits in sut!.makeSearch(for: "blah") {
            resultHits += hits
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, [], line: line)
    }

    func assertRemoveDocumentUsingSequenceSearch(line: UInt = #line) throws {
        try sut!.removeDocument(at: documentURL1)

        let resultHits = sut!.makeSearch(for: "bar").reduce([], +)

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, Set([documentURL2]), line: line)
    }


    func assertPositiveResultUsingCompletionSearch(line: UInt = #line) {
        var resultHits: [SearchHit] = []
        var resultHasMore: Bool?

        sut!.search(for: "bar") { hits, hasMore, shouldStop in
            resultHits += hits
            resultHasMore = hasMore
        }

        guard resultHasMore != nil && !resultHasMore! else {
            // bail out
            XCTFail(line: line)
            return
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, Set([documentURL1, documentURL2]), line: line)
        XCTAssertFalse(resultHasMore!)
    }

    func assertNegativeResultUsingCompletionSearch(line: UInt = #line) {
        var resultHits: [SearchHit] = []
        var resultHasMore: Bool?

        sut!.search(for: "blah") { hits, hasMore, shouldStop in
            resultHits += hits
            resultHasMore = hasMore
        }

        guard resultHasMore != nil && !resultHasMore! else {
            // bail out
            XCTFail(line: line)
            return
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, [], line: line)
        XCTAssertFalse(resultHasMore!)
    }

    func assertRemoveDocumentUsingCompletionSearch(line: UInt = #line) throws {
        try sut!.removeDocument(at: documentURL1)

        var resultHits: [SearchHit] = []
        var resultHasMore: Bool?

        sut!.search(for: "bar") { hits, hasMore, shouldStop in
            resultHits = hits
            resultHasMore = hasMore
        }

        guard resultHasMore != nil && !resultHasMore! else {
           // bail out
            XCTFail(line: line)
            return
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, Set([documentURL2]), line: line)
        XCTAssertFalse(resultHasMore!)
    }

    // MARK: - Tests

    func test_InMemoryDocumentIndexerUsingSequenceSearch() throws {
        sut = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        try populate()
        assertPositiveResultUsingSequenceSearch()
        assertNegativeResultUsingSequenceSearch()
        try assertRemoveDocumentUsingSequenceSearch()
    }

    func test_InMemoryDocumentIndexerUsingCompletionSearch() throws {
        sut = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        try populate()
        assertPositiveResultUsingCompletionSearch()
        assertNegativeResultUsingCompletionSearch()
        try assertRemoveDocumentUsingCompletionSearch()
    }

    func test_PersistentDocumentIndexerUsingSequenceSearch() throws {
        let fileURL = generateTmpFileURL()
        sut = PersistentDocumentIndexer(creatingAtURL: fileURL, autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        try populate()

        sut = nil

        sut = PersistentDocumentIndexer(openingAtURL: fileURL, autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        assertPositiveResultUsingSequenceSearch()
        assertNegativeResultUsingSequenceSearch()
        try assertRemoveDocumentUsingSequenceSearch()
    }

    func test_PersistentDocumentIndexerUsingCompletionSearch() throws {
        let fileURL = generateTmpFileURL()
        sut = PersistentDocumentIndexer(creatingAtURL: fileURL, autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        try populate()

        sut = nil

        sut = PersistentDocumentIndexer(openingAtURL: fileURL, autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        assertPositiveResultUsingCompletionSearch()
        assertNegativeResultUsingCompletionSearch()
        try assertRemoveDocumentUsingCompletionSearch()
    }

    func test_fileIndexing() throws {
        let textContentFileURL = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Resources").appendingPathComponent("textContent.txt")

        let fileURL = FileDocumentURL(textContentFileURL)!

        sut = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch)
        XCTAssertNotNil(sut)

        try sut!.indexFileDocument(at: fileURL)

        let resultHits = sut!.makeSearch(for: "Lorem").reduce([], +)

        XCTAssertEqual(resultHits.count, 1)
        XCTAssertEqual(resultHits.first!.documentURL.asURL, fileURL.asURL)
    }
}
