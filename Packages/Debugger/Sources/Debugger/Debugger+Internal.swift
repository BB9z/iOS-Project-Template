/*
 Debugger+Internal.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

// swiftlint:disable identifier_name
/// 入口按钮缓存实例
internal weak var triggerButton: TriggerButton?
private var _floatWindow: Window?
internal var _globalActionItems: [DebugActionItem]?
// swiftlint:enable identifier_name

internal extension Debugger {
    static var floatWindow: Window! {
        get {
            _floatWindow ?? {
                let win = Window()
                win.backgroundColor = nil
                win.windowLevel = .statusBar
                win.rootViewController = storyboard.instantiateInitialViewController()
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

    /// 尝试找应用处于活跃的窗体
    @available(iOS 13.0, *)
    static var activedWindowScene: UIWindowScene? {
        if let actived = tureKeyWindow?.windowScene { return actived }
        let scenes = UIApplication.shared.connectedScenes
        return (scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first) as? UIWindowScene
    }

    private static var tureKeyWindow: UIWindow? {
        (UIApplication.shared as DeprecatedKeyWindow).keyWindow
    }

    /// 尝试找应用活跃窗体的 key window
    static var mainWindow: UIWindow? {
        if let actived = tureKeyWindow { return actived }
        if #available(iOS 13.0, *) {
            let windows = activedWindowScene?.windows ?? UIApplication.shared.windows
            return windows.first(where: { $0.isKeyWindow }) ?? windows.first
        } else {
            let windows = UIApplication.shared.windows
            return windows.first(where: { $0.isKeyWindow }) ?? windows.first
        }
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

    static var storyboard: UIStoryboard {
        UIStoryboard(name: "Debugger", bundle: Bundle.module)
    }

    static func show(text: String) {
        let vc = DescriptionViewController.new()
        vc.item = text
        floatWindow.debuggerPush(vc: vc)
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

    static func unwrap(optional value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle != .optional {
            return value
        }
        if let (_, some) = mirror.children.first {
            return some
        }
        return nil
    }

    /// 输入的类型 + id 描述
    static func shortDescription(value: Any) -> String {
        guard let value = unwrap(optional: value) else { return "nil" }
        let mirror = Mirror(reflecting: value)
        var title = String(describing: mirror.subjectType)
        for child in mirror.children {
            if child.label == "id" || child.label == "uid" {
                if let value = child.value as? CustomStringConvertible {
                    title += ": \(value)"
                    break
                }
            }
        }
        return title
    }

    static func toggleControlCenterVisableFromButton() {
        if floatWindow.isHidden {
            showControlCenter()
            return
        }
        if #available(iOS 13.0, *) {
            if let buttonWin = triggerButton?.window, floatWindow.windowScene != buttonWin.windowScene {
                // 按钮和浮窗不在同一窗体，移动浮窗
                showControlCenter()
                return
            }
        }
        hideControlCenter()
    }

    static func hideTriggerButtonForAwhile() {
        triggerButton?.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            triggerButton?.isHidden = false
        }
    }
}

// 帮助找真正的处于激活中的 window
// 支持多窗体的应用，会同时有多个 scene 处于 foregroundActive（这很合理），只有 keyWindow 能反应真正激活的（或者是最后激活的）
private protocol DeprecatedKeyWindow {
    var keyWindow: UIWindow? { get }
}
extension UIApplication: DeprecatedKeyWindow {
}

