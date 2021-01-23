//
//  NavigationController.swift
//  GuestMode
//

private enum NavigationTab: Int {
    case home = 0, tabNeedsLogin, tabAllowGuest, count
    static let defaule = NavigationTab.home
    static let login = NSNotFound
}

/**
 应用主导航控制器
 */
class NavigationController: MBNavigationController {
    override class func storyboardName() -> String { "GuestMode" }

    override func onInit() {
        super.onInit()
        MBApp.status().globalNavigationController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 强制设置一些初始状态，否则会有异常

        tabItems?.selectIndex = NavigationTab.defaule.rawValue
        onTabSelect(tabItems!)
        Account.addCurrentUserChangeObserver(self, initial: false) { [weak self] user in
            if user != nil {
                self?.onLogin()
            } else {
                self?.onLogout()
            }
        }
    }

    // MARK: - 登入/登出控制

    func onLogout() {
        changeNavigationStack { _ in
            if self.visibleViewController?.mbUserLoginRequired == true {
                self.presentLoginScene()
            }
        }
    }

    func onLogin() {
        // 如果登入相关页面不涉及多个页面，直接 pop 登入页即可
        if let vc = loginSuspendedViewController {
            replaceViewControllers(ofScence: LoginVCs.self, with: vc, animated: true)
        }
        else {
            popViewControllers(ofScence: LoginVCs.self, animated: true)
        }
    }

    override func presentLoginScene() {
        precondition(AppUser() == nil)
        let vc = LoginViewController.newFromStoryboard()
        pushViewController(vc, animated: true)
    }

    @discardableResult override func popViewController(animated: Bool) -> UIViewController? {
        guard let topVC = topViewController else {
            return super.popViewController(animated: animated)
        }
        func isLoginVC(_ vc: UIViewController?) -> Bool {
            return vc?.conforms(to: LoginVCs.self) == true
        }
        if AppUser() == nil
            && isLoginVC(topVC)
            && !isLoginVC(previousViewController) {
            // 弹出界面（可能是登入界面），返回后需要登入、强制重设导航
            // 这里前置条件是默认页面无需登入即可浏览
            let hasNeedsLoginVC = viewControllers.contains { $0.mbUserLoginRequired }
            if hasNeedsLoginVC {
                let rootVC: UIViewController = viewControllerAtTabIndex(NavigationTab.defaule.rawValue)
                setViewControllers([rootVC, topVC], animated: false)
                tabItems?.selectIndex = NavigationTab.defaule.rawValue
            }
        }
        return super.popViewController(animated: animated)
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

    // tab 切换阻止未登入时切换到需要登入的页面
    func controlGroup(_ controlGroup: MBControlGroup, shouldSelectControlAt index: Int) -> Bool {
        if AppUser() == nil {
            let vc: UIViewController = viewControllerAtTabIndex(index)
            if vc.mbUserLoginRequired {
                presentLoginScene()
                return false
            }
        }
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
        case .tabNeedsLogin:
            vc = PrivateViewController.newFromStoryboard()
        case .tabAllowGuest:
            vc = PublicViewController.newFromStoryboard()
        case .count, .none:
            fatalError()
        }
        vc.rfPrefersBottomBarShown = true
        tabControllers.replaceObject(at: index, withObject: vc)
        return vc
    }
}

// MARK: - Router

extension NavigationController {
    @objc class func jump(url: URL, context: Any?) {
        precondition(false, "Demo 不需要路由")
    }
}
