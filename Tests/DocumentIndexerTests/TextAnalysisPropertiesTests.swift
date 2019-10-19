import XCTest
@testable import DocumentIndexer

final class TextAnalysisPropertiesTests: XCTestCase {
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
        try sut.indexDocument(at: documentURL3, withText: "the foo")
    }

    // MARK: - Tests
    
    func test_minTermLength() throws {
        sut = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch, textAnalysisProperties: TextAnalysisProperties().customized({
            $0.minTermLength = 4
        }))
        
        XCTAssertNotNil(sut)

        try populate()

        var resultHits: [SearchHit] = []
        sut!.search(for: "bar") { hits, hasMore, shouldStop in
            resultHits += hits
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, [])
    }

    func test_substitutions() throws {
        sut = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch, textAnalysisProperties: TextAnalysisProperties().customized({
            $0.substitutions = ["bar": "the"] // replace "the" with "bar"
        }))

        XCTAssertNotNil(sut)

        try populate()

        var resultHits: [SearchHit] = []
        sut!.search(for: "bar") { hits, hasMore, shouldStop in
            resultHits += hits
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, Set([documentURL1, documentURL2, documentURL3]))
    }

    func test_maximumTerms() throws {
        sut = InMemoryDocumentIndexer(autoflushStrategy: .beforeEachSearch, textAnalysisProperties: TextAnalysisProperties().customized({
            $0.maximumTerms = 1
        }))

        XCTAssertNotNil(sut)

        try populate()

        var resultHits: [SearchHit] = []
        sut!.search(for: "bar") { hits, hasMore, shouldStop in
            resultHits += hits
        }

        let resultURLs = Set(resultHits.map { $0.documentURL })
        XCTAssertEqual(resultURLs, [])
    }

    // TODO: Add tests for "proximityIndexing", "termChars", "startTermChars", "endTermChars"
}
