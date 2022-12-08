/*
 Window.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

internal final class Window: UIWindow {
    override var canBecomeKey: Bool { false }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result is WindowTouchForwardView {
            return nil
        }
        return result
    }

    @IBAction internal func debuggerHide(_ sender: Any) {
        Debugger.hideControlCenter()
    }

    private var viewControllers = [UIViewController]()

    @IBAction internal func debuggerBack(_ sender: Any?) {
        if rootViewController == viewControllers.last {
            _ = viewControllers.popLast()
        }
        rootViewController = viewControllers.last
        if rootViewController == nil {
            Debugger.hideControlCenter()
        }
    }

    func debuggerPush(vc: UIViewController) {
        if let current = rootViewController,
           !viewControllers.contains(current) {
            viewControllers.append(current)
        }
        viewControllers.append(vc)
        rootViewController = vc
    }
}

internal final class WindowTouchForwardView: UIView {
}
