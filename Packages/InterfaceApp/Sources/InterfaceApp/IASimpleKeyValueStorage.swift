/*!
 IASimpleKeyValueStorage
 InterfaceApp

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 应用界面：简单 KV 存储

 例如 UserDefaults、keychain 或者自己写的文件存储

 set 方法传空意味着清空该字段。不用 `set(_:forKey:)` 这种签名，不想补全时会把方法合并
 */
public protocol IASimpleKeyValueStorage {

    func data(forKey key: String) throws -> Data?

    func set(data: Data?, forKey key: String) throws

    func string(forKey key: String) throws -> String?

    func set(string: String?, forKey key: String) throws

    func int(forKey key: String) throws -> Int?

    func set(int: Int?, forKey key: String) throws

    func double(forKey key: String) throws -> Double?

    func set(double: Double?, forKey key: String) throws

    func date(forKey key: String) throws -> Date?

    func set(date: Date?, forKey key: String) throws
}

/// 添加默认 codable 支持
public extension IASimpleKeyValueStorage {
    func codable<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = try data(forKey: key) else {
            return nil
        }
        let model = try JSONDecoder().decode(T.self, from: data)
        return model
    }

    func set<T: Encodable>(codable: T?, forKey key: String) throws {
        if let value = codable {
            let data = try JSONEncoder().encode(value)
            try set(data: data, forKey: key)
        } else {
            try set(data: nil, forKey: key)
        }
    }
}

/// UserDefaults 默认实现
extension UserDefaults: IASimpleKeyValueStorage {
    public func set(data: Data?, forKey key: String) throws {
        set(data, forKey: key)
    }

    public func set(string: String?, forKey key: String) throws {
        set(string, forKey: key)
    }

    public func int(forKey key: String) throws -> Int? {
        object(forKey: key) as? Int
    }

    public func set(int: Int?, forKey key: String) throws {
        set(int, forKey: key)
    }

    public func double(forKey key: String) throws -> Double? {
        object(forKey: key) as? Double
    }

    public func set(double: Double?, forKey key: String) throws {
        set(double, forKey: key)
    }

    public func date(forKey key: String) throws -> Date? {
        object(forKey: key) as? Date
    }

    public func set(date: Date?, forKey key: String) throws {
        set(date, forKey: key)
    }
}
