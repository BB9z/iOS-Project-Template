//
//  TopicDetailVC.swift
//  App
//

/**
 帖子详情
 */
class TopicDetailViewController: UIViewController,
    HasItem,
    TopicEntityUpdating {

    override class func storyboardName() -> String? { "Topic" }

    @objc var item: TopicEntity! {
        didSet {
            item.delegates.add(self)
        }
    }

    @IBOutlet weak var listView: MBTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let ds = listView.dataSource {
            ds.fetchAPIName = "CommentListTopic"
            ds.fetchParameters = ["tid": item.uid]
        }
        listView.pullToFetchController.footerContainer.emptyLabel.text = "暂无评论"
        updateUI(item: item)
        refresh()
    }

    @objc func refresh() {
        API.requestName("TopicDetail") { c in
            c.parameters = ["tid": item.uid]
            c.groupIdentifier = apiGroupIdentifier
            c.success { [weak self] _, rsp in
                guard let sf = self, let item = rsp as? TopicEntity else { return }
                sf.item.merge(from: item)
                sf.updateUI(item: sf.item)
            }
            c.failure { [weak self] _, error in
                guard let sf = self else { return }
                let e = error as NSError
                if e.code == 404 {
                    AppHUD().showInfoStatus("帖子已移除或不存在")
                    sf.navigationController?.removeViewController(sf, animated: true)
                    return
                }
                AppHUD().alertError(error, title: nil, fallbackMessage: "帖子信息获取失败")
            }
        }
        listView.pullToFetchController.triggerHeaderProcess()
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    func updateUI(item: TopicEntity) {
        titleLabel.text = item.title ?? "加载中..."
        contentLabel.text = item.content
        topicLikedChanged(item)
    }

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

/// 列表 cell
class CommentListCell: UITableViewCell, HasItem {
    @objc var item: CommentEntity! {
        didSet {
            avatarView.item = item.from
            userNameLabel.text = item.from?.name
            timeLabel.text = item.createTime?.recentString
            contentLabel.text = item.content
        }
    }
    @IBOutlet private weak var avatarView: UserAvatarView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
}

extension TopicDetailViewController: AppPageURL {
    var pageURL: URL? {
        URL(string: "\(NavigationController.appScheme)://topic/\(item.uid)")
    }
}
