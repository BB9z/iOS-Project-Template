/*
 MBAdaptiveStackView

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 指定一个宽度，当其父 view 宽度小于该值时采用竖版布局，否则用水平布局
 */
class MBAdaptiveStackView: UIStackView {

    /// 布局切换宽度，指的是父 view 宽度
    @IBInspectable var mediaWidth: CGFloat = 0

    /// 采用横版布局时调整 spacing 的量，与 compactSpacing 同时大于等于 0 起效
    @IBInspectable var regularSpacing: CGFloat = -1
    /// 采用竖版布局时调整 spacing 的量，与 regularSpacing 同时大于等于 0 起效
    @IBInspectable var compactSpacing: CGFloat = -1

    override var bounds: CGRect {
        didSet {
            updateLayoutIfNeeded()
        }
    }

    private func updateLayoutIfNeeded() {
        // 宽度不能用自己的，因为有可能切为竖版后宽度不会自动还原
        guard mediaWidth > 0,
              let width = superview?.bounds.width else { return }
        let isCompact = width < mediaWidth
        let axisWillBe: NSLayoutConstraint.Axis = isCompact ? .vertical : .horizontal
        if axis != axisWillBe {
            axis = axisWillBe
            if compactSpacing >= 0, regularSpacing >= 0 {
                spacing = isCompact ? compactSpacing : regularSpacing
            }
        }
    }
}
