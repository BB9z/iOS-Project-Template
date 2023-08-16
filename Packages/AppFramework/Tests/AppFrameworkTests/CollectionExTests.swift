/*
 CollectionExTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import XCTest

class CollectionExTests: XCTestCase {
    
    func testSequenceUniqued() {
        XCTAssertEqual(
            [1, 2, 3, 2, 4, 5, 1].uniqued(),
            [1, 2, 3, 4, 5]
        )

        XCTAssertEqual(
            ["1"].uniqued(),
            ["1"]
        )

        let emptyArray = [Int]()
        XCTAssertEqual(emptyArray.uniqued(), [])
    }
}
