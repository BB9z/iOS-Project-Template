/*
 GradientProgressViews.swift

 Copyright © 2020-2021 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 渐变的条形进度条

 🔰 UI 控件不完善，按需修改
 */
class GradientBarProgressView: UIView {

    /// 进度条完成部分的渐变颜色，设置单个为纯色，设置多个为渐变色
    var progressColors: [UIColor] = [#colorLiteral(red: 0.9450980392, green: 0.5568627451, blue: 0.05490196078, alpha: 1), #colorLiteral(red: 1, green: 0.8039215686, blue: 0.007843137255, alpha: 1)]

    /// 进度条完成部分的圆角半径
    @IBInspectable var progressCornerRadius: CGFloat = 0 {
        didSet {
            maskLayer.cornerRadius = progressCornerRadius
        }
    }

    /// 进度完成部分的内间距
    var progressEdgeInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
        }
    }

    /// 当前进度
    @IBInspectable var progress: Float {
        get {
            privateProgress
        }
        set {
            setProgress(newValue, animated: false)
        }
    }

    /// 渐变Layer
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.colors = progressColors.map { $0.cgColor }
        return layer
    }()

    /// 动画持续时间
    var animationDuration: TimeInterval = 0.3

    /// 动画时间函数
    var timingFunction = CAMediaTimingFunction(name: .default)

    /// 进度更新动画过程中的回调，在这里可以拿到当前进度及进度条的frame
    var progressUpdating: ((Float, CGRect) -> Void)?


    private var privateProgress: Float = 0
    private let maskLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }()

    // MARK: - Lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds.inset(by: progressEdgeInsets)
        var bounds = gradientLayer.bounds
        bounds.size.width *= CGFloat(progress)
        maskLayer.frame = bounds
        if progressCornerRadius == 0 {
            maskLayer.cornerRadius = bounds.height / 2
            maskLayer.masksToBounds = true
        }
        layer.cornerRadius = bounds.height / 2
    }

    // MARK: - Private
    private func commonInit() {
        gradientLayer.mask = maskLayer
        layer.insertSublayer(gradientLayer, at: 0)
        layer.masksToBounds = true
    }

    @objc private func displayLinkAction() {
        guard let frame = maskLayer.presentation()?.frame else { return }
        let progress = frame.size.width / gradientLayer.frame.size.width
        progressUpdating?(Float(progress), frame)
    }

    // MARK: - Public
    func setProgress(_ progress: Float, animated: Bool) {
        let validProgress = min(1.0, max(0.0, progress))
        if privateProgress == validProgress {
            return
        }
        privateProgress = validProgress

        // 动画时长
        var duration = animated ? animationDuration : 0
        if duration < 0 {
            duration = 0
        }

        var displayLink: CADisplayLink?
        if duration > 0 {
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
            displayLink?.add(to: .main, forMode: .common)
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        CATransaction.setCompletionBlock {
            displayLink?.invalidate()
            if duration == 0 {
                // 更新回调
                self.progressUpdating?(validProgress, self.maskLayer.frame)
            } else {
                if nil != self.maskLayer.presentation() {
                    self.displayLinkAction()
                } else {
                    self.progressUpdating?(validProgress, self.maskLayer.frame)
                }
            }
        }

        var bounds = self.gradientLayer.bounds
        bounds.size.width *= CGFloat(validProgress)
        self.maskLayer.frame = bounds

        CATransaction.commit()
    }
}

/**
 渐变的圆环进度条

 🔰 UI 控件不完善，按需修改
 */
