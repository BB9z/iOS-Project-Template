//
//  AccountEntities.swift
//  App
//

import AppFramework

/**
 用户账户信息 model

 https://bb9z.github.io/API-Documentation-Sample/Sample/Entity#AccountEntity
*/
@objc(AccountEntity)
@objcMembers
class AccountEntity: MBModel {
    var uid: MBIdentifier = ""
    var name: String?
    var introduction: String?
    var avatar: String?
    var sex: NSNumber?

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper(modelToJSONDictionary: [#keyPath(AccountEntity.uid): "id"])
    }
}

/**
 用户登入时带 token 的结构

 https://bb9z.github.io/API-Documentation-Sample/Sample/Account#SignInUp
 */
@objc(LoginResponseEntity)
@objcMembers
class LoginResponseEntity: MBModel {
    var info: AccountEntity?
    var token: String?
    var isNew: NSNumber?

    /// 收到服务器登入信息，设置当前用户
    func setAsCurrent() {
        guard let info = info, let token = token else {
            Current.hud.showErrorStatus("服务器返回信息缺失")
            return
        }
        let user = Account(id: info.uid)
        user.token = token
        AccountManager.current = user
    }

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper.forSnakeCase()
    }
}
