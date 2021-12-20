/*
 应用级别的便捷方法：NSAttributedString 扩展
 */
extension NSMutableAttributedString {

    /**
     便捷组装方法
     */
    @discardableResult func append(_ text: String, font: UIFont? = nil, color: UIColor? = nil) -> Self {
        var atts = [NSAttributedString.Key: Any]()
        if let font = font {
            atts[.font] = font
        }
        if let color = color {
            atts[.foregroundColor] = color
        }
        append(NSAttributedString(string: text, attributes: atts))
        return self
    }

    /**
     便捷组装方法
     */
    @discardableResult func append(_ text: String, _ attributes: [NSAttributedString.Key: Any]) -> Self {
        append(NSAttributedString(string: text, attributes: attributes))
        return self
    }
}
