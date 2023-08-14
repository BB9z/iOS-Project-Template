/*
 Helper.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import XCTest

extension XCTestCase {
    func noBlockingWait(_ time: TimeInterval = 0.1) {
        let waiter = XCTWaiter()
        let exp = XCTestExpectation()  // Don't use self
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            exp.fulfill()
        }
        waiter.wait(for: [exp], timeout: 10)  // No more than 10s
        print("Test> noBlockingWait end.")
    }
}

extension XCTestExpectation {
    /// Return the expectation that is not intended to happen.
    @discardableResult
    func inverted() -> Self {
        isInverted = true
        return self
    }
}
