/*
 MBGroupSelectionControl

 Copyright © 2021, 2023 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(UIKit)
import B9Action
import UIKit

public protocol MBGroupSelectionControlDelegate: AnyObject {
    /// 是否允许选中控件，传入的 control 一定是当前未选中的
    func groupSelectionControl(_ control: MBGroupSelectionControl, shouldSelect control: UIControl) -> Bool
    /// 是否允许取消选中控件，传入的 control 一定是当前已选中的
    func groupSelectionControl(_ control: MBGroupSelectionControl, shouldDeselect control: UIControl) -> Bool
}

/**
 用于管理一组 UIControl 的选择（isSelected）状态

 当用户点击处于管理中的控件时，会切换其选中状态。外部通过代码直接修改管控控件的 isSelected 属性，状态是不认的。

 当控件的选中状态发生变化时会发送 `UIControl.Event.valueChanged` 事件。





 在 Interface Builder 中，除了可以作为一般的 control view 使用，还可仅作为一个附加对象，只控制控制逻辑：
 附加一个 NSObject 到 scene 上，修改类名，然后连接 controls 等属性，继承 UIControl 只是为了便于发送事件。

 实现备忘：

 - 不加泛型，因为 IB 不支持
 */
open class MBGroupSelectionControl: UIControl {
    /// 处于管理的控件，设置更新时会维持已有的选中状态
    @IBOutlet public var controls: [UIControl] {
        get { selectedTracker.elements }
        set {
            let changes = selectedTracker.update(elements: newValue, keepActive: true)
            update(selectedControls: [], deselectedControls: changes.deactived, animated: false)
            newValue.forEach(setupAction(control:))
        }
    }

    /// 处于选中状态的控件，始终会是 controls 的子集
    open var selectedControls: [UIControl] {
        selectedTracker.activedElements
    }

    /// 选中控件的 tag 集合，已去重并排序
    public var selectedTags: [Int] {
        selectedTracker.activedElements.map { $0.tag }.sorted()
    }

    open func update(selection controls: [UIControl], animated: Bool) {
        let changes = selectedTracker.set(activedElements: controls)
        update(selectedControls: changes.actived, deselectedControls: changes.deactived, animated: animated)
    }

    /// 最少允许同时选中几个控件，用于设置必选
    @IBInspectable open var minimumSelectCount: Int = 1
    /// 最多允许同时选中几个控件，默认 0 不限制
    @IBInspectable open var maximumSelectCount: Int = 0

    /// 用于选中状态发生了变化的控件进行更新，子类重载用，默认什么也不做
    open func update(selectedControls: [UIControl], deselectedControls: [UIControl], animated: Bool) {
        // for override
    }

    public weak var delegate: MBGroupSelectionControlDelegate?

    /// 延迟选中变化事件的发送，避免连续选择发送多个无意义变更，> 0 启用，不可以是负数
    @IBInspectable open var valueChangedActionDelay: Double = 0 {
        didSet {
            assert(valueChangedActionDelay >= 0, "valueChangedActionDelay must >= 0")
            if oldValue == valueChangedActionDelay { return }
            needsSendValueChangedAction = DelayAction(needsSendValueChangedAction.action, delay: valueChangedActionDelay)
        }
    }

    // MARK: -
    private var selectedTracker = CollectionStateTracker<UIControl>()
    private lazy var needsSendValueChangedAction = DelayAction(Action { [weak self] in
        self?.sendActions(for: .valueChanged)
    }, delay: valueChangedActionDelay)
}

extension MBGroupSelectionControl {
    private func setupAction(control: UIControl) {
        let action = #selector(_handleControlTap(sender:))
        let actionString = NSStringFromSelector(action)
        if nil != control.actions(forTarget: self, forControlEvent: .touchUpInside)?.first(where: { $0 == actionString }) {
            return
        }
        control.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func _handleControlTap(sender: UIControl) {
        if sender.isSelected && selectedControls.count <= minimumSelectCount {
            return
        }
        if maximumSelectCount == 1 {
            // 单选模式
            controls.forEach { ctr in
                if ctr.isSelected, ctr != sender { ctr.isSelected.toggle() }
            }
            // continue
        } else if maximumSelectCount > 1 {
            if !sender.isSelected && selectedControls.count >= maximumSelectCount {
                return
            }
        }
        sender.isSelected.toggle()
        if valueChangedActionDelay > 0 {
            needsSendValueChangedAction.set()
        } else {
            sendActions(for: .valueChanged)
        }
    }
}

#endif // END: UIKit
