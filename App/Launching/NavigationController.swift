//
//  NavigationController.swift
//  App
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
        // 强制设置一些初始状态，否则会有异常
        defaultAppearanceAttributes[.prefersBottomBarShownAttribute] = 0
        bottomBarHidden = true
        AppAPI()

        Account.addCurrentUserChangeObserver(self, initial: true) { [weak self] user in
            if user != nil {
                self?.onLogin()
            } else {
                self?.onLogout()
            }
        }
    }

    func onLogout() {
        presentLoginScene()
        releaseTabViewControllersIfNeeded()
    }

    func onLogin() {
        selectTab(.defaule)
    }

    override func presentLoginScene() {
        tabItems.selectIndex = NavigationTab.login
        setViewControllers([ WelcomeViewController.newFromStoryboard() ], animated: true)
    }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        releaseTabViewControllersIfNeeded()
    }
}

// MARK: - Jump
extension NavigationController {
    @IBAction private func navigationBackToHome(_ sender: Any?) {
        selectTab(.defaule)
    }
}
