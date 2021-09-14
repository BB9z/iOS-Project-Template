//
//  LoginForms.swift
//  App
//

/*
 登录注册相关的表单

 为什么像这样组织？

   表单用 table view controller 实现主要有两个好处：
   1. 输入框滚动避开键盘的处理系统会自动提供，而且滚动的位置是以 cell 为准的，显示更合适，这比三方库好用；
   2. 便于项目内或跨项目复用 UI，静态 cell 搭建界面本身就很方便，以 cell 为单位更便于复制。

   缺点主要是当有 UI 元素需要固定不随整体滚动，需要用另一个 view controller 做嵌套。
   另一种比较好的组织方式是 scroll view + stack view，复用也方便，但是键盘处理得额外做。

   我之前多年的习惯是直接用 UITableViewController，当布局有需要时再套 view controller；
   最近的项目把表单统一做成需要嵌入的，虽然层数上冗余了，但代码的组织更清晰、复用更简便了。
 */

/// 用户名+密码登入表单
internal class LoginSigninFormScene: UITableViewController {
    @IBOutlet weak var nameField: TextField!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var submitButton: UIButton!
}

/// 手机号和验证码输入表单
internal class LoginMobileVerifyCodeScene: UITableViewController {
    @IBOutlet weak var mobileField: TextField!
    @IBOutlet weak var codeField: TextField!
    @IBOutlet weak var sendCodeButton: MBCodeSendButton!
    @IBOutlet weak var submitButton: UIButton!
}

/// 手机号和验证码发送表单
internal class LoginMobileSendCodeFormScene: UITableViewController {
    @IBOutlet weak var mobileField: TextField!
    @IBOutlet weak var submitButton: UIButton!
}

/// 注册表单
internal class LoginRegisterFormScene: UITableViewController {
    @IBOutlet weak var mobileField: TextField?
    @IBOutlet weak var emailField: TextField?
    @IBOutlet weak var isEmailButton: UIButton!
    @IBOutlet weak var codeField: TextField?
    @IBOutlet weak var sendCodeButton: MBCodeSendButton?
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var passwordField2: TextField!
    @IBOutlet weak var submitButton: UIButton!

    @IBAction private func onChangeIsEmail(_ sender: Any) {
        updateUI(isEmail: !isEmailButton.isSelected)
    }

    func updateUI(isEmail: Bool) {
        isEmailButton.isSelected = isEmail
        tableView.reloadSections(IndexSet(integer: userIDSection), with: .automatic)
    }

    // 静态 UITableViewController 也可做 cell 的动态显隐
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == userIDSection {
            return 1
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == userIDSection {
            return isEmailButton.isSelected ? emailCell : mobileCell
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    private let userIDSection = 1
    @IBOutlet weak var mobileCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
}

/// 密码重置表单（通过手机）
internal class LoginPasswordResetFormScene: UITableViewController {
    @IBOutlet weak var mobileField: TextField!
    @IBOutlet weak var codeField: TextField!
    @IBOutlet weak var sendCodeButton: MBCodeSendButton!
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var passwordField2: TextField!
    @IBOutlet weak var submitButton: UIButton!
}

/// 密码设置表单
internal class LoginPasswordSetScene: UITableViewController {
    @IBOutlet weak var passwordField: TextField!
    @IBOutlet weak var passwordField2: TextField!
    @IBOutlet weak var submitButton: UIButton!
}
