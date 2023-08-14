/*
 ObjectPoolTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import XCTest

private class CustomObject {
    static var creationCount = 0

    init() {
        Self.creationCount += 1
    }
}

class ObjectPoolTests: XCTestCase {
    func testObjectPool() {
        let pool = ObjectPool<String, CustomObject>()

        // Test object creation
        let obj1 = pool.object(key: "key1", creator: CustomObject())
        let obj2 = pool.object(key: "key2", creator: CustomObject())
        XCTAssert(obj1 !== obj2)
        XCTAssertEqual(2, CustomObject.creationCount)

        // Test object uniqueness
        let obj3 = pool.object(key: "key1", creator: CustomObject())
        XCTAssert(obj1 === obj3)
        XCTAssertEqual(2, CustomObject.creationCount)

        // Test subscript
        pool["key1"] = CustomObject()
        XCTAssert(obj1 !== pool["key1"])
        XCTAssertEqual(3, CustomObject.creationCount)

        // Test removeAll
        pool.removeAll()
        XCTAssertNil(pool["key1"])
        XCTAssertNil(pool["key2"])
    }
}
