import XCTest
@testable import DocumentIndexer

final class DocumentURLTests: XCTestCase {
    var sut: DocumentURL?

    override func tearDown() {
        sut = nil
    }

    func test_construction1() {
        sut = DocumentURL(URL(string: "foo:root/foo/0")!)
        XCTAssertNotNil(sut)

        XCTAssertEqual(sut!.name, "0")
        XCTAssertEqual(sut!.schemeName, "foo")
        XCTAssertEqual(sut!.parent, DocumentURL(URL(string: "foo:root/foo")!))
    }

    func test_construction2() {
        let documentURL = DocumentURL(URL(string: ":root/foo/0")!)!
        sut = DocumentURL(documentURL.wrappee)
        XCTAssertEqual(sut, documentURL)
    }

    func test_construction3() {
        let parentDocumentURL = DocumentURL(URL(string: ":root")!)!
        sut = DocumentURL(scheme: "foo", parent: parentDocumentURL, name: "11")
        XCTAssertNotNil(sut)

        XCTAssertEqual(sut!, DocumentURL(URL(string: "foo:root/11")!))
    }

    func test_asURL() {
        let url = URL(string: "://root/foo/0")!
        sut = DocumentURL(url)
        XCTAssertNotNil(sut)
        
        XCTAssertEqual(sut!.asURL, url)
    }

    func test_fileDocumentURLPositive() {
        let fileURL = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Resources").appendingPathComponent("textContent.txt")
        XCTAssertNotNil(FileDocumentURL(fileURL))
    }

    func test_fileDocumentURLNegative() {
        let nonFileURL = URL(string: ":1")!
        XCTAssertNil(FileDocumentURL(nonFileURL))
    }
}
