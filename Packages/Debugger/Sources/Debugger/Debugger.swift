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
        guard let win = window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            NSLog("❌ \(#function): key window not found")
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
}

/// 入口按钮缓存实例
internal weak var triggerButton: TriggerButton?

// MARK: - 一些操作
public extension Debugger {
    /// 显示 VC 堆栈调试信息
    static func showViewControllerHierarchy() {
        let sel = Selector(("_printH" + "ierarchy"))
        guard UIViewController.responds(to: sel) else { return }
        let obj = UIViewController.perform(sel)
        guard let result = obj?.takeUnretainedValue() as? String else { return }
        print(result)
    }
}

// MARK: - Helper
internal extension Debugger {
    static var rootViewController: UIViewController? {
        let windows = UIApplication.shared.windows
        guard let win = windows.first(where: { $0.isKeyWindow }) ?? windows.first else {
            return nil
        }
        return win.rootViewController
    }
}
