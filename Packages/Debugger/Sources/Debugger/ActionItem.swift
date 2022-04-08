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
public struct DebugActionItem {
    /// 操作描述
    public let title: String
    weak var target: AnyObject?
    var action: Selector?
    var actionBlock: (() -> Void)?

    /// 使用闭包创建一个调试操作
    public init(_ title: String, action: (() -> Void)?) {
        self.title = title
        self.actionBlock = action
    }

    /// target/action 方式创建一个调试操作
    public init(_ title: String, target: AnyObject?, _ action: Selector) {
        self.title = title
        self.target = target
        self.action = action
    }
}

/// 在 view controller 中定义，debugger 会从当前页面逐级向上遍历以获取所有的调试操作
public protocol DebugActionSource {
    /// 返回当前页面层级中支持的调试操作
    func debugActionItems() -> [DebugActionItem]
}

internal extension DebugActionItem {
    /// 执行附加的操作
    func perform() {
        actionBlock?()
        if let sel = action {
            UIApplication.shared.sendAction(sel, to: target, from: nil, for: nil)
        }
    }
}

// swiftlint:disable identifier_name

/// 旧版接口
public func DebugMenuItem(_ title: String, _ target: AnyObject?, _ selector: Selector) -> DebugActionItem {
    DebugActionItem(title, target: target, selector)
}

/// 旧版接口
public func DebugMenuItem2(_ title: String, _ block: @escaping () -> Void) -> DebugActionItem {
    DebugActionItem(title, action: block)
}
