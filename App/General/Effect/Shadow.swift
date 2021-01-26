// @MBDependency:3
/**
 背景 view，用于设置阴影
 */
class BackgroundView: UIView {
    @IBInspectable var shadowOffset: CGPoint = CGPoint(x: 0, y: 8)
    @IBInspectable var shadowBlur: CGFloat = 11
    @IBInspectable var shadowSpread: CGFloat = -2
    @IBInspectable var shadowColor: UIColor = UIColor.black.withAlphaComponent(0.3)

    override func awakeFromNib() {
        super.awakeFromNib()
        updateLayerStyle()
    }

    func updateLayerStyle() {
        Shadow(view: self, offset: shadowOffset, blur: shadowBlur, spread: shadowSpread, color: shadowColor, cornerRadius: cornerRadius)
    }

    override var frame: CGRect {
        didSet {
            lastLayerSize = bounds.size
        }
    }
    override var bounds: CGRect {
        didSet {
            lastLayerSize = bounds.size
        }
    }
    var lastLayerSize = CGSize.zero {
        didSet {
            if oldValue == lastLayerSize { return }
            let rect = layer.bounds.inset(by: UIEdgeInsetsMakeWithSameMargin(-shadowSpread))
            layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        }
    }
}

// swiftlint:disable identifier_name
/**
 给一个 view 的 layer 设置阴影样式
 
 生成的阴影无论参数还是效果与 Sketch 应用一致
 */
func Shadow(view: UIView?, offset: CGPoint, blur: CGFloat, spread: CGFloat, color: UIColor, cornerRadius: CGFloat = 0) {
    guard let layer = view?.layer else {
        return
    }
    layer.shadowColor = color.cgColor
    layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
    layer.shadowRadius = blur
    layer.shadowOpacity = 1
    layer.cornerRadius = cornerRadius

    let rect = layer.bounds.inset(by: UIEdgeInsetsMakeWithSameMargin(-spread))
    layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
}
// swiftlint:enable identifier_name
