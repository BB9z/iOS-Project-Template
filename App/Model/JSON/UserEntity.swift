//
//  UserEntity.swift
//  App
//

/**
 用户模型

 https://bb9z.github.io/API-Documentation-Sample/Sample/Entity#UserEntity
 */
@objc(UserEntity)
class UserEntity: MBModel,
    IdentifierEquatable {

    @objc var uid: String = ""
    @objc var name: String = ""
    @objc var introduction: String?
    @objc var avatar: String?
    @objc var topicCount: Int = 0
    @objc var likedCount: Int = 0

    // MARK: -

    override func isEqual(_ object: Any?) -> Bool {
        isUIDEqual(object)
    }
    override var hash: Int { uid.hashValue }

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper.baseMapper(JSONKeyMapper.forSnakeCase(), withModelToJSONExceptions: [ "uid": "id" ])
    }
}
