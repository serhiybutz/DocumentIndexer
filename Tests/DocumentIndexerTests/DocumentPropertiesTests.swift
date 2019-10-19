import XCTest
@testable import DocumentIndexer

final class DocumentPropertiesTests: XCTestCase {
    let documentURL1 = DocumentURL(URL(string: ":1")!)!
    let documentURL2 = DocumentURL(URL(string: ":2")!)!
    let documentURL3 = DocumentURL(URL(string: ":3")!)!

    let originalDict1: [String: Int] = ["prop1": 123]
    let originalDict2: [String: String] = ["prop2": "blah"]

    var sut: DocumentIndexer?

    override func tearDown() {
        sut = nil
    }

    func test() throws {
        sut = InMemoryDocumentIndexer()!
        XCTAssertNotNil(sut)

        try sut!.indexDocument(at: documentURL1, withText: "foo bar")
        try sut!.indexDocument(at: documentURL2, withText: "baz bar")
        try sut!.indexDocument(at: documentURL3, withText: "baz foo")

        try sut!.flush()

        sut!.setDocumentProperties(at: documentURL1, properties: originalDict1)
        sut!.setDocumentProperties(at: documentURL2, properties: originalDict2)

        let dict1 = sut!.getDocumentProperties(at: documentURL1).flatMap { $0 as? [String: Int] }
        XCTAssertNotNil(dict1)
        XCTAssertEqual(dict1!, originalDict1)

        let dict2 = sut!.getDocumentProperties(at: documentURL2).flatMap { $0 as? [String: String] }
        XCTAssertNotNil(dict2)
        XCTAssertEqual(dict2!, originalDict2)

        let dict3 = sut!.getDocumentProperties(at: documentURL3)
        XCTAssertNil(dict3)
    }
}
