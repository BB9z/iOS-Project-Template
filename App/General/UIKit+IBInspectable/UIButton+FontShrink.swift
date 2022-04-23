/*
 UIButton+FontShrink.swift

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

private extension UIButton {

    /**
     文字显示不下时自动减少字体大小
     */
    @IBInspectable var minimumFontScale: CGFloat {
        get {
            titleLabel?.minimumScaleFactor ?? 0
        }
        set {
            guard let label = titleLabel else {
                assert(false)
                return
            }
            label.minimumScaleFactor = newValue
            label.adjustsFontSizeToFitWidth = true
            label.allowsDefaultTighteningForTruncation = true
        }
    }
}
