/*
 MBLayoutButton

 Copyright © 2018-2019, 2023 BB9z.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

// @MBDependency:3

/**
 自定义元素布局的 button
 */
class MBLayoutButton: RFButton {

    /**
     禁用点按效果
     */
    @IBInspectable var touchEffectDisabled: Bool = false

    /**
     点击放大倍数

     默认 1.1
     */
    @IBInspectable var scale: CGFloat = 1.1

    @IBInspectable var touchDuration: Float = 0.2
    @IBInspectable var releaseDuration: Float = 0.3

    @IBInspectable var reduceAlphaWhenDisabled: Bool = false

    /**
     跳转链接

     如果设置了 touchUpInsideCallback，默认的点击跳转不会被执行
     */
    @IBInspectable var jumpURL: String?

    override func onInit() {
        super.onInit()
        addTarget(self, action: #selector(_touchDownEffect), for: .touchDown)
        addTarget(self, action: #selector(_touchUpEffect), for: [.touchUpOutside, .touchUpInside, .touchCancel])
    }

    override func afterInit() {
        super.afterInit()
        if touchUpInsideCallback != nil { return }
        touchUpInsideCallback = { [weak self] _ in
            guard let sf = self else { return }
            if sf.jumpURL?.isEmpty == false {
                if let url = URL(string: sf.jumpURL!) {
                    NavigationController.jump(url: url, context: nil)
                }
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            if reduceAlphaWhenDisabled {
                alpha = isEnabled ? 1 : 0.5
            }
        }
    }

    @objc private func _touchDownEffect() {
        if touchEffectDisabled { return }
        if isTouchDownEffectApplied { return }
        isTouchDownEffectApplied = true
        touchDownEffect()
    }

    @objc private func _touchUpEffect() {
        if !isTouchDownEffectApplied { return }
        touchUpEffect()
        isTouchDownEffectApplied = false
    }
    private var isTouchDownEffectApplied = false

    /// 重写已实现按下效果
    func touchDownEffect() {
        UIView.animate(withDuration: TimeInterval(touchDuration), delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.layer.transform = CATransform3DMakeScale(self.scale, self.scale, 1)
        }, completion: nil)
    }

    /// 重写已实现手势抬起恢复效果
    func touchUpEffect() {
        UIView.animate(withDuration: TimeInterval(releaseDuration), delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.layer.transform = CATransform3DIdentity
        }, completion: nil)
    }

    override var intrinsicContentSize: CGSize {
        bounds.size
    }
}
