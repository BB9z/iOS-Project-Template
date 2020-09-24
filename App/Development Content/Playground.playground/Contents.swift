
import UIKit

/*:

 我一般用 playground 辅助实现，验证简短的方法

 另见：[技术选型: 有助更快开发的工具](https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#tools-implement-faster)
 */

extension String {
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
        assert(str.count == self.count)
        return str
    }
}

"1".phoneMasked()
"12".phoneMasked()
"123".phoneMasked()
"1234".phoneMasked()
"12345".phoneMasked()
"123456".phoneMasked()
"1234567".phoneMasked()
"12345678".phoneMasked()
"123456789".phoneMasked()
"1234567890".phoneMasked()
"12345678901".phoneMasked()
"123456789012".phoneMasked()
