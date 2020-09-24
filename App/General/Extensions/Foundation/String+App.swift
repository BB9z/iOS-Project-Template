/*
 应用级别的便捷方法：String 扩展
 */

extension StringProtocol {
    // @MBDependency:4
    /// 应用级别行为，输入预处理
    func trimmed() -> String? {
        let str = trimmingCharacters(in: .whitespaces)
        return str.isNotEmpty ? str : nil
    }

    // @MBDependency:3
    /// 检查是否符合给定正则表达式
    func matches(regularExpression pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }

    // @MBDependency:2
    /// email 格式检查
    var isValidEmail: Bool {
        matches(regularExpression: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
    }

    // @MBDependency:3
    /// 是否是大陆手机手机号
    var isValidPhoneNumber: Bool {
        matches(regularExpression: "^1\\d{10}$")
    }
}

extension String {
    // @MBDependency:3
    /// 用 separator 连接两个 string
    static func join(_ str1: String?, _ str2: String?, separator: String = "") -> String {
        if let str1 = str1, let str2 = str2 {
            return String(format: "%@%@%@", str1, separator, str2)
        }
        if let str = str1 { return str }
        if let str = str2 { return str }
        return ""
    }

    // @MBDependency:2
    /// 手机号/电话号打码
    /// 支持任意长度
    func phoneMasked(_ mask: Character = Character("*")) -> String {
        guard !isEmpty else { return self }
        // 用系数算可以支持任意长度的输入
        // 系数是可以计算的，但这里写死的可读性好
        let length = Double(count)
        let maskCount = Int((length / 11.0 * 4.0).rounded())
        guard maskCount > 0 else { return self }
        let maskString = String(repeating: mask, count: maskCount)
        let rangeStart = index(startIndex, offsetBy: Int((length * 0.29).rounded()))
        let rangeEnd = index(rangeStart, offsetBy: maskCount - 1)
        var str = self
        str.replaceSubrange(rangeStart...rangeEnd, with: maskString)
        return str
    }
}

/*
 废弃的实现

 硬换行数 https://github.com/BB9z/iOS-Project-Template/blob/4.1/App/General/Extensions/Foundation/NSString%2BApp.m#L19
 版本比较 https://github.com/BB9z/iOS-Project-Template/blob/4.1/App/General/Extensions/Foundation/NSString%2BApp.m#L27
 */
