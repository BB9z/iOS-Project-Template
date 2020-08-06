//
//  DemoVCs.swift
//  GuestMode
//

/**
 演示首页
 */
class HomeViewController: UIViewController {
    override class func storyboardName() -> String { "Main" }

    override func viewDidLoad() {
        super.viewDidLoad()
        Account.addCurrentUserChangeObserver(self, initial: true) { [weak self] user in
            guard let sf = self else { return }
            sf.logoutButton.isHidden = user == nil
            sf.loginStateLabel.text = user == nil ? "未登入" : "已登入: \(AppUserInformation()?.name ?? "-")"
        }
    }

    @IBOutlet private weak var loginStateLabel: UILabel!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBAction private func onLogout(_ sender: Any) {
        Account.current = nil
    }

    @IBAction private func demoActionNeedsLogin(_ sender: Any) {
        // 未登入弹出登入页并返回，登入后不恢复操作
        // 因为回来还是之前的页面，让用户重新点一下就好了
        if MBOperationLoginRequired() { return }

        let alert = UIAlertController(title: "执行操作", message: "仅当用户已登入", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        rfPresent(alert, animated: true, completion: nil)
    }
}

/**
 需要登入可见的页面
 */
class PrivateViewController: UIViewController {
    override class func storyboardName() -> String { "Main" }
    // 是否需要登入可见在 Interface Builder 中设置 MBUserLoginRequired
}

/**
 游客也可见的页面
 */
class PublicViewController: UIViewController {
    override class func storyboardName() -> String { "Main" }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 展示用户切换的处理
        // 如果游客和用户看到的是完全不同的页面，可以通过嵌入不同的 vc 来实现
        if isNeedsReloadAsUserChanged {
            refresh()
            updateLastUserID()
        }
    }

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var resultLabel: UILabel!
    func refresh() {
        loadingIndicator.startAnimating()
        contentView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let sf = self else { return }
            sf.loadingIndicator.stopAnimating()
            sf.contentView.isHidden = false
            sf.resultLabel.text = AppUser() == nil ? "现在展示的是游客可见的内容" : "现在展示的是\(AppUserInformation()?.name ?? "用户")可见的内容"
        }
    }
}

/**
 演示登入页
 */
class LoginViewController: UIViewController, LoginVCs {
    override class func storyboardName() -> String { "Main" }

    /// 便于用户切换时区分
    static var demoUserName: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // 业务上可能需要登入页面从底部弹出以示区别，可以通过转场样式模拟
        rfTransitioningStyle = "RFMoveInFromBottomTransitioning"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        restoreJumpContainer.isHidden = AppNavigationController()?.loginSuspendedViewController == nil
    }
    @IBOutlet private weak var restoreJumpContainer: UIView!
    @IBOutlet private weak var restoreJumpSwitch: UISwitch!

    @IBAction private func demoLogin(_ sender: Any) {
        if !restoreJumpSwitch.isOn {
            AppNavigationController()?.loginSuspendedViewController = nil
        }
        let information = AccountEntity()
        information.name = Self.demoUserName ?? "默认用户"
        let user = Account(id: Account.userIDUndetermined)!
        user.information = information
        user.token = "demo token"
        Account.current = user
    }
}

/**
 更深层的登入相关页面，如注册
 */
class LoginStep2ViewController: UIViewController, LoginVCs {
    @IBAction private func demoLogin(_ sender: Any) {
        let user = Account(id: Account.userIDUndetermined)!
        user.token = "demo token"
        Account.current = user
    }
}

/// 用于登入后移除导航中的多个登入页
@objc protocol LoginVCs {
}


/**
 用户切换工具页
 */
class LoginSwitchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        Account.addCurrentUserChangeObserver(self, initial: true) { [weak self] user in
            guard let sf = self else { return }
            let isLogin = user != nil
            sf.logoutButton.isHidden = !isLogin
            sf.loginButtons.views(hidden: isLogin)
        }
    }

    @IBOutlet private var loginButtons: [UIButton]!
    @IBOutlet private weak var logoutButton: UIButton!
    @IBAction private func demoLoginAsUserA(_ sender: Any) {
        LoginViewController.demoUserName = "用户 A"
        AppNavigationController()?.presentLoginScene()
    }
    @IBAction private func demoLoginAsUserB(_ sender: Any) {
        LoginViewController.demoUserName = "用户 B"
        AppNavigationController()?.presentLoginScene()
    }
    @IBAction private func onLogout(_ sender: Any) {
        Account.current = nil
    }
}
