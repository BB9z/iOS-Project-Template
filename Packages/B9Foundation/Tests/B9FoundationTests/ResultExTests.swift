/*
 ResultExTests.swift
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import B9Foundation
import XCTest

class ResultExTests: XCTestCase {
    enum TestError: Error {
        case test
    }

    func testIsSuccessGetter() {
        let result1 = Result<Bool, Error>.success(true)
        XCTAssertTrue(result1.isSuccess)

        let result2 = Result<Bool, Error>.failure(NSError())
        XCTAssertFalse(result2.isSuccess)
    }

    func testErrorGetter() {
        let result1 = Result<Bool, Error>.success(true)
        XCTAssertNil(result1.error)

        let result2 = Result<Bool, Error>.failure(TestError.test)
        XCTAssertNotNil(result2.error)
    }
}
