/*:
 [目录](TOC) | [Previous](@previous) | [Next](@next)
 */

import PlaygroundSupport
import UIKit

let image = UIImage(named: "sample")

class RippleView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    private func setupLayer() {
        isUserInteractionEnabled = false
        replicatorLayer.frame = layer.bounds
        waveLayer.frame = replicatorLayer.bounds
        replicatorLayer.addSublayer(waveLayer)
        layer.addSublayer(replicatorLayer)
    }

    private lazy var replicatorLayer: CAReplicatorLayer = {
        let rlayer = CAReplicatorLayer()
        rlayer.frame = CGRect(origin: .zero, size: bounds.size)
        rlayer.instanceCount = 3
        rlayer.instanceDelay = 1
        return rlayer
    }()

    private lazy var waveLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.bounds = bounds
        layer.contents = image?.cgImage
        layer.opacity = 0
        return layer
    }()

    @IBInspectable private(set) var isAnimating: Bool = false {
        didSet {
            if hidesWhenStopped {
                isHidden = !isAnimating
            }
        }
    }
    @IBInspectable var hidesWhenStopped: Bool = true

    @objc func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        installAnimation()
    }
    @objc func stopAnimating() {
        guard isAnimating else { return }
        isAnimating = false
        uninstallAnimation()
    }

    private func installAnimation() {
        if waveLayer.animation(forKey: "wave") != nil { return }
        let frame = waveLayer.bounds
        let animation = CAAnimationGroup()

        let scaleAnm = CABasicAnimation(keyPath: "transform.scale")
        scaleAnm.fromValue = 0
        scaleAnm.toValue = 1

        let alphaAnm = CAKeyframeAnimation(keyPath: #keyPath(CALayer.opacity))
        alphaAnm.values = [1, 1, 0]
        alphaAnm.keyTimes = [0, 0.5, 1]

        animation.animations = [scaleAnm, alphaAnm]
        animation.duration = replicatorLayer.instanceDelay * Double( replicatorLayer.instanceCount)
        animation.autoreverses = false
        animation.repeatCount = .greatestFiniteMagnitude

        waveLayer.add(animation, forKey: "wave")
//        waveLayer.mbPersistCurrentAnimations()
    }
    private func uninstallAnimation() {
        waveLayer.removeAnimation(forKey: "wave")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            if isAnimating {
                installAnimation()
            }
        } else {
            uninstallAnimation()
        }
    }
}


let view = RippleView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
view.tintColor = .red
PlaygroundPage.current.liveView = view
view.startAnimating()
