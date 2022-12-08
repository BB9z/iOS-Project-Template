//
//  TopicListDisplayer.swift
//  App
//

import HasItem

/**
 帖子列表
 */
class TopicListDisplayer: MBTableListDisplayer, StoryboardCreation {
    static var storyboardID: StoryboardID { .topic }
}

#if DEBUG
import Debugger
extension TopicListDisplayer: DebugActionSource {
    func debugActionItems() -> [DebugActionItem] {
        [
            DebugActionItem("测试数据") { [self] in
                let user1 = UserEntity()
                user1.uid = "UAnOiIAvB1keXOBFfvUezgIQ"
                user1.name = "演示用户"
                user1.avatar = "https://via.placeholder.com/160?text=User+02"

                let tp1 = TopicEntity()
                tp1.uid = "TPEmpty"
                tp1.author = user1
                tp1.title = "长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长的标题"
                tp1.content = "1\n2 2\n3 3 3\n4 4 4 4\n5 5 5 5 5\n6 6 6 6 6 6\n7 7 7 7 7 7 7\n8 8 8 8 8 8 8 8\n9 9 9 9 9 9 9 9 9\n10\nEnd"
                tp1.createTime = Date()

                let tp2 = TopicEntity()
                tp2.uid = "TPEmpty"
                tp2.author = user1
                tp2.title = "无内容帖子"
                tp2.createTime = Date(timeIntervalSinceNow: -3600)

                let tp3 = TopicEntity()
                tp3.uid = "TP404"
                tp3.author = user1
                tp3.title = "已删除的帖子"
                tp3.content = "点进详情应提示删除并返回"
                tp3.createTime = Date(timeIntervalSinceNow: -3600 * 24)

                let items = [tp1, tp2, tp3]
                tableView.dataSource.setItemsWithRawData(items)
            }
        ]
    }
}
#endif

/// 帖子列表 cell
class TopicListCell: UITableViewCell,
    HasItem,
    TopicEntityUpdating {

    @objc var item: TopicEntity! {
        didSet {
            if let old = oldValue {
                old.delegates.remove(self)
            }
            item.delegates.add(self)
            avatarView.item = item.author
            titleLabel.text = item.title
            contentLabel.text = item.content?.replacingOccurrences(of: "\n", with: " ")
            dateLabel.text = item.createTime?.recentString
            topicLikedChanged(item)
        }
    }
    @IBOutlet private weak var avatarView: UserAvatarView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var likeButton: UIButton!
    @IBAction private func onLikeButtonTapped(_ sender: Any) {
        item.toggleLike()
    }
    func topicLikedChanged(_ item: TopicEntity) {
        likeButton.isEnabled = item.likeEnabled
        likeButton.isSelected = item.isLiked
        likeButton.text = (item.isLiked ? "已赞" : "点赞") + " \(item.likeCount)"
    }
}
