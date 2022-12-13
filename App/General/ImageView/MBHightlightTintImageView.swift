/*
 MBHightlightTintImageView.swift

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 图片主题色根据高亮状态变化的 image view

 注意：iOS 11-12 第一屏的图片可能还需要用 UIImageView+MBRenderingMode 修正一下
 */
class MBHighlightTintImageView: UIImageView {

    private var normalTintColor: UIColor?
    @IBInspectable var highlightTintColor: UIColor? {
        didSet {
            if isHighlighted, let color = highlightTintColor {
                tintColor = color
            }
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        if isHighlighted {
            return
        }
        normalTintColor = tintColor
    }

    override var isHighlighted: Bool {
        didSet {
            guard let color = highlightTintColor else {
                return
            }
            if isHighlighted {
                tintColor = color
            } else {
                tintColor = normalTintColor
            }
        }
    }
}
