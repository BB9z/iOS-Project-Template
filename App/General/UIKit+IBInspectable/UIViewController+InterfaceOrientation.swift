/*
 UIViewController+InterfaceOrientation.swift

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/**
 ViewController 支持的朝向控制

 使用：

 1. 设置 `UIViewController.defaultInterfaceOrientation` 以激活朝向控制；
 2. 在需要特殊朝向的页面设置 `interfaceOrientationFlag` 属性，可以在 Interface Builder 中直接设置；
 3. 如需强制转屏特性，需要在合适的地方调用 `forceRotationIfNeeded(viewController:)` 方法，可以通过导航去控制，推荐导航的 `navigationController(_, willShow:, animated:)` 代理方法；
 4. iPadOS 上不建议控制朝向，利用 UITraitCollection 适配才是正道；iPad 应用必需在设置中启用「Requires Full Screen」才能支持朝向控制（否则连 UIViewController 的 supportedInterfaceOrientations 都不会被调用），强制转屏在 iPad 上不可用。
 */
public struct InterfaceOrientationFlag: OptionSet {
    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// 使用全局默认值
    static let `default` = InterfaceOrientationFlag([])
    /// 支持竖屏
    static let portrait = InterfaceOrientationFlag(rawValue: 1 << 0)
    /// 支持横屏
    static let landscape = InterfaceOrientationFlag(rawValue: 1 << 1)
    /// 显示时如果屏幕方向是不支持的，强制转方向
    static let forceRotation = InterfaceOrientationFlag(rawValue: 1 << 2)
}

private var _defaultInterfaceOrientation: InterfaceOrientationFlag?
private let flagAssociation = AssociatedObject<InterfaceOrientationFlag>()

extension UIViewController {
    /**
     朝向全局设置，设置非空值启用朝向控制，传空禁用控制

     setter 必须在主线程调用，启用控制时值不能是 .default
     */
    public static var defaultInterfaceOrientation: InterfaceOrientationFlag? {
        get {
            _defaultInterfaceOrientation
        }
        set {
            dispatchPrecondition(condition: .onQueue(.main))
            if newValue != nil {
                // 启用控制
                if newValue == .default {
                    fatalError("启用屏幕旋转控制的默认值不能是 .default")
                }
                if _defaultInterfaceOrientation == nil {
                    swizzle(enable: true)
                }
            } else {
                // 禁用控制
                if _defaultInterfaceOrientation != nil {
                    swizzle(enable: false)
                }
            }
            _defaultInterfaceOrientation = newValue
        }
    }

    @IBInspectable private var _interfaceOrientation: Int {
        get {
            Int(interfaceOrientationFlag?.rawValue ?? 0)
        }
        set {
            let flag = InterfaceOrientationFlag(rawValue: UInt(newValue))
            interfaceOrientationFlag = flag
        }
    }

    /// 朝向设置
    ///
    /// .default 和空时应用全局设置
    public var interfaceOrientationFlag: InterfaceOrientationFlag? {
        get { flagAssociation[self] }
        set { flagAssociation[self] = newValue }
    }

    /// 判断设备朝向是否需要强制转换到给定 vc 的朝向，如果是则强转朝向
    public static func forceRotationIfNeeded(viewController: UIViewController) {
        guard let flag = viewController.interfaceOrientationFlag,
              flag.shouldForceRotation else { return }
        if viewController.traitCollection.userInterfaceIdiom == .pad {
            // iPad 上不支持强制设置方向，下面走了也无效果
            return
        }
        guard let vcWindow = (viewController.navigationController ?? AppNavigationController())?.view.window else {
            AppLog().warning("未找到 vc 所在窗体，跳过强制转屏")
            return
        }
        // 用 UIDevice.orientation 做判定是下策
        let isPortrait = vcWindow.screen.bounds.width < vcWindow.screen.bounds.height
        if isPortrait {
            if !flag.contains(.portrait) {
                UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }
        } else {
            if !flag.contains(.landscape) {
                UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }

    // MARK: -

    private static func swizzle(enable: Bool) {
        guard let origin = class_getInstanceMethod(self, #selector(getter: UIViewController.supportedInterfaceOrientations)),
              let replace = class_getInstanceMethod(self, #selector(_b9_supportedInterfaceOrientations)) else {
                  assert(false)
                  return
              }
        method_exchangeImplementations(origin, replace)
    }

    @objc private func _b9_supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let value = (interfaceOrientationFlag == .default ? nil : interfaceOrientationFlag)?.mask
            ?? Self.defaultInterfaceOrientation?.mask
            ?? _b9_supportedInterfaceOrientations()
        return value
    }
}

extension InterfaceOrientationFlag {
    /// 是否应当强制转屏，会检查 flag 中所有分量，仅当需要强制转屏且只支持同一方向时才返回 true
    var shouldForceRotation: Bool {
        contains(.forceRotation)
        && (contains(.landscape) || contains(.portrait))
        && !(contains(.landscape) && contains(.portrait))
    }

    var mask: UIInterfaceOrientationMask {
        var masks: UIInterfaceOrientationMask = [.all]
        if !contains(.portrait) {
            masks.remove([.portrait, .portraitUpsideDown])
        }
        if !contains(.landscape) {
            masks.remove(.landscape)
        }
        return masks
    }
}
