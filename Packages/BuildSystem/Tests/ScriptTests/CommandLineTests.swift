/*
 CommandLineTests.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import BuildSystem
import XCTest

final class CommandLineTests: XCTestCase {

    func testCommandURL() {
        let url = CommandLine.url
        XCTAssertEqual("xctest", url.lastPathComponent, "Should be xctest during testing")
        XCTAssertEqual(url.path, CommandLine.arguments[0])
    }

    func testRunNoExistsCommand() {
        let result = CommandLine.run(["_b9_no_exists_"])
        XCTAssertEqual(127, result.status)
        XCTAssertEqual("env: _b9_no_exists_: No such file or directory", result.output)
    }

    func testRunSuccess() {
        let result = CommandLine.run(["ls"])
        XCTAssertEqual(0, result.status)
        let lineCount = result.output.split(separator: "\n").count
        XCTAssertGreaterThan(lineCount, 4, "Should have many files in build directory")
    }
}
