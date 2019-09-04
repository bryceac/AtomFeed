import XCTest
@testable import AtomFeed

final class AtomFeedTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AtomFeed().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
