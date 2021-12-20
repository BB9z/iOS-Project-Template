//
//  UserEntity.swift
//  App
//

/**
 用户模型

 https://bb9z.github.io/API-Documentation-Sample/Sample/Entity#UserEntity
 */
@objc(UserEntity)
@objcMembers
class UserEntity: MBModel,
    IdentifierEquatable {

    var uid: String = ""
    var name: String = ""
    var introduction: String?
    var avatar: String?
    var topicCount: Int = 0
    var likedCount: Int = 0

    // MARK: -

    override func isEqual(_ object: Any?) -> Bool {
        isUIDEqual(object)
    }
    override var hash: Int { uid.hashValue }

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper.baseMapper(JSONKeyMapper.forSnakeCase(), withModelToJSONExceptions: [ "uid": "id" ])
    }
}
