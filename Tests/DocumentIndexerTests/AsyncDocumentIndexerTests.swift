import XCTest
@testable import DocumentIndexer

final class AsyncDocumentIndexingTests: XCTestCase {
    // MARK: - State

    let testData = TestData()

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

        try testData.corpus.forEach {
            try sut.indexDocument(at: $0.0, withText: $0.1)
        }
    }

    func assertSearchCompletion(line: UInt = #line) {
        let searchDone = expectation(description: "search done")
        DispatchQueue.global().async {
            self.sut!.search(for: self.testData.randomQuery()) { hits, hasMore, shouldStop in
                shouldStop = true
                searchDone.fulfill()
            }
        }
        wait(for: [searchDone], timeout: 3)
    }

    // MARK: - Tests

    func test_InMemoryDocumentIndexer() throws {
        sut = InMemoryDocumentIndexer(autoflushStrategy: .none)
        XCTAssertNotNil(sut)

        try populate()
        try sut!.flush()

        assertSearchCompletion()
    }

    func test_PersistentDocumentIndexer() throws {
        let fileURL = generateTmpFileURL()
        sut = PersistentDocumentIndexer(creatingAtURL: fileURL, autoflushStrategy: .none)
        XCTAssertNotNil(sut)

        try populate()
        try sut!.flush()

        sut = nil

        sut = PersistentDocumentIndexer(openingAtURL: fileURL, autoflushStrategy: .none)
        XCTAssertNotNil(sut)

        assertSearchCompletion()
    }
}
