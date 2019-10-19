import XCTest
@testable import DocumentIndexer

final class DocumentIndexingCompactionTests: XCTestCase {
    // MARK: - State

    var sut: DocumentIndexer?

    // MARK: - Life Cycle

    override func tearDown() {
        sut = nil
    }

    // MARK: - Helpers

    func populate(testData: TestData) throws {
        guard let sut = sut else {
            XCTFail()
            return            
        }

        try testData.corpus.forEach {
            try sut.indexDocument(at: $0.0, withText: $0.1)
        }
    }

    // MARK: - Tests

    struct IndexerFragmentationStatePreserver: FragmentationStatePreserver {
        func preserve(_ state: FragmentationState) {
            UserDefaults.standard.setValue(state.maximumDocumentID, forKey: "maximumDocumentID")
            UserDefaults.standard.setValue(state.documentCount, forKey: "documentCount")
        }
        func restore() -> FragmentationState {
            guard let maximumDocumentID = UserDefaults.standard.object(forKey: "maximumDocumentID") as? Int,
                  let documentCount = UserDefaults.standard.object(forKey: "documentCount") as? Int
            else { preconditionFailure() }

            return (maximumDocumentID: maximumDocumentID,
                    documentCount: documentCount)
        }
    }

    func test_PersistentDocumentIndexer() throws {
        let indexerFragmentationStatePreserver = IndexerFragmentationStatePreserver()

        // 1. Create file index

        let fileURL = generateTmpFileURL()
        sut = PersistentDocumentIndexer(creatingAtURL: fileURL, autoflushStrategy: .none, fragmentationStatePreserver: indexerFragmentationStatePreserver)
        XCTAssertNotNil(sut)

        let ud1 = sut!.uncompactedDocuments!
        let size1 = fileSize(fileURL.path)!

        XCTAssertEqual(ud1, 0)
        XCTAssert(size1 > 0)

        // 2. Populate file index with textual context

        let testData1 = TestData(documentURLPrefix: ":root1")

        try populate(testData: testData1)
        try sut!.flush()

        let ud2 = sut!.uncompactedDocuments!
        let size2 = fileSize(fileURL.path)!

        XCTAssertEqual(ud2, 0)
        XCTAssertGreaterThan(size2, size1) // size increased

        // 3. Close file index

        sut = nil

        // 4. Open file index again

        sut = PersistentDocumentIndexer(openingAtURL: fileURL, autoflushStrategy: .none, fragmentationStatePreserver: indexerFragmentationStatePreserver)
        XCTAssertNotNil(sut)

        // 5. Remove some indexed documents from file index

        try testData1.corpus.prefix(upTo: testData1.corpus.count / 2).forEach {
            try sut!.removeDocument(at: $0.0)
        }

        let ud5 = sut!.uncompactedDocuments!
        let size5 = fileSize(fileURL.path)!
        XCTAssertGreaterThan(ud5, 0) // indicates a need for compacting
        XCTAssertEqual(size5, size2) // index is bloated

        // 6. Perform compacting of file index

        try sut!.compact()
        try sut!.flush()

        let ud6 = sut!.uncompactedDocuments!
        let size6 = fileSize(fileURL.path)!
        XCTAssertEqual(ud6, 0) // compacting not needed
        XCTAssert(size6 < size5) // size decreased

        // 7. Populate file index with more textual context

        let testData2 = TestData(documentURLPrefix: ":root2")

        try populate(testData: testData2)
        try sut!.flush()

        let ud7 = sut!.uncompactedDocuments!
        let size7 = fileSize(fileURL.path)!

        XCTAssertEqual(ud7, 0)
        XCTAssertGreaterThan(size7, size6) // size increased

        // 8. Remove some more indexed documents from file index

        try testData2.corpus.prefix(upTo: testData2.corpus.count / 2).forEach {
            try sut!.removeDocument(at: $0.0)
        }

        let ud8 = sut!.uncompactedDocuments!
        let size8 = fileSize(fileURL.path)!
        XCTAssertGreaterThan(ud8, 0) // indicates a need for compacting
        XCTAssertEqual(size8, size7) // index is bloated

        // 9. Perform compacting of file index again

        try sut!.compact()
        try sut!.flush()

        let ud9 = sut!.uncompactedDocuments!
        let size9 = fileSize(fileURL.path)!
        XCTAssertEqual(ud9, 0) // compacting not needed
        XCTAssert(size9 < size8) // size decreased
    }
}
