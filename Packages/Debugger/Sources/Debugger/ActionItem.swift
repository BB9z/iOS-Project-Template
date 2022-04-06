//
//  File.swift
//  
//
//  Created by BB9z on 2022/4/6.
//

import UIKit

/// 调试操作定义
public typealias DebugActionItem = UIBarButtonItem

private var actionBlockAssociation: UInt8 = 0

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

    convenience init(title: String, action: (() -> Void)?) {
        self.init(title: title, style: .plain, target: nil, action: nil)
        actionBlock = action
    }
}

// swiftlint:disable identifier_name

/// 旧版接口
public func DebugMenuItem(_ title: String, _ target: Any?, _ selector: Selector) -> DebugActionItem {
    DebugActionItem(title: title, style: .plain, target: target, action: selector)
}

/// 旧版接口
public func DebugMenuItem2(_ title: String, _ block: @escaping () -> Void) -> DebugActionItem {
    DebugActionItem(title: title, action: block)
}
