//
//  TopicEntity.swift
//  App
//

import B9MulticastDelegate

/**
 帖子

 https://bb9z.github.io/API-Documentation-Sample/Sample/Entity#TopicEntity
 */
@objc(TopicEntity)
@objcMembers
class TopicEntity: MBModel,
    IdentifierEquatable {

    var uid: String = ""
    var title: String?
    var content: String?
    var author: UserEntity?
    var createTime: Date?
    var editTime: Date?
//    "attachments": [AttachmentEntity],
    var status: [String] = [String]()
    var commentCount: Int = 0

    // MARK: -
    private var allowOperations = [String]()

    // MARK: - 赞

    var likeEnabled: Bool {
        allowOperations.contains("like")
    }

    var likeCount: Int = 0
    private(set) var isLiked = false
//    "last_comment": CommentEntity

    private weak var likeTask: RFAPITask?

    /// 切换点赞状态
    func toggleLike() {
        let positiveAPI = "TopicLikedAdd"
        let negativeAPI = "TopicLikedRemove"

        if let task = likeTask {
            task.cancel()
            likeTask = nil
            return
        }

        let shouldLike = !isLiked
        isLiked = shouldLike
        likeCount += shouldLike ? 1 : -1
        delegates.invoke { $0.topicLikedChanged?(self) }

        likeTask = API.requestName(shouldLike ? positiveAPI : negativeAPI, context: { c in
            c.parameters = ["tid": uid]
            c.completion { [self] task, _, _ in
                if task?.isSuccess == false {
                    isLiked = !shouldLike
                    likeCount -= shouldLike ? 1 : -1
                    delegates.invoke { $0.topicLikedChanged?(self) }
                }
            }
        })
    }

    // MARK: -

    override func isEqual(_ object: Any?) -> Bool {
        isUIDEqual(object)
    }
    override var hash: Int { uid.hashValue }

    override class func keyMapper() -> JSONKeyMapper! {
        JSONKeyMapper.baseMapper(JSONKeyMapper.forSnakeCase(), withModelToJSONExceptions: [ "uid": "id" ])
    }

    // MARK: -

    lazy var delegates = MulticastDelegate<TopicEntityUpdating>()
}

// 状态更新协议
// 需要可选实现，需要标记成 @objc
@objc protocol TopicEntityUpdating {
    @objc optional func topicLikedChanged(_ item: TopicEntity)
    @objc optional func topicCommentChanged(_ item: TopicEntity)
}
