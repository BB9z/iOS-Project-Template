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
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result is WindowTouchForwardView {
            return nil
        }
        return result
    }
}

internal final class WindowTouchForwardView: UIView {
}
