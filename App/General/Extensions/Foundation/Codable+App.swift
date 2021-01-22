/*
 应用级别的便捷方法：Codable 相关扩展
 */
extension JSONDecoder {
    /// 从服务器接收到的格式
    static let server: JSONDecoder = {
        let coder = JSONDecoder()
        coder.dateDecodingStrategy = .server
        return coder
    }()

    /// 从字符串 JSON 解码
    func decode<T>(_ type: T.Type, from string: String) throws -> T where T: Decodable {
        let data = string.data(using: .utf8)!
        return try decode(type, from: data)
    }
}

extension JSONEncoder {
    /// 编码为发送给服务器的格式
    static let server: JSONEncoder = {
        let coder = JSONEncoder()
        coder.dateEncodingStrategy = .server
        coder.outputFormatting = []
        return coder
    }()

    /// 本地调试显示用
    static let display: JSONEncoder = {
        let coder = JSONEncoder()
        coder.dateEncodingStrategy = .iso8601
        coder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return coder
    }()

    /// 编码为 JSON 字符串
    func encodeToString<T>(_ value: T) throws -> String where T: Encodable {
        let data = try encode(value)
        return String(data: data, encoding: .utf8)!
    }
}

extension Encodable {
    /// 转为 JSON 对象
    func asJSONObject(encoder: JSONEncoder = JSONEncoder()) throws -> Any {
        let data = try encoder.encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}

/// Encodable 声明 CustomDebugStringConvertible 则实现自动生成
extension Encodable where Self: CustomDebugStringConvertible {
    var debugDescription: String {
        "[\(Self.self)] " + String(data: (try? JSONEncoder.display.encode(self))!, encoding: .utf8)!
    }
}
