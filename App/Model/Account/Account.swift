//
//  Account.swift
//  App
//

import B9Condition

/**
 管理当前用户
 */
class Account: MBUser {
    // 有的项目登入时只返回认证信息，没有用户 ID，这时候需要用 userIDUndetermined 创建 Account 对象
    #if MBUserStringUID
    static let userIDUndetermined = "<undetermined>"
    #else
    static let userIDUndetermined = INT64_MAX
    #endif

    // MARK: - 状态

    override var description: String {
        "<Account \(ObjectIdentifier(self)): uid = \(uid), information: \(information.description), pofileFetched?: \(hasPofileFetchedThisSession)>"
    }

    /**
     用户基本信息

     不为空，操作上可以便捷一些
     */
    @objc var information: AccountEntity {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }

            if let ret = _information { return ret }
            var account = AppUserDefaultsShared().accountEntity
            if account == nil {
                AppUserDefaultsShared().accountEntity = nil
                account = AccountEntity()
            }
            _information = account
            return account!
        }
        set {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }

            _information = newValue

            #if MBUserStringUID
            let uidChanged = newValue.uid.length > 0 && uid != newValue.uid as String
            #else
            let uidChanged = newValue.uid > 0 && uid != newValue.uid
            #endif
            if uidChanged {
                if uid != Account.userIDUndetermined {
                    AppLog().critical("用户信息 ID 不匹配")
                }
                setValue(information.uid, forKeyPath: #keyPath(MBUser.uid))
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
        AppUserDefaultsShared().lastUserID = uid
        AppUserDefaultsShared().accountEntity = information
    }

    var token: String?

    var hasPofileFetchedThisSession = false

    // MARK: - 挂载

    private(set) lazy var profile: AccountDefaults? = {
        let suitName = ("User\(uid)" as NSString).rf_MD5
        return AccountDefaults(suiteName: suitName)
    }()

    // MARK: - 流程

    /// 应用启动后初始流程
    class func setup() {
        precondition(AppUser() == nil, "应用初始化时应该还未设置当前用户")
        #if MBUserStringUID
        guard let userID = AppUserDefaultsShared().lastUserID else { return }
        #else
        let userID = AppUserDefaultsShared().lastUserID
        guard userID > 0 else { return }
        #endif
        guard let token = AppUserDefaultsShared().userToken else {
            AppLog().critical("Account has ID but no token")
            return
        }

        guard let user = Account(id: userID) else { fatalError() }
        user.token = token
        current = user
        user.updateInformation { c in
            c.failureCallback = APISlientFailureHandler(true)
        }
    }

    override class func onCurrentUserChanged(_ currentUser: MBUser?) {
        let user = currentUser as? Account
        let defaults = AppUserDefaultsShared()
        #if MBUserStringUID
        defaults.lastUserID = user?.uid
        #else
        defaults.lastUserID = user?.uid ?? 0
        #endif
        defaults.userToken = user?.token
        defaults.accountEntity = user?.information
        if !defaults.synchronize() {
            // 实际项目遇到过 UserDefaults 无法存储的 bug，需要用户重启设备才行
            // 处理方式可以参考： https://github.com/BB9z/iOS-Project-Template/blob/4.1/App/Model/Account/Account.swift#L123-L127
            NSLog("⚠️ 用户信息存储失败")
        }
    }

    override func onLogin() {
        guard let token = token else { fatalError() }
        debugPrint("当前用户 ID: \(uid), token: \(token)")
        AppAPI().defineManager.authorizationHeader[authHeaderKey] = "Bearer \(token)"
        AppCondition().set(on: [ApplicationCondition.userHasLogged])
        if !hasPofileFetchedThisSession {
            updateInformation { c in
                c.failureCallback = APISlientFailureHandler(true)
            }
        }
    }
    override func onLogout() {
        AppCondition().set(off: [.userHasLogged, .userInfoFetched])
        AppAPI().defineManager.authorizationHeader.removeObject(forKey: authHeaderKey)
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
