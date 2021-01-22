/*
 服务器日期转换
 */

extension Date {
    /// 从服务器日期创建
    init?(serverString: String?) {
        guard let str = serverString,
              let date = DateFormatter.server.date(from: str) else { return nil }
        self = date
    }
}

extension DateFormatter {
    /// 服务器日期格式
    static let server: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .server
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    /// 服务器日期格式
    static let server = JSONDecoder.DateDecodingStrategy.iso8601
}

extension JSONEncoder.DateEncodingStrategy {
    /// 服务器日期格式
    static let server = JSONEncoder.DateEncodingStrategy.iso8601
}

extension TimeZone {
    // @MBDependency:2
    /// 服务器时区
    static var server = TimeZone(identifier: "Asia/Shanghai")!
}
