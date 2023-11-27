/*
 UIKit+Test.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(UIKit)
import UIKit

/// 代码创建 UI 元素，链式写法支持
extension UIView {
    func tag(_ tag: Int) -> Self {
        self.tag = tag
        return self
    }
}

enum SimulateApp {
    /// Swift Package 中单元测试没有 host app 环境，UIApplication 实例不存在，
    /// 导致 UIControl 的事件无法发送，为此需要进行了一些模拟替换
    static func setupForNoHost() {
        guard !hasSetup else { return }
        hasSetup = true
        UIControl.hookSetup()
    }

    private static var hasSetup = false
}

fileprivate extension UIControl {
    static func hookSetup() {
        exchange(Self.self, #selector(sendActions(for:)), #selector(hookedSendActions))
    }

    @objc func hookedSendActions(for controlEvents: UIControl.Event) {
        for target in allTargets {
            let object: NSObject = target as NSObject
            let rawActions = actions(forTarget: target, forControlEvent: controlEvents)
            for action in rawActions ?? [] {
                let selector = Selector(action)
                object.perform(selector, with: self)
            }
        }
    }
}

// swizzle 不完成实现
private func exchange(_ cls: AnyClass, _ original: Selector, _ new: Selector) {
    guard let orginalMethod = class_getInstanceMethod(cls, original),
          let newMethod = class_getInstanceMethod(cls, new) else {
        fatalError()
    }
    method_exchangeImplementations(orginalMethod, newMethod)
}

#endif
