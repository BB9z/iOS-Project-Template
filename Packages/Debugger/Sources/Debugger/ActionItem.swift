/*
 ActionItem.swift
 Debugger

 Copyright © 2022-2023 BB9z.
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
    ///
    /// - Parameters:
    ///   - target: 可以为空，为空时通过响应链执行 selector
    public init(_ title: String, target: AnyObject?, _ action: Selector) {
        self.title = title
        self.target = target
        self.action = action
    }

    /// 为 ``DebugActionSource`` 提供数据
    public static func items(_ with: (DebugActionBuilder) -> Void) -> [DebugActionItem] {
        let builder = DebugActionBuilder()
        with(builder)
        return builder.build()
    }
}

/// 创建一组 ``DebugActionItem`` 使用，见：``DebugActionItem/items(_:)``
public final class DebugActionBuilder: NSObject {
    /// 附加一个闭包操作
    public func add(_ title: String, action: @escaping (() -> Void)) {
        items.append(.init(title, action: action))
    }
    
    /// 附加一个 target/selector 操作
    public func add(_ title: String, target: AnyObject?, selector: Selector) {
        items.append(.init(title, target: target, selector))
    }
    
    var items = [DebugActionItem]()
    func build() -> [DebugActionItem] {
        items
    }
}

/**
 在 view controller 中定义，debugger 会从当前页面逐级向上遍历以获取所有的调试操作
 
 建议用 DEBUG 宏包裹，示例代码：
 
 ```swift
 #if DEBUG
 import Debugger
 extension SomeViewController: DebugActionSource {
     func debugActionItems() -> [DebugActionItem] {
         ...
     }
 }
 #endif
 ```
 */
public protocol DebugActionSource: AnyObject {
    /**
     返回当前页面层级中支持的调试操作
     
     定义示例：
     
     ```swift
     func debugActionItems() -> [DebugActionItem] {
         [
             DebugActionItem("加1") { [self] in
                 count += 1
             },
             DebugActionItem("重置", target: self, #selector(reset)),
         ]
     }
     ```
     
     或使用 action builder，这种方式的好处之一是可以判断条件添加不同的操作项：
     
     ```swift
     func debugActionItems() -> [DebugActionItem] {
         DebugActionItem.items {
             $0.add("加1") { [self] in
                 count += 1
             }
             if count > 0 {
                 $0.add("重置", target: self, selector: #selector(reset))
             }
         }
     }
     ```
     */
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
