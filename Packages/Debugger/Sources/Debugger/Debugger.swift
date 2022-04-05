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

    ///
    public static var isDebugEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "__debugEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "__debugEnabled")
        }
    }
}

internal weak var triggerButton: TriggerButton?
