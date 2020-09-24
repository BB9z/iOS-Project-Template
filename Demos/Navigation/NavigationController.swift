//
//  NavigationController.swift
//  Navigation
//

/**
 应用主导航控制器
 */
class NavigationController: MBNavigationController {
    override class func storyboardName() -> String { "Main" }

    override func onInit() {
        super.onInit()
        MBApp.status().globalNavigationController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - 页面声明的行为、样式控制

    override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)

        if viewController.rfPrefersDisabledInteractivePopGesture {
            // 禁用返回手势，只禁用就行，会自行恢复
            interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    override func updateNavigationAppearance(appearanceAttributes attributes: [RFViewControllerAppearanceAttributeKey: Any] = [:], animationDuration: TimeInterval, animated: Bool) {
        super.updateNavigationAppearance(appearanceAttributes: attributes, animationDuration: animationDuration, animated: animated)
        if let boolValue = attributes[RFViewControllerAppearanceAttributeKey.pefersTransparentBar] as? NSNumber,
            boolValue.boolValue {
            navigationBar.isTranslucent = true
            navigationBar.setBackgroundImage(UIImage(named: "blank"), for: .default)
        } else if navigationBar.isTranslucent {
            navigationBar.isTranslucent = false
        }
    }
}

// MARK: - Router

extension NavigationController {
    @objc class func jump(url: URL, context: Any?) {
        precondition(false, "Demo 不需要路由")
    }
}
