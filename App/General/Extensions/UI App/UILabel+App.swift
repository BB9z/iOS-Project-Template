/*
 应用级别的便捷方法
 */
extension UILabel {

    /**
     设置文字，如果文字非空，附加可选前缀并显示给定 view；否则隐藏指定 view
     */
    func setText(_ text: String?, prefix: String? = nil, suffix: String? = nil, emptyHide view: UIView? = nil) {
        if let value = text?.trimmed() {
            self.text = (prefix ?? "") + value + (suffix ?? "")
            view?.isHidden = false
        } else {
            view?.isHidden = true
        }
    }

    /**
     设置文字，如果文字非空，附加可选前缀并显示自己；否则隐藏自己
     */
    func setTextOrHide(_ text: String?, prefix: String? = nil, suffix: String? = nil) {
        setText(text, prefix: prefix, suffix: suffix, emptyHide: self)
    }

    /**
     当条件满足时设置文字，并控制给定 view 的显隐
     */
    func setText(_ text: @autoclosure () -> String?, if condition: Bool, orHide view: UIView?) {
        if condition {
            view?.isHidden = false
            self.text = text()
        } else {
            view?.isHidden = true
        }
    }

    /**
     通常用于设置数字+单元，并设置单元部分相对正常文本的大小
     */
    func setValue(_ valueString: String, unit: String, unitFontScale scale: CGFloat) {
        assert(0...1 ~= scale)
        let atts = NSMutableAttributedString(string: valueString)
        let unitFont = font.withSize(font.pointSize * scale)
        atts.append(NSAttributedString(string: unit, attributes: [.font: unitFont]))
        attributedText = atts
    }
}
