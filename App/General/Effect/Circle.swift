/*
 Circle.swift

 Copyright © 2021 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 无论宽高变化，总是居中裁切视图中所有内容为圆形

 一定会触发离屏渲染，只设置 layer cornerRadius 够用时没必要上这个
 */
@IBDesignable
class CircleCropView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        let aMask = mask ?? {
            let newMask = UIView()
            newMask.backgroundColor = .black
            mask = newMask
            return newMask
        }()
        let size = min(bounds.width, bounds.height)
        let rect = CGRectMakeWithCenterAndSize(bounds.center, CGSize(width: size, height: size))
        if aMask.frame != rect {
            aMask.frame = rect
            aMask.layer.cornerRadius = size / 2
        }
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layoutSubviews()
    }
}

/**
 圆环 view
 */
@IBDesignable
class RingView: UIView {
    @IBInspectable var color: UIColor = .red {
        didSet {
            needsUpdateStyle = true
        }
    }
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            needsUpdateStyle = true
        }
    }

    private var shapeLayer: CAShapeLayer!

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
        if shapeLayer == nil {
            shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = nil
            layer.insertSublayer(shapeLayer, at: 0)
        }
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = color.cgColor
        let inset = lineWidth / 2
        shapeLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset)).cgPath
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateLayerStyle()
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerStyle()
    }
}
