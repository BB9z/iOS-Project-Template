/*
 UILabel+ParagraphStyle.swift

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

private extension UILabel {
    /**
     便于调整纯文本 label 的行高
     */
    @IBInspectable var lineHeightMultiple: CGFloat {
        get {
            let style = attributedText?.attributes(at: 0, effectiveRange: nil)[.paragraphStyle] as? NSParagraphStyle
            return style?.lineHeightMultiple ?? 0
        }
        set {
            guard let aStr = text else {
                NSLog("⚠️ text is nil, set lineHeightMultiple has no effect.")
                return
            }
            let style = NSMutableParagraphStyle()
            style.lineHeightMultiple = newValue
            attributedText = NSAttributedString(string: aStr, attributes: [NSAttributedString.Key.paragraphStyle: style])
        }
    }
}
