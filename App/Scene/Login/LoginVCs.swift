//
//  LoginVCs.swift
//  App
//

import HasItem

// 登入相关页面的 IBAction 大都是通过响应链调用的，不能把它们标记成 private

/// 用于登入后移除导航中的登入页
@objc protocol LoginVCs {
}

/// 登入注册 vc 基类
class LoginFormBaseViewController: UIViewController, StoryboardCreation, LoginVCs {
    static var storyboardID: StoryboardID { .login }

    /// 发送验证码相关的信息
    /// 返回 nil 不执行发送
    /// 因为 onSendCode() action 形式太固定了，抽出一层避免反复写同样的逻辑
    func sendCodeContext() -> (apiName: String, requestParameters: [String: Any], sendCodeButton: MBCodeSendButton?)? {
        // swiftlint:disable:previous unavailable_function
        fatalError("需子类重载")
    }

    @IBAction func onSendCode(_ sender: Any) {
        guard let context = sendCodeContext() else { return }
        let codeButton = context.sendCodeButton
        codeButton?.markSending(message: nil)
        API.requestName(context.apiName) { c in
            c.parameters = context.requestParameters
            c.loadMessage = ""
            c.groupIdentifier = apiGroupIdentifier
            c.success { [weak codeButton] _, _ in
                codeButton?.froze()
            }
            c.finished { [weak codeButton] _, success in
                if !success {
                    codeButton?.isEnabled = true
                }
            }
        }
    }
}

/**
 未登入用户欢迎页
 */
class WelcomeViewController: LoginFormBaseViewController {
    private var form: LoginMobileVerifyCodeScene {
        MBSwift.cast(children.first, as: LoginMobileVerifyCodeScene.self)
    }

    override func sendCodeContext() -> (apiName: String, requestParameters: [String: Any], sendCodeButton: MBCodeSendButton?)? {
        guard let mobile = form.mobileField?.vaildFieldText() else {
            return nil
        }
        return ("SignInUpSend", ["mobile": mobile], form.sendCodeButton)
    }

    @IBAction func onSubmit(_ sender: Any) {
        guard let mobile = form.mobileField?.vaildFieldText(),
            let code = form.codeField.vaildFieldText() else {
                return
        }
        dismissKeyboard()
        API.requestName("SignInUp") { c in
            c.parameters = ["mobile": mobile, "code": code]
            c.loadMessage = ""
            c.loadMessageShownModal = true
            c.groupIdentifier = apiGroupIdentifier
            c.bindControls = [form.submitButton as Any]
            c.success { _, rsp in
                guard let item = rsp as? LoginResponseEntity else { fatalError() }
                item.setAsCurrent()
            }
        }
    }
}

/**
 密码登入
 */
class LoginPasswordViewController: LoginFormBaseViewController {
    private var form: LoginSigninFormScene {
        MBSwift.cast(children.first, as: LoginSigninFormScene.self)
    }

    @IBAction func onSubmit(_ sender: Any) {
        guard let name = form.nameField?.vaildFieldText(),
            let password = form.passwordField.vaildFieldText() else {
                return
        }
        dismissKeyboard()
        API.requestName("LoginPassword") { c in
            c.parameters = ["name": name, "password": password]
            c.loadMessage = ""
            c.loadMessageShownModal = true
            c.groupIdentifier = apiGroupIdentifier
            c.bindControls = [form.submitButton as Any]
            c.success { _, rsp in
                guard let item = rsp as? LoginResponseEntity else { fatalError() }
                item.setAsCurrent()
            }
        }
    }
}

/**
 注册页
 */
class LoginRegisterViewController: LoginFormBaseViewController {
    var form: LoginRegisterFormScene {
        MBSwift.cast(children.first, as: LoginRegisterFormScene.self)
    }

    override func sendCodeContext() -> (apiName: String, requestParameters: [String: Any], sendCodeButton: MBCodeSendButton?)? {
        var parameters = [String: Any]()
        if form.isEmailButton.isSelected {
            guard let email = form.emailField?.vaildFieldText() else {
                return nil
            }
            parameters["email"] = email
        } else {
            guard let mobile = form.mobileField?.vaildFieldText() else {
                return nil
            }
            parameters["mobile"] = mobile
        }
        return ("RegisterCode", parameters, form.sendCodeButton)
    }

