/*
 应用级别的便捷方法
 */
extension Double {

    // @MBDependency:3
    /**
     xx.xx 价格的格式
     
     - Parameter addPadding: 是否补足小数点后两位，否则抹零
     */
    func priceString(addPadding: Bool = false) -> String {
        if addPadding {
            return String(format: "%.2f", self)
        }
        let price100 = Int64((self * 100).rounded())
        if price100.isMultiple(of: 100) {
            return String(format: "%.0f", self)
        } else if price100.isMultiple(of: 10) {
            return String(format: "%.1f", self)
        } else {
            return String(format: "%.2f", self)
        }
    }
}

extension NumberFormatter {

    // @MBDependency:1
    /// 带千位分隔符的数字
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}

extension LengthFormatter {
    // @MBDependency:1
    /// 距离格式化，两位有效数字
    static var distance: LengthFormatter {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        let numberfm = NumberFormatter()
        numberfm.minimumSignificantDigits = 0
        numberfm.maximumSignificantDigits = 2
        formatter.numberFormatter = numberfm
        return formatter
    }
}
