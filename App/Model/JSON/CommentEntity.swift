//
//  CommentEntity.swift
//  App
//

/**
 帖子评论

 https://bb9z.github.io/API-Documentation-Sample/Sample/Entity#CommentEntity
 */
@objc(CommentEntity)
@objcMembers
class CommentEntity: MBModel,
    IdentifierEquatable {

    var uid: String = ""
    var from: UserEntity?
    var to: UserEntity?
    var createTime: Date?
    var content: String?
    var replies: [CommentEntity]?

    // MARK: -

    override func isEqual(_ object: Any?) -> Bool {
        isUIDEqual(object)
    }
    override var hash: Int { uid.hashValue }

    override class func classForCollectionProperty(propertyName: String!) -> AnyClass! {
        if propertyName == #keyPath(CommentEntity.replies) {
            return CommentEntity.self
        }
        return super.classForCollectionProperty(propertyName: propertyName)
    }

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper.baseMapper(JSONKeyMapper.forSnakeCase(), withModelToJSONExceptions: [ "uid": "id" ])
    }
}
