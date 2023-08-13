//
//  Account.swift
//  App
//

import AppFramework
import B9Condition
import InterfaceApp

/**
 管理当前用户
 */
class Account: IAAccount {

    // 有的项目登入时只返回认证信息，没有用户 ID，这时候需要用 userIDUndetermined 创建 Account 对象
    static let userIDUndetermined = "<undetermined>"

    init(id: String) {
        self.id = id
    }

    // MARK: - 状态

    /**
     用户基本信息

     不为空，操作上可以便捷一些
     */
    @objc var information: AccountEntity {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }

            if let ret = _information { return ret }
            var account = Current.defualts.accountEntity
            if account == nil {
                Current.defualts.accountEntity = nil
                account = AccountEntity()
            }
            _information = account
            return account!
        }
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }

            _information = newValue

            let uidChanged = newValue.uid.isNotEmpty && id != newValue.uid
            if uidChanged {
                if id != Account.userIDUndetermined {
                    AppLog().critical("用户信息 ID 不匹配")
                }
                id = information.uid
            }

            // 开始对接口/数据源取回的数据处理
            // 原则是保留能从用户信息接口获取的字段
            // 如果是登录接口附加的信息则移动到 Account 上

            persistentInfomationToStore()
        }
    }
    private var _information: AccountEntity?
    private func persistentInfomationToStore() {
        guard isCurrent else { return }
        Current.defualts.lastUserID = id
        Current.defualts.accountEntity = information
    }

    private(set) var id: String
    var token: String?

    var hasPofileFetchedThisSession = false

    // MARK: - 挂载

    private(set) lazy var profile: AccountDefaults? = {
        let suitName = B9Crypto.md5(utf8: "User\(id)") ?? id
        return AccountDefaults(suiteName: suitName)
    }()

    // MARK: - 流程

    /// 应用启动后初始流程
    class func setup() {
        precondition(Current.account == nil, "应用初始化时应该还未设置当前用户")
        guard let userID = Current.defualts.lastUserID else { return }
        guard let token = Current.defualts.userToken else {
            AppLog().critical("Account has ID but no token")
            return
        }

        let user = Account(id: userID)
        user.token = token
        AccountManager.current = user
        user.updateInformation { c in
            c.failureCallback = APISlientFailureHandler(true)
        }
    }

    func didLogin() {
        guard let token = token else { fatalError() }
        debugPrint("当前用户 ID: \(id), token: \(token)")
        Current.api.defineManager.authorizationHeader[authHeaderKey] = "Bearer \(token)"
        let defaults = Current.defualts
        defaults.lastUserID = id
        defaults.userToken = token
        defaults.accountEntity = information
        AppCondition().set(on: [ApplicationCondition.userHasLogged])
        if !hasPofileFetchedThisSession {
            updateInformation { c in
                c.failureCallback = APISlientFailureHandler(true)
            }
        }
    }
    func didLogout() {
        AppCondition().set(off: [.userHasLogged, .userInfoFetched])
        let defaults = Current.defualts
        defaults.lastUserID = nil
        defaults.userToken = nil
        defaults.accountEntity = nil
        Current.api.defineManager.authorizationHeader.removeObject(forKey: authHeaderKey)
        profile?.synchronize()
    }
    // 🔰 修改认证头字段名
    private var authHeaderKey: String { "Authorization" }

    /// 更新账号用户信息
    func updateInformation(requestContext context: (RFAPIRequestConext) -> Void) {
        API.requestName("AcoountInfo") { c in
            context(c)
            let inputSuccessCallback = c.successCallback
            c.success { [self] task, rsp in
                guard let info = rsp as? AccountEntity else { fatalError() }
                if let cb = inputSuccessCallback {
                    cb(task, rsp)
                }
                hasPofileFetchedThisSession = true
                information = info
                if isCurrent {
                    AppCondition().set(off: [.userInfoFetched])
                }
            }
        }
    }
}

extension Account: CustomDebugStringConvertible {
    var debugDescription: String {
        "<Account \(ObjectIdentifier(self)): id = \(id), information: \(information.description), pofileFetched?: \(hasPofileFetchedThisSession)>"
    }
}
