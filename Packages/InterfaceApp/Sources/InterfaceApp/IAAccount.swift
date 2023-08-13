/*!
 IAAccount
 InterfaceApp

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import Foundation

/// 应用界面：账户
public protocol IAAccount: AnyObject {
    var id: String { get }
    /// 成为当前用户时执行的操作，总是在主线程执行
    func onLogin()
    /// 用户登出时执行的操作，总是在主线程执行
    func onLogout()
}
