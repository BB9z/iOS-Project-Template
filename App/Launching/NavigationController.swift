//
//  NavigationController.swift
//  App
//

private enum NavigationTab: Int {
    case home = 0, topic, more, count
    static let defaule = NavigationTab.home
    static let login = NSNotFound
}

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
        tabControllers.count = 0
        tabControllers.count = NavigationTab.count.rawValue
    }

    func onLogin() {
        tabItems?.selectIndex = NavigationTab.defaule.rawValue
        onTabSelect(tabItems!)
    }

    override func presentLoginScene() {
        tabItems?.selectIndex = NavigationTab.login
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

    // MARK: -

    var tabItems: MBControlGroup? {
        bottomBar as? MBControlGroup
    }

    lazy var tabControllers: NSPointerArray = {
        let array = NSPointerArray(options: .strongMemory)
        array.count = NavigationTab.count.rawValue
        return array
    }()
}

// MARK: - Tab

extension NavigationController: MBControlGroupDelegate {
    func controlGroup(_ controlGroup: MBControlGroup, shouldSelectControlAt index: Int) -> Bool {
        return true
    }

    @IBAction private func onTabSelect(_ sender: MBControlGroup) {
        let vc: UIViewController = viewControllerAtTabIndex(sender.selectIndex)
        let newVCs = [ vc ]
        if viewControllers != newVCs {
            viewControllers = newVCs
        }
    }

    func viewControllerAtTabIndex(_ index: Int) -> UIViewController {
        if let vc = tabControllers.object(at: index) as? UIViewController {
            return vc
        }
        var vc: UIViewController!
        switch NavigationTab(rawValue: index) {
        case .home:
            vc = HomeViewController.newFromStoryboard()
        case .topic:
            vc = TopicRecommandListController.newFromStoryboard()
        case .more:
            vc = MoreViewController.newFromStoryboard()
        case .some(.count), .none:
            fatalError()
        }
        vc.rfPrefersBottomBarShown = true
        tabControllers.replaceObject(at: index, withObject: vc)
        return vc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        let idx = tabItems?.selectIndex
        for i in 0..<tabControllers.count where i != idx {
            tabControllers.replacePointer(at: i, withPointer: nil)
        }
    }
}

extension NavigationController: MBDebugNavigationReleaseChecking {
    func debugShouldIgnoralCheckRelease(for viewController: UIViewController!) -> Bool {
        return (tabControllers.allObjects as NSArray).contains(viewController!)
    }
}

// MARK: - Jump
extension NavigationController {
    @IBAction private func navigationBackToHome(_ sender: Any?) {
        tabItems?.selectIndex = NavigationTab.defaule.rawValue
        onTabSelect(tabItems!)
    }
}
