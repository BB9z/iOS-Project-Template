/*
 UIViewController+Appearance.swift

 Copyright © 2016-2018, 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 在 Interface Builder 中直接控制 vc 相关样式
 */
extension UIViewController: RFNavigationBehaving {
    /// 状态栏浅色文字？
    @IBInspectable var prefersLightContentBarStyle: Bool {
        get { lightContentBarAssociation[self] ?? false }
        set { lightContentBarAssociation[self] = newValue }
    }

    /// 隐藏导航栏？
    @IBInspectable var prefersNavigationBarHidden: Bool {
        get { navigationBarHiddenAssociation[self] ?? false }
        set { navigationBarHiddenAssociation[self] = newValue }
    }

    /// 导航栏颜色
    @IBInspectable var preferredNavigationBarColor: UIColor? {
        get { navigationBarColorAssociation[self] }
        set { navigationBarColorAssociation[self] = newValue }
    }

    /// 需要显示底部 tab？
    @IBInspectable var prefersBottomBarShown: Bool {
        get { bottomBarShownAssociation[self] ?? false }
        set { bottomBarShownAssociation[self] = newValue }
    }

    /// 阻止侧滑返回手势
    @IBInspectable var prefersDisabledInteractivePopGesture: Bool {
        get { disabledInteractivePopGestureAssociation[self] ?? false }
        set { disabledInteractivePopGestureAssociation[self] = newValue }
    }

    /// 透明导航
    @IBInspectable var pefersTransparentBar: Bool {
        get { transparentBarAssociation[self] ?? false }
        set { transparentBarAssociation[self] = newValue }
    }

    public func rfNavigationAppearanceAttributes() -> [RFViewControllerAppearanceAttributeKey: Any]? {
        var dic = [RFViewControllerAppearanceAttributeKey: Any]()
        if let value = navigationBarHiddenAssociation[self] {
            dic[.prefersNavigationBarHiddenAttribute] = value
        }
        if let value = bottomBarShownAssociation[self] {
            dic[.prefersBottomBarShownAttribute] = value
        }
        if let value = transparentBarAssociation[self] {
            dic[.pefersTransparentBar] = value
        }
        if let value = navigationBarColorAssociation[self] {
            dic[.preferredNavigationBarTintColorAttribute] = value
        }
        if prefersLightContentBarStyle {
            dic[.preferredNavigationBarItemColorAttribute] = UIColor.white
            dic[.preferredNavigationBarTitleTextAttributes] = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        return dic
    }
}

private let lightContentBarAssociation = AssociatedObject<Bool>()
private let navigationBarHiddenAssociation = AssociatedObject<Bool>()
private let navigationBarColorAssociation = AssociatedObject<UIColor>()
private let bottomBarShownAssociation = AssociatedObject<Bool>()
private let disabledInteractivePopGestureAssociation = AssociatedObject<Bool>()
private let transparentBarAssociation = AssociatedObject<Bool>()

extension RFViewControllerAppearanceAttributeKey {
    static let pefersTransparentBar = RFViewControllerAppearanceAttributeKey(rawValue: "pefersTransparentBar")
}
