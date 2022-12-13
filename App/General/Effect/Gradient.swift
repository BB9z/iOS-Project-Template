/*
 Gradient.swift

 Copyright © 2021 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 线性渐变 view
 Linear gradient view
 */
@IBDesignable
class GradientView: UIView {
    @IBInspectable var startColor: UIColor? {
        didSet { needsUpdateStyle = true }
    }
    @IBInspectable var endColor: UIColor? {
        didSet { needsUpdateStyle = true }
    }
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet { needsUpdateStyle = true }
    }
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet { needsUpdateStyle = true }
    }

    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    var gradientLayer: CAGradientLayer {
        MBSwift.cast(layer, as: CAGradientLayer.self)
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
        if let start = startColor, let end = endColor {
            gradientLayer.colors = [start.cgColor, end.cgColor]
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateLayerStyle()
    }
}
