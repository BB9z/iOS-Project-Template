/*
 UIImageImageSetTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import XCTest
import UIKit

class UIImageImageSetTests: XCTestCase {
    func testInitWithSetNameAndIdentifier() {
        var assertCalled = 0
        MBAssertSetHandler { message, _, _ in
            assertCalled += 1
            print(message)
        }
        defer {
            MBAssertSetHandler(nil)
        }

        // OK
        XCTAssertNotNil(UIImage(setName: "zs_test", identifier: "1", in: .module))
        XCTAssertEqual(0, assertCalled)

        // Bad set name
        XCTAssertNil(UIImage(setName: "test", identifier: "1", in: .module))
        XCTAssertEqual(1, assertCalled)

        // No existent
        XCTAssertNil(UIImage(setName: "zs_test", identifier: 2, in: .module))
        XCTAssertEqual(2, assertCalled)
    }
}
