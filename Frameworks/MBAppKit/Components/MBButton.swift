/*!
 MBButton
 MBAppKit

 Copyright © 2018, 2021, 2023 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

/**
 按钮基类

 主要用于外观定制
 */
class MBButton: UIButton {

    /**
     样式名，以便让同一个按钮类支持多个样式

     一般在 setupAppearance 根据 styleName 做相应配置
     */
    @IBInspectable var styleName: String?

    /**
     子类重写该方法设置外观

     外观设置的时机是在 button 初始化后尽可能的早，在初始化时就不能通过 skipAppearanceSetup 略过设置，太晚可能会覆盖正常业务代码的设置。从 nib 载入的设置时机稳定在 awakeFromNib，通过代码创建时时机不定，可通过 appearanceSetupDone 属性辅助判断

     通常不用调用 super

     ```
     func setupAppearance() {
         setBackgroundImage(IMAGE, for: .disabled)
         setBackgroundImage(IMAGE, for: .normal)
         setBackgroundImage(IMAGE, for: .highlighted)

         setTitleColor(COLOR, for: .disabled)
         setTitleColor(COLOR, for: .normal)
         setTitleColor(COLOR, for: .highlighted)
     }
     ```
     */
    func setupAppearance() {
        // For overwrite
    }

    /**
     子类重写，当按钮尺寸变化时执行
     */
    func setupAppearanceAfterSizeChanged() {
        // For overwrite
    }

    /**
     外观代码设置完成标记，一般只有通过代码创建 button 时才需要判断
     */
    private(set) var appearanceSetupDone = false

    @IBInspectable var skipAppearanceSetup = false

    /**
     扩展按钮可响应点击的区域
     */
    var touchHitTestExpandInsets = UIEdgeInsets.zero
    @IBInspectable var _touchHitTestExpandInsets: CGRect {
        get {
            NSValue(uiEdgeInsets: touchHitTestExpandInsets).cgRectValue
        }
        set {
            touchHitTestExpandInsets = NSValue(cgRect: newValue).uiEdgeInsetsValue
        }
    }

    /**
     非空时按钮原有的点击事件不在发送，而改为执行该 block

     设计时的场景是增加一种禁用状态，可以点击但不走正常的事件
     */
    var blockTouchEvent: (() -> Void)?

    /**
     点击按钮时执行的操作，默认什么也不做
     */
    @objc func onButtonTapped() {
        // For overwrite
    }

    // MARK: - RFInitializing

    func onInit() {
        // For overwrite
    }

    func afterInit() {
        addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        _setupAppearance()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _setupAppearance()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        _setupAppearance()
    }

    private func _setupAppearance() {
        if appearanceSetupDone { return }
        appearanceSetupDone = true
        if !skipAppearanceSetup {
            setupAppearance()
        }
    }

    override var bounds: CGRect {
        didSet {
            if !skipAppearanceSetup && !oldValue.size.equalTo(bounds.size) {
                setupAppearanceAfterSizeChanged()
            }
        }
    }

    override var frame: CGRect {
        didSet {
            if !skipAppearanceSetup && !oldValue.size.equalTo(frame.size) {
                setupAppearanceAfterSizeChanged()
            }
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let reversedInsets = touchHitTestExpandInsets.reversed()
        let expandRect = bounds.inset(by: reversedInsets)
        return expandRect.contains(point)
    }

    private var _MBButton_blockTouchEventFlag = false

    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if let blockTouchEvent = blockTouchEvent, event?.type == .touches {
            if !_MBButton_blockTouchEventFlag {
                _MBButton_blockTouchEventFlag = true
                blockTouchEvent()
                DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                    self?._MBButton_blockTouchEventFlag = false
                }
            }
            return
        }
        super.sendAction(action, to: target, for: event)
    }
}

/**
 作为按钮容器，解决按钮在 view 的 bounds 外不可点的问题
 */
class MBControlTouchExpandContainerView: UIView {
    @IBOutlet var controls: [UIControl]?

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for c in controls ?? [] {
            if c.point(inside: convert(point, to: c), with: event) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
}
