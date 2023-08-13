/*!
 MBTouchEffectButton

 Copyright © 2018, 2023 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 按钮基础类，为按下实现特殊效果提供支持

 Button base class that provides support for implementing special effects when pressed.
 */
class MBTouchEffectButton: MBButton {

    /**
     禁用点按效果

     Disables the touch effect.
     */
    @IBInspectable var touchEffectDisabled: Bool = false

    private var touchDownEffectApplied = false

    override func onInit() {
        super.onInit()

        addTarget(self, action: #selector(onTouchDown), for: .touchDown)
        addTarget(self, action: #selector(onTouchUp), for: [.touchUpOutside, .touchUpInside, .touchCancel])
    }

    @objc private func onTouchDown() {
        if touchEffectDisabled {
            return
        }
        if touchDownEffectApplied {
            return
        }
        touchDownEffectApplied = true
        touchDownEffect()
    }

    @objc private func onTouchUp() {
        if !touchDownEffectApplied {
            return
        }
        touchUpEffect()
        touchDownEffectApplied = false
    }

    /**
     重写以实现按下效果

     Overwrite to implement the touch down effect.
     */
    func touchDownEffect() {
        // For overwrite
    }

    /**
     重写以实现手势抬起恢复效果

     Overwrite to implement the touch up effect.
     */
    func touchUpEffect() {
        // For overwrite
    }
}
