//
//  NavigationController.swift
//  App
//

import B9Condition

/**
 应用主导航控制器
 */
class NavigationController: MBNavigationController, StoryboardCreation, UIApplicationDelegate {
    static var storyboardID: StoryboardID { .main }

    override func onInit() {
        super.onInit()
        MBApp.status().globalNavigationController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 导航基类会在导航即将显示时把当前的样式作为默认样式，进入 app 时就显示 tab 但我们需要默认不显示 tab
        defaultAppearanceAttributes[.prefersBottomBarShownAttribute] = false
        _ = AppAPI()

        Account.addCurrentUserChangeObserver(self, initial: true) { [weak self] user in
            if user != nil {
                self?.onLogin()
            } else {
                self?.onLogout()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppCondition().set(off: [.navigationLoaded])
    }

    func onLogout() {
        presentLoginScene()
        releaseTabViewControllersIfNeeded()
    }

    func onLogin() {
        selectTab(.default)
    }

    override func presentLoginScene() {
        tabItems.selectIndex = NavigationTab.login
        setViewControllers([ WelcomeViewController.newFromStoryboard() ], animated: true)
    }

    override func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, willShow: viewController, animated: animated)
        viewController.attemptRotation(transitionCoordinator: transitionCoordinator)
    }

    override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)
        if viewController.prefersDisabledInteractivePopGesture {
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
        selectTab(.default)
    }
}
