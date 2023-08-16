/*
 HasItemSupport.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit
#if canImport(AppFramework)
import AppFramework
#endif

internal extension Debugger {
#if canImport(AppFramework)
    private static func findItem(between currentVC: UIViewController?, and primaryVC: UIViewController?) -> Any? {
        var viewController = currentVC
        while viewController != nil {
            if let vc = viewController as? AnyHasItem {
                return vc.item()
            }
            viewController = viewController?.parent
        }
        return nil
    }

    static func currentItemActionItem(_ currentVC: UIViewController?, _ primaryVC: UIViewController?) -> DebugActionItem? {
        guard let item = findItem(between: currentVC, and: primaryVC) else {
            return nil
        }
        let title = Debugger.shortDescription(value: item)
        return DebugActionItem(title) {
            Debugger.inspect(value: item)
        }
    }
#else
    static func currentItemActionItem(_ currentVC: UIViewController?, _ primaryVC: UIViewController?) -> DebugActionItem? {
        nil
    }
#endif

    /// 列表单元描述
    static func shortDescription(cell: Any) -> String {
#if canImport(AppFramework)
        var result = "\(type(of: cell))"
        if let hasItemCell = cell as? AnyHasItem {
            if let item = hasItemCell.item() as Any? {
                result += " / \(shortDescription(value: item))"
            }
        }
        return result
#else
        return "\(type(of: cell))"
#endif
    }

    static func inspect(cell: Any) {
#if canImport(AppFramework)
        if let hasItemCell = cell as? AnyHasItem {
            if let item = hasItemCell.item() as Any? {
                inspect(value: item)
                return
            }
        }
#endif
        inspect(value: cell)
    }
}
