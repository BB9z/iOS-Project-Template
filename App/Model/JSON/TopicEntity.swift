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
class TopicEntity: MBModel,
    IdentifierEquatable {

    @objc var uid: String = ""
    @objc var title: String?
    @objc var content: String?
    @objc var author: UserEntity?
    @objc var createTime: Date?
    @objc var editTime: Date?
//    "attachments": [AttachmentEntity],
    @objc var status: [String] = [String]()
    @objc var commentCount: Int = 0

    // MARK: -
    @objc private var allowOperations = [String]()

    // MARK: - 赞

    var likeEnabled: Bool {
        allowOperations.contains("like")
    }

    @objc var likeCount: Int = 0
    @objc private(set) var isLiked: Bool = false
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
            c.parameters = ["tid": self.uid]
            c.complation { task, _, _ in
                if task?.isSuccess == false {
                    self.isLiked = !shouldLike
                    self.likeCount -= shouldLike ? 1 : -1
                    self.delegates.invoke { $0.topicLikedChanged?(self) }
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