@IBDesignable
class GradientRingProgressView: UIView {
    @IBInspectable var color1: UIColor = #colorLiteral(red: 0.9921568627, green: 0.9725490196, blue: 0.4745098039, alpha: 1) {
        didSet {
            updateColor()
        }
    }
    @IBInspectable var color2: UIColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.03921568627, alpha: 1) {
        didSet {
            updateColor()
        }
    }

    @IBInspectable var trackColor: UIColor = #colorLiteral(red: 0.08235294118, green: 0.003921568627, blue: 0.3019607843, alpha: 1) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    @IBInspectable var trackWidth: CGFloat = 18 {
        didSet {
            trackLayer.lineWidth = trackWidth
            layer.setNeedsLayout()
        }
    }
    @IBInspectable var progressWidth: CGFloat = 18 {
        didSet {
            progressLayer.lineWidth = progressWidth
            layer.setNeedsLayout()
        }
    }
    @IBInspectable var progress: Float = 0 {
        didSet {
            if almostFullProgressAdjust,
               progress < 0.999 {
                progressLayer.strokeEnd = CGFloat(progress * adjustProgess)
            } else {
                progressLayer.strokeEnd = CGFloat(progress)
            }
        }
    }
    @IBInspectable var almostFullProgressAdjust: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onInit()
    }
    private func onInit() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(gradientLayer1)
//        gradientLayer1.addSublayer(gradientLayer2)
        gradientLayer1.mask = progressLayer
        updateColor()
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let rect = layer.bounds
        trackLayer.frame = rect
        gradientLayer1.frame = rect
//        gradientLayer2.frame = CGRect(x: rect.minX, y: rect.minY, width: rect.width * 0.5, height: rect.height)
        progressLayer.frame = rect
        let offset = max(trackWidth, progressWidth) / 2
        let lineRect = rect.insetBy(dx: offset, dy: offset)
        trackLayer.path = UIBezierPath(ovalIn: lineRect).cgPath
        progressLayer.path = progressPath(frame: lineRect).cgPath
        if almostFullProgressAdjust {
            let progressLength = (min(bounds.width, bounds.height) - max(trackWidth, progressWidth)) * CGFloat.pi
            adjustProgess = Float(1.0 - progressWidth * 0.5 / progressLength)
        }
    }
    private var adjustProgess: Float = 1

    private func updateColor() {
//        let midColor = color1.mixedColor(withRatio: 0.5, color: color2)
        gradientLayer1.colors = [color1.cgColor, color2.cgColor]
//        gradientLayer2.colors = [color1.cgColor, color2.cgColor]
    }

    private func progressPath(frame: CGRect) -> UIBezierPath {
        let ctr = CGFloat(0.27614)
        let xCtrLength = ctr * frame.width
        let yCtrLength = ctr * frame.height
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.midX, y: frame.minY))
        path.addCurve(to: CGPoint(x: frame.maxX, y: frame.midY),
                      controlPoint1: CGPoint(x: frame.midX + xCtrLength, y: frame.minY),
                      controlPoint2: CGPoint(x: frame.maxX, y: frame.midY - yCtrLength))
        path.addCurve(to: CGPoint(x: frame.midX, y: frame.maxY),
                      controlPoint1: CGPoint(x: frame.maxX, y: frame.midY + yCtrLength),
                      controlPoint2: CGPoint(x: frame.midX + xCtrLength, y: frame.maxY))
        path.addCurve(to: CGPoint(x: frame.minX, y: frame.midY),
                      controlPoint1: CGPoint(x: frame.midX - xCtrLength, y: frame.maxY),
                      controlPoint2: CGPoint(x: frame.minX, y: frame.midY + yCtrLength))
        path.addCurve(to: CGPoint(x: frame.midX, y: frame.minY),
                      controlPoint1: CGPoint(x: frame.minX, y: frame.midY - yCtrLength),
                      controlPoint2: CGPoint(x: frame.midX - xCtrLength, y: frame.minY))
        path.close()
        return path
    }

    lazy var trackLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = trackWidth
        shape.fillColor = nil
        shape.strokeColor = trackColor.cgColor
        shape.lineCap = .round
        return shape
    }()

    lazy var progressLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = progressWidth
        shape.fillColor = nil
        shape.strokeColor = UIColor.white.cgColor
        shape.lineCap = .round
        shape.strokeEnd = 0
        return shape
    }()

    lazy var gradientLayer1: CAGradientLayer = {
        let grad = CAGradientLayer()
        grad.locations = [0, 1] as [NSNumber]
        return grad
    }()
//    lazy var gradientLayer2: CAGradientLayer = {
//        let grad = CAGradientLayer()
//        grad.locations = [0, 1] as [NSNumber]
//        return grad
//    }()
}
