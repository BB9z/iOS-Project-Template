/*
 ResizeObservableView

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 尺寸变更时通知给定 delegate 或父 view
 */
class ResizeObservableView: UIView {
    /// 为空会尝试通知父 view
    @IBOutlet weak var delegate: ResizeObserver?

    override var bounds: CGRect {
        willSet {
            if bounds.size != newValue.size {
                noticeWillResize(toSize: newValue.size)
            }
        }
        didSet {
            if oldValue.size != bounds.size {
                noticeDidResized(oldSize: oldValue.size)
            }
        }
    }

    private func noticeWillResize(toSize: CGSize) {
        guard let observer = delegate ?? superview as? ResizeObserver else {
            return
        }
        observer.willResize?(view: self, toSize: toSize)
    }
    private func noticeDidResized(oldSize: CGSize) {
        guard let observer = delegate ?? superview as? ResizeObserver else {
            return
        }
        observer.didResized?(view: self, oldSize: oldSize)
    }
}

/// 关联 view 尺寸变更响应
@objc protocol ResizeObserver {
    /// 尺寸即将变化
    @objc optional func willResize(view: UIView, toSize: CGSize)
    /// 尺寸已变化
    @objc optional func didResized(view: UIView, oldSize: CGSize)
}
