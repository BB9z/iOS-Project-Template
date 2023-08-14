/*
 IASimpleKeyValueStorageTests.swift
 InterfaceApp

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import InterfaceApp
import XCTest


class IASimpleKeyValueStorageTests: XCTestCase {

    let backend = UserDefaults(suiteName: "test")!
    lazy var storage: IASimpleKeyValueStorage = backend

    override func tearDown() {
        super.tearDown()
        backend.removePersistentDomain(forName: "test")
    }

    func testCodable() throws {
        struct TestModel: Codable {
            let name: String
        }

        let key = #function
        let value = TestModel(name: "John")

        try storage.set(codable: value, forKey: key)
        guard let retrievedValue: TestModel = try storage.codable(forKey: key) else {
            XCTFail("Failed to retrieve value")
            return
        }

        XCTAssertEqual(retrievedValue.name, value.name)

        guard let raw = try storage.data(forKey: key),
              let string = String(data: raw, encoding: .utf8) else {
            XCTFail("Raw JSON should be stored")
            return
        }
        XCTAssertEqual(string, #"{"name":"John"}"#)

        let nilValue: TestModel? = nil
        try storage.set(codable: nilValue, forKey: key)

        XCTAssertNil(try storage.codable(forKey: key) as TestModel?)
        XCTAssertNil(try storage.data(forKey: key))
    }

    func testIntMethods() throws {
        let key = #function
        let value = 42

        try storage.set(int: value, forKey: key)
        let retrievedValue = try storage.int(forKey: key)

        XCTAssertEqual(retrievedValue, value)

        try storage.set(int: nil, forKey: key)
        XCTAssertNil(try storage.int(forKey: key))
    }

    func testDoubleMethods() throws {
        let key = #function
        let value = 42.0

        try storage.set(double: value, forKey: key)
        let retrievedValue = try storage.double(forKey: key)

        XCTAssertEqual(retrievedValue, value)

        try storage.set(double: nil, forKey: key)
        XCTAssertNil(try storage.double(forKey: key))
    }

    func testStringMethods() throws {
        let key = #function
        let value = "testValue"

        try storage.set(string: value, forKey: key)
        let retrievedValue = try storage.string(forKey: key)

        XCTAssertEqual(retrievedValue, value)

        try storage.set(string: nil, forKey: key)
        XCTAssertNil(try storage.string(forKey: key))
    }

    func testDateMethods() throws {
        let key = #function
        let value = Date()

        try storage.set(date: value, forKey: key)
        let retrievedValue = try storage.date(forKey: key)

        XCTAssertEqual(retrievedValue, value)

        try storage.set(date: nil, forKey: key)
        XCTAssertNil(try storage.date(forKey: key))
    }
}
