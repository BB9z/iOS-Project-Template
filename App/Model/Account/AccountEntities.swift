//
//  AccountEntities.swift
//  App
//

/**
 用户账户信息 model

 https://bb9z.github.io/API-Documentation-Sample/Sample/Entity#AccountEntity
*/
@objc(AccountEntity)
class AccountEntity: MBModel {
    @objc var uid: MBIdentifier = ""
    @objc var name: String?
    @objc var introduction: String?
    @objc var avatar: String?
    @objc var sex: NSNumber?

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper(modelToJSONDictionary: [#keyPath(AccountEntity.uid): "id"])
    }
}

/**
 用户登入时带 token 的结构

 https://bb9z.github.io/API-Documentation-Sample/Sample/Account#SignInUp
 */
@objc(LoginResponseEntity)
class LoginResponseEntity: MBModel {
    @objc var info: AccountEntity?
    @objc var token: String?
    @objc var isNew: NSNumber?

    /// 收到服务器登入信息，设置当前用户
    func setAsCurrent() {
        guard let info = info, let token = token else {
            AppHUD().showErrorStatus("服务器返回信息缺失")
            return
        }
        let user = Account(id: info.uid as String)
        user?.token = token
        Account.current = user
    }

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper.forSnakeCase()
    }
}
