//
//  DemoVCs.swift
//  GuestMode
//
//  Created by BB9z on 2020/8/3.
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
            sf.loginStateLabel.text = user == nil ? "未登入" : "已登入"
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
}

/**
 演示登入页
 */
class LoginViewController: UIViewController, LoginVCs {
    override class func storyboardName() -> String { "Main" }

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
        let user = Account(id: Account.userIDUndetermined)!
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
