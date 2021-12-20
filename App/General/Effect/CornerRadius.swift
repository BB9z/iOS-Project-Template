// @MBDependency:4
/**
 UIView 圆角裁切
 */
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            // 不要设置裁切属性，显示圆角不是必须，而且不要裁切时不好撤销设置
            layer.cornerRadius = newValue
        }
    }
}
