/*
 应用级别的便捷方法
 */
extension DateFormatter {

    /// MBDateDayIdentifier 专用格式化
    static let dayIdentifier: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .server
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    /// 本地化的 X年X月X日
    static let localizedYMD: DateFormatter = {
        DateFormatter.currentLocale(fromTemplate: "yMMMMd")
    }()

    /// 本地化的 X月X日
    static let localizedMD: DateFormatter = {
        DateFormatter.currentLocale(fromTemplate: "MMMMd")
    }()

    /// 本地化的周几
    static let localizedShortWeek: DateFormatter = {
        DateFormatter.currentLocale(fromTemplate: "EEE")
    }()
}
