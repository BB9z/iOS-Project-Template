/*
 系统组件向前兼容声明
 */

extension UIActivityIndicatorView.Style {
    init(medium fallbackToGray: Bool) {
        if #available(iOS 13.0, *) {
            self = .medium
        } else {
            self = fallbackToGray ? .gray : .white
        }
    }

    static var big: Self {
        if #available(iOS 13.0, *) {
            return .large
        } else {
            return .whiteLarge
        }
    }
}
