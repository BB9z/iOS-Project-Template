/*
 ActionItem.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/// 调试操作定义
public typealias DebugActionItem = UIBarButtonItem

/// 在 view controller 中定义，debugger 会从当前页面逐级向上遍历以获取所有的调试操作
@objc public protocol DebugActionSource {
    /// 返回当前页面层级中支持的调试操作
    func debugActionItems() -> [DebugActionItem]
}

public extension DebugActionItem {
    /// 使用闭包创建一个调试操作
    convenience init(_ title: String, action: (() -> Void)?) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        actionBlock = action
    }

    /// target/action 传统方式创建一个调试操作
    convenience init(_ title: String, target: Any?, _ action: Selector) {
        self.init(title: title, style: .plain, target: target, action: action)
    }
}

/// 增加对闭包的支持
internal extension DebugActionItem {
    private var actionBlock: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &actionBlockAssociation) as? (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, &actionBlockAssociation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 执行附加的操作
    func perform() {
        if !isEnabled { return }
        actionBlock?()
        if let sel = action {
            UIApplication.shared.sendAction(sel, to: target, from: nil, for: nil)
        }
    }
}
private var actionBlockAssociation: UInt8 = 0

// swiftlint:disable identifier_name

/// 旧版接口
public func DebugMenuItem(_ title: String, _ target: Any?, _ selector: Selector) -> DebugActionItem {
    DebugActionItem(title: title, style: .plain, target: target, action: selector)
}

/// 旧版接口
public func DebugMenuItem2(_ title: String, _ block: @escaping () -> Void) -> DebugActionItem {
    DebugActionItem(title, action: block)
}
