//
//  Account.swift
//  GuestMode
//

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
        "<Account \(ObjectIdentifier(self)): uid = \(uid), information: \(information.description)>"
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

            persistentInformationToStore()
        }
    }
    private var _information: AccountEntity?
    private func persistentInformationToStore() {
        guard isCurrent else { return }
        AppUserDefaultsShared().lastUserID = uid
        AppUserDefaultsShared().accountEntity = information
    }

    var token: String?

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
        let userID = AppUserDefaultsShared().lastUserID ?? 0
        guard userID > 0 else { return }
        #endif
        guard let token = AppUserDefaultsShared().userToken else {
            AppLog().critical("Account has ID but no token")
            return
        }

        guard let user = Account(id: userID) else { fatalError() }
        user.token = token
        self.current = user
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
    }

    override func onLogin() {
        debugPrint("当前用户 ID: \(uid), token: \(token ?? "null")")
    }
    override func onLogout() {
        profile?.synchronize()
    }
}