    @IBAction func onSubmit(_ sender: Any) {
        guard let parameters = submitRequestParameters() else {
            return
        }
        dismissKeyboard()
        API.requestName("LoginPassword") { c in
            c.parameters = parameters
            c.loadMessage = "注册中"
            c.loadMessageShownModal = true
            c.groupIdentifier = apiGroupIdentifier
            c.bindControls = [form.submitButton as Any]
            c.success { _, rsp in
                guard let item = rsp as? LoginResponseEntity else { fatalError() }
                item.setAsCurrent()
            }
        }
    }
    /// 准备注册请求用的参数
    /// 返回 nil 意味着字段输入不合法
    private func submitRequestParameters() -> [String: Any]? {
        let isEmail = form.isEmailButton.isSelected
        var parameters = [String: Any]()
        if isEmail {
            guard let email = form.emailField?.vaildFieldText() else {
                return nil
            }
            parameters["email"] = email
        } else {
            guard let mobile = form.mobileField?.vaildFieldText() else {
                return nil
            }
            parameters["mobile"] = mobile
        }
        guard let code = form.codeField?.vaildFieldText(),
            let password = form.passwordField2.vaildFieldText() else {
                return nil
        }
        parameters["code"] = code
        parameters["password"] = password
        return parameters
    }
}

/**
 通过手机找回密码验证
 */
class PasswordResetMobileViewController: LoginFormBaseViewController {
    var form: LoginMobileVerifyCodeScene {
        MBSwift.cast(children.first, as: LoginMobileVerifyCodeScene.self)
    }

    override func sendCodeContext() -> (apiName: String, requestParameters: [String: Any], sendCodeButton: MBCodeSendButton?)? {
        guard let mobile = form.mobileField?.vaildFieldText() else {
            return nil
        }
        return ("OTACSend", ["mobile": mobile], form.sendCodeButton)
    }

    @IBAction func onSubmit(_ sender: Any) {
        guard let mobile = form.mobileField?.vaildFieldText(),
            let code = form.codeField.vaildFieldText() else {
                return
        }
        dismissKeyboard()
        API.requestName("OTACVerify") { c in
            c.parameters = ["mobile": mobile, "code": code]
            c.loadMessage = ""
            c.groupIdentifier = apiGroupIdentifier
            c.bindControls = [form.submitButton as Any]
            c.success { [weak self] _, rsp in
                guard let sf = self else { return }
                guard let info = rsp as? [String: String],
                    let token = info["ot_token"] else {
                        AppHUD().showErrorStatus("服务器返回异常")
                        return
                }
                sf.otToken = token
                sf.performSegue(withIdentifier: "NEXT", sender: sf)
            }
        }
    }

    private var otToken: String?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 通过 HasItem 传值
        if var vc = segue.destination as? AnyHasItem {
            vc.setItem(otToken)
        }
    }
}

/**
 密码找回，设置新密码
 */
class PasswordResetViewController: LoginFormBaseViewController, HasItem {
    var form: LoginPasswordSetScene {
        MBSwift.cast(children.first, as: LoginPasswordSetScene.self)
    }

    /// ot_token
    @objc var item: String!

    @IBAction func onSubmit(_ sender: Any) {
        guard let token = item else {
            AppHUD().showErrorStatus("内部参数异常")
            return
        }
        guard let password = form.passwordField.vaildFieldText() else {
            return
        }
        dismissKeyboard()
        API.requestName("PasswordReset") { c in
            c.parameters = ["ot_token": token, "password": password]
            c.loadMessage = ""
            c.loadMessageShownModal = true
            c.groupIdentifier = apiGroupIdentifier
            c.bindControls = [form.submitButton as Any]
            c.success { _, _ in
                AppHUD().showSuccessStatus("密码已重置")
                AppNavigationController()?.popToRootViewController(animated: true)
            }
        }
    }
}

#if DEBUG
import Debugger
extension WelcomeViewController: DebugActionSource {
    func debugActionItems() -> [DebugActionItem] {
        [
            DebugActionItem("测试用户") {
                let user = Account(id: Account.userIDUndetermined)
                user?.token = "token"
                Account.current = user
            }
        ]
    }
}

extension PasswordResetViewController: DebugActionSource {
    func debugActionItems() -> [DebugActionItem] {
        [
            DebugActionItem("填入12345678") { [self] in
                form.passwordField.text = "12345678"
                form.passwordField2.text = "12345678"
                form.submitButton.isEnabled = true
            }
        ]
    }
}
#endif
