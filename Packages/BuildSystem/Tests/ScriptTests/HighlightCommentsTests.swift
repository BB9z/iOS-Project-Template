/*
 HighlightCommentsTests.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import BuildSystem
import XCTest

final class HighlightCommentsTests: XCTestCase {
    let core = HighlightComments(files: [])

    func testMatchEmptyString() {
        let result = core.findMatch(in: "", file: "")
        XCTAssertTrue(result.isEmpty)
    }

    func testMatchSingleLine() {
        let result = core.findMatch(in: "// Todo:  abc", file: "")
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result[0].line, 1)
        XCTAssertEqual(result[0].col, 1)
        XCTAssertEqual(result[0].text, "TODO: abc")
    }

    func testMatchContent() {
        let content = """
            1  line
            2 // TODO: dddd

            🥶 // todo: 🫥
             // FIXME: 0002

            // some: // todo: // todo: zz
            //fixme s1
            // fixme s2
            //  fixme: s3
            end
            """

        let result = core.findMatch(in: content, file: "")
        print(result)

        XCTAssertEqual(result, [
            .init(file: "", line: 2, col: 3, text: "TODO: dddd"),
            .init(file: "", line: 4, col: 3, text: "TODO: 🫥"),
            .init(file: "", line: 5, col: 2, text: "FIXME: 0002"),
            .init(file: "", line: 7, col: 10, text: "TODO: // todo: zz"),
            .init(file: "", line: 10, col: 1, text: "FIXME: s3"),
        ])
    }
}
