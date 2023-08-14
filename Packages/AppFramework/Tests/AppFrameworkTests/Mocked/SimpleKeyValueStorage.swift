/*
 MockKeyValueStorage.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation
import InterfaceApp

/// Dictionary 作为数据源
class MockKeyValueStorage: IASimpleKeyValueStorage {
    var dict = [String: Any]()

    func data(forKey key: String) throws -> Data? {
        dict[key] as? Data
    }

    func set(data value: Data?, forKey key: String) {
        dict[key] = value
    }

    func string(forKey key: String) -> String? {
        dict[key] as? String
    }

    func set(string value: String?, forKey key: String) {
        dict[key] = value
    }

    func int(forKey key: String) throws -> Int? {
        return dict[key] as? Int
    }

    func set(int value: Int?, forKey key: String) throws {
        dict[key] = value
    }

    func date(forKey key: String) throws -> Date? {
        dict[key] as? Date
    }

    func set(date value: Date?, forKey key: String) {
        dict[key] = value
    }

    func double(forKey key: String) throws -> Double? {
        dict[key] as? Double
    }

    func set(double value: Double?, forKey key: String) {
        dict[key] = value
    }
}
