/*
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/**
 Debugger
 */
public enum Debugger {
    /**
     将调试入口按钮添加到界面上

     如果按钮后来被其他 view 覆盖了，重新调用可以把按钮移到顶部

     - Parameter window: 添加到哪个 window 里，未指定使用应用当前的 key window
     */
    public static func installTriggerButton(in window: UIWindow? = nil) {
        guard let win = window ?? mainWindow else {
            NSLog("❌ %@: key window not found", #function)
            return
        }
        if let button = triggerButton {
            button.removeFromSuperview()
            button.frame = CGRect(x: 5, y: win.bounds.height - 20 - 5, width: 20, height: 20)
            win.addSubview(button)
            return
        }
        let button = TriggerButton(frame: CGRect(x: 5, y: win.bounds.height - 20 - 5, width: 20, height: 20))
        button.backgroundColor = .systemTeal
        button.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        button.alpha = 0.3
        win.addSubview(button)
        triggerButton = button
        #if DEBUG
        self.isDebugEnabled = true
        #endif
    }

    /**
     调试模式是否开启，用于控制调试入口按钮的显隐

     在 DEBUG 模式下，执行 `installTriggerButton()` 会自动开启
     */
    public static var isDebugEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "__debugEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "__debugEnabled")
        }
    }

    /// 附加的全局操作，供应用定制
    public static var globalActionItems: [DebugActionItem] {
        get {
            _globalActionItems ?? []
        }
        set {
            _globalActionItems = newValue
            DispatchQueue.main.async {
                floatViewController?.refresh()
            }
        }
    }

    /// 自定义对象检查方法
    public static var vauleInspector: ((Any) -> Void)?

    /// 检测列表时依据的属性名
    /// 列表可以是 UITableView、UICollectionView 和 VisableCellInspecting
    public static var inspectingListPropertyNames: [String] = ["listView", "tableView", "collectionView"]

    /// 测试 URL 跳转时，如何处理 URL 需要应用指定
    public static var urlJumpHandler: ((URL) -> Void)?
}

// MARK: - 一些操作
public extension Debugger {
    /// 显示调试面板
    static func showControlCenter() {
        if #available(iOS 13.0, *) {
            floatWindow.windowScene = triggerButton?.window?.windowScene ?? activatedWindowScene
        }
        floatWindow.isHidden = false
        floatViewController?.refresh()
    }

    /// 隐藏调试面板
    static func hideControlCenter() {
        floatWindow.isHidden = true
    }

    static func showDebugView(_ view: UIView) {
        floatViewController?.customView = view
    }

    static func hideDebugView() {
        floatViewController?.customView = nil
    }

    /// 检查对象
    static func inspect(value: Any) {
        guard let value = unwrap(optional: value) else {
            return
        }
        if let cb = vauleInspector {
            cb(value)
            return
        }
        if let value = value as? CustomDebugStringConvertible {
            show(text: value.debugDescription)
        } else {
            var output = ""
            dump(value, to: &output)
            show(text: output)
        }
    }

    /// 检测列表可见单元
    static func inspectVisableCell() {
        guard let cells = inspectListCell(Debugger.currentViewController) else {
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: nil))
        for cell in cells {
            alert.addAction(UIAlertAction(title: shortDescription(cell: cell), style: .default, handler: { _ in
                inspect(cell: cell)
            }))
        }
        present(alertController: alert)
    }

    /// 显示 VC 堆栈调试信息
    static func showViewControllerHierarchy() {
        let sel = Selector(("_printH" + "ierarchy"))
        guard UIViewController.responds(to: sel) else { return }
        let isFloatShown = !floatWindow.isHidden
        if isFloatShown {
            // 不隐藏在 iOS 上会显示 debug window 内的结构
            floatWindow.isHidden = true
        }
        let obj = UIViewController.perform(sel)
        if isFloatShown {
            floatWindow.isHidden = false
        }
        guard let result = obj?.takeUnretainedValue() as? String else { return }
        print(result)
        alertShow(text: result)
    }

    /// 模拟内存警告
    static func simulateMemoryWarning() {
        let sel = Selector(("_performMemoryWarning"))
        UIApplication.shared.perform(sel, with: nil, afterDelay: 0)
    }

    /// 重置网络相关存储
    static func resetURLStorage() {
        URLCache.shared.removeAllCachedResponses()
        let credentialStorage = URLCredentialStorage.shared
        for (space, obj) in credentialStorage.allCredentials {
            for credential in obj.values {
                credentialStorage.remove(credential, for: space)
            }
        }
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.cookies?.forEach { cookieStorage.deleteCookie($0) }
    }
}
