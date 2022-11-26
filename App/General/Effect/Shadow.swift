/*
 Shadow.swift

 Copyright © 2018, 2020-2021 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

// @MBDependency:3
/**
 阴影 view
 */
@IBDesignable
class ShadowView: UIView {
    @IBInspectable var shadowOffset: CGPoint = CGPoint(x: 0, y: 8) {
        didSet {
            needsUpdateStyle = true
        }
    }
    @IBInspectable var shadowBlur: CGFloat = 10 {
        didSet {
            needsUpdateStyle = true
        }
    }
    @IBInspectable var shadowSpread: CGFloat = 0 {
        didSet {
            needsUpdateStyle = true
        }
    }
    /// nil 禁用阴影
    @IBInspectable var shadowColor: UIColor? = UIColor.black.withAlphaComponent(0.3) {
        didSet {
            needsUpdateStyle = true
        }
    }

    private var needsUpdateStyle = false {
        didSet {
            guard needsUpdateStyle, !oldValue else { return }
            DispatchQueue.main.async { [self] in
                if needsUpdateStyle { updateLayerStyle() }
            }
        }
    }

    private func updateLayerStyle() {
        needsUpdateStyle = false
        if let color = shadowColor {
            Shadow(view: self, offset: shadowOffset, blur: shadowBlur, spread: shadowSpread, color: color, cornerRadius: cornerRadius)
        } else {
            layer.shadowColor = nil
            layer.shadowPath = nil
            layer.shadowOpacity = 0
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateLayerStyle()
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        lastLayerSize = layer.bounds.size
        if shadowColor != nil, layer.shadowOpacity == 0 {
            updateLayerStyle()
        }
    }

    private var lastLayerSize = CGSize.zero {
        didSet {
            if oldValue == lastLayerSize { return }
            guard shadowColor != nil else { return }
            updateShadowPathWithAnimationFixes(bounds: layer.bounds)
        }
    }

    // 需要对阴影动画做特别处理才能和 view 尺寸变化的动画同步
    private func updateShadowPathWithAnimationFixes(bounds: CGRect) {
        let rect = bounds.insetBy(dx: shadowSpread, dy: shadowSpread)
        let newShadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        if let resizeAnimation = layer.animation(forKey: "bounds.size") {
            let key = #keyPath(CALayer.shadowPath)
            let shadowAnimation = CABasicAnimation(keyPath: key)
            shadowAnimation.duration = resizeAnimation.duration
            shadowAnimation.timingFunction = resizeAnimation.timingFunction
            shadowAnimation.fromValue = layer.shadowPath
            shadowAnimation.toValue = newShadowPath
            layer.add(shadowAnimation, forKey: key)
        }
        layer.shadowPath = newShadowPath
    }
}

/**
 给一个 view 的 layer 设置阴影样式
 
 生成的阴影无论参数还是效果与 Sketch 应用一致
 */
func Shadow(view: UIView?, offset: CGPoint, blur: CGFloat, spread: CGFloat, color: UIColor, cornerRadius: CGFloat = 0) {  // swiftlint:disable:this identifier_name
    guard let layer = view?.layer else {
        return
    }
    layer.shadowColor = color.cgColor
    layer.shadowOffset = CGSize(width: offset.x, height: offset.y)
    layer.shadowRadius = blur
    layer.shadowOpacity = 1
    layer.cornerRadius = cornerRadius

    let rect = layer.bounds.insetBy(dx: spread, dy: spread)
    layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
}
