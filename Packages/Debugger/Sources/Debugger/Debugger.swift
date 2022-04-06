/*
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import B9FoundationUI
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

    static var floatWindow: Window! {
        get {
            _floatWindow ?? {
                let win = Window()
                win.backgroundColor = nil
                win.windowLevel = .statusBar
                win.rootViewController = UIStoryboard(name: "Debugger", bundle: Bundle.module)
                    .instantiateInitialViewController()
                _floatWindow = win
                return win
            }()
        }
        set {
            _floatWindow = newValue
        }
    }

    static var floatViewController: FloatViewController? {
        floatWindow?.rootViewController as? FloatViewController
    }
}

private var _floatWindow: Window?

/// 入口按钮缓存实例
internal weak var triggerButton: TriggerButton?

// MARK: - 一些操作
public extension Debugger {
    /// 切换调试面板显隐
    static func toggleControlCenterVisable() {
        floatWindow.isHidden.toggle()
        if !floatWindow.isHidden {
            floatViewController?.refresh()
        }
    }

    /// 隐藏调试面板
    static func showControlCenter() {
        floatWindow.isHidden = true
        floatViewController?.refresh()
    }

    /// 隐藏调试面板
    static func hideControlCenter() {
        floatWindow.isHidden = true
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
}

// MARK: - Helper
internal extension Debugger {
    /// 尝试找应用的 key window，找不到用第一个 window
    static var mainWindow: UIWindow? {
        let windows = UIApplication.shared.windows
        return windows.first(where: { $0.isKeyWindow }) ?? windows.first
    }

    /// 主 window 的根视图
    static var rootViewController: UIViewController? {
        mainWindow?.rootViewController
    }

    /// 通过 hit test 找当前的 view controller
    static var currentViewController: UIViewController? {
        guard let win = mainWindow else { return nil }
        // 中心点偏右上，减少识别到中间 HUD 的可能性
        let testPoint = CGPoint(x: win.bounds.width * 0.7, y: win.bounds.height * 0.3)
        let vc = win.hitTest(testPoint, with: nil)?.viewController
        return vc
    }


    static func alertShow(text: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "关闭", style: .cancel, handler: nil))
        guard let vc = rootViewController else { return }
        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view
            let bounds = vc.view.bounds
            popover.sourceRect = CGRect(origin: CGPoint(x: bounds.midX, y: bounds.midY), size: .zero)
            popover.permittedArrowDirections = []
        }
        vc.present(alert, animated: true, completion: nil)
    }

    static func hideControlCenterForAwhile() {
        hideControlCenter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            showControlCenter()
        }
    }
}
