/*
 AppErrorTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import XCTest

final class AppErrorTests: XCTestCase {

    func testMessageError() {
        let message = "This is an error message"
        let error = AppError.message(message)
        XCTAssertEqual(error.errorDescription, message)
    }

    func testIsCancel() {
        XCTAssertFalse(AppError.isCancel(
            AppError.message("test")
        ))
        XCTAssertTrue(AppError.isCancel(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        ))
        XCTAssertFalse(AppError.isCancel(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        ))
        XCTAssertTrue(AppError.isCancel(
            CancellationError()
        ))
    }
}
