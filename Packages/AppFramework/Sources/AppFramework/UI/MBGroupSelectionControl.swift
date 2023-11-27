/*
 MBGroupSelectionControl
 AppFramework

 Copyright © 2021, 2023 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(UIKit)
import B9Action
import UIKit

@objc
public protocol MBGroupSelectionControlDelegate: AnyObject {
    /// 是否允许选中控件，传入的 control 一定是当前未选中的
    @objc optional func groupSelectionControl(_ groupControl: MBGroupSelectionControl, shouldSelect control: UIControl) -> Bool
    /// 是否允许取消选中控件，传入的 control 一定是当前已选中的，单选模式不调用
    @objc optional func groupSelectionControl(_ groupControl: MBGroupSelectionControl, shouldDeselect control: UIControl) -> Bool
}

/**
 用于管理一组 UIControl 的选择（isSelected）状态

 当用户点击处于管理中的控件时，会切换其选中状态。外部通过代码直接修改管控控件的 isSelected 属性，状态是不认的。

 当控件的选中状态发生变化时会发送 `UIControl.Event.valueChanged` 事件。

 在 Interface Builder 中，除了可以作为一般的 control view 使用，还可仅作为一个附加对象，只控制控制逻辑：
 附加一个 NSObject 到 scene 上，修改类名，然后连接 controls 等属性，继承 UIControl 只是为了便于发送事件。

 ## Topics

 ### 数据源

 - ``controls``
 - ``allowsMultipleSelection``

 ### 选中状态

 - ``selectedControls``
 - ``selectedIndex``
 - ``selectedTags``

 ### 更新选中

 - ``update(selection:animated:)``
 - ``update(selectedControls:deselectedControls:animated:)``

 ### 事件控制

 - ``delegate``
 - ``valueChangedActionDelay``

 <!-- 实现备忘：不加泛型，否则无法在 Interface Builder 中使用 -->
 */
open class MBGroupSelectionControl: UIControl {
    /// 处于管理的控件，设置更新时会维持已有的选中状态
    @IBOutlet open var controls: [UIControl] {
        get { selectedTracker.elements }
        set {
            let oldValue = controls
            if oldValue == newValue { return }
            let action = #selector(_handleControlTap(sender:))
            oldValue.forEach {
                $0.removeTarget(self, action: action, for: .touchUpInside)
            }
            newValue.forEach {
                $0.addTarget(self, action: action, for: .touchUpInside)
            }
            let changes = selectedTracker.update(elements: newValue, keepActive: true)
            update(selectedControls: [], deselectedControls: changes.deactivated, animated: false)
        }
    }

    /// 处于选中状态的控件，始终会是 ``MBGroupSelectionControl/controls`` 的子集
    public var selectedControls: [UIControl] {
        selectedTracker.activedElements
    }

    /// 选中控件的 tag 集合，已去重并按数值大小排序
    open var selectedTags: [Int] {
        selectedTracker.activedElements.map { $0.tag }.sorted()
    }

    /// 选中控件的序号，置空反选全部。多选时：获取的是最靠前的序号，设置时如果已选中多个，强制变为指定的单个
    ///
    /// 越界时触发 ``MBAssert(_:_:file:line:)``，无操作
    open var selectedIndex: Int? {
        // 多选时的序号应该没什么意义，只实现单选的
        get {
            selectedTracker.activedIndexs.min()
        }
        set {
            guard let newIndex = newValue, newIndex != NSNotFound else {
                update(selection: [], animated: false)
                return
            }
            guard newIndex < selectedTracker.count, newIndex >= 0 else {
                MBAssert(false, "selectedIndex 越界")
                return
            }
            let newSelection = selectedTracker.elements(of: IndexSet(integer: newIndex))
            update(selection: newSelection, animated: false)
        }
    }

    /// 更新选中状态
    ///
    /// - SeeAlso: ``update(selectedControls:deselectedControls:animated:)``
    public func update(selection controls: [UIControl], animated: Bool) {
        let changes = selectedTracker.set(activedElements: controls)
        if changes.activated.isEmpty && changes.deactivated.isEmpty {
            return
        }
        changes.activated.forEach { $0.isSelected = true }
        changes.deactivated.forEach { $0.isSelected = false }
        update(selectedControls: changes.activated, deselectedControls: changes.deactivated, animated: animated)
    }

    /**
     单选还是多选模式，默认单选模式

     单选模式下，选中一个控件会取消其他控件的选中状态，点选已选中控件无操作；
     多选模式下，选中一个控件不会影响其他控件的状态，点选已选中控件会取消其选中状态。

     多选模式变为单选，如果已选中控件多于一个，会保留第一个选中的控件的状态，其他控件重置选中。
     */
    @IBInspectable open var allowsMultipleSelection: Bool = false {
        didSet {
            if oldValue == allowsMultipleSelection { return }
            if !allowsMultipleSelection {
                let selected = selectedControls
                if selected.count > 1 {
                    update(selection: [selected[0]], animated: false)
                }
            }
        }
    }

    /// 用于选中状态发生了变化的控件进行更新，子类重载用，默认什么也不做
    open func update(selectedControls: [UIControl], deselectedControls: [UIControl], animated: Bool) {
        // for override
    }

    @IBOutlet open weak var delegate: MBGroupSelectionControlDelegate?

    /// 延迟选中变化事件的发送，避免连续选择发送多个无意义变更，> 0 启用，不可以是负数
    @IBInspectable open var valueChangedActionDelay: Double = 0 {
        didSet {
            assert(valueChangedActionDelay >= 0, "valueChangedActionDelay must >= 0")
            if oldValue == valueChangedActionDelay { return }
            needsSendValueChangedAction = DelayAction(needsSendValueChangedAction.action, delay: valueChangedActionDelay)
        }
    }

    /// 在 Interface Builder 中绑定一个 UIStackView，将其管理的 UIControl 作为 controls
    @available(*, deprecated, message: "仅用于在 IB 中便捷设置，不允许代码访问")
    @IBOutlet public weak var _IBBindStackArrangedAsControls: UIStackView! {
        get { nil }
        set {
            controls = newValue.arrangedSubviews.compactMap { $0 as? UIControl }
        }
    }

    // MARK: -
    private var selectedTracker = CollectionStateTracker<UIControl>()
    private lazy var needsSendValueChangedAction = DelayAction(Action { [weak self] in
        self?.sendActions(for: .valueChanged)
    }, delay: valueChangedActionDelay)
}

extension MBGroupSelectionControl {
    @objc private func _handleControlTap(sender: UIControl) {
        if allowsMultipleSelection {
            var selected = selectedTracker.activedElements
            if let idx = selected.firstIndex(of: sender) {
                if delegate?.groupSelectionControl?(self, shouldDeselect: sender) ?? true {
                    selected.remove(at: idx)
                    update(selection: selected, animated: true)
                }
            } else {
                if delegate?.groupSelectionControl?(self, shouldSelect: sender) ?? true {
                    selected.append(sender)
                    update(selection: selected, animated: true)
                }
            }
        } else {
            if selectedTracker.isActived(sender) {
                return  // noop
            }
            if delegate?.groupSelectionControl?(self, shouldSelect: sender) ?? true {
                update(selection: [sender], animated: true)
            }
        }
        noticeValueChanged()
    }

    private func noticeValueChanged() {
        if valueChangedActionDelay > 0 {
            needsSendValueChangedAction.set()
        } else {
            sendActions(for: .valueChanged)
        }
    }
}

#endif // END: UIKit
