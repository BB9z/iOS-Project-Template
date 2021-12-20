//
//  MoreVC.swift
//  App
//

/**
 更多 tab 页
 */
class MoreViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .main }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAccountUI()
        // 演示：为了区分数据来源，不在这里刷新数据了
    }

    @IBOutlet private weak var avatarView: MBImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var introductionLabel: UILabel!
    private func updateAccountUI() {
        let user = AppUserInformation()
        avatarView.imageURL = user?.avatar
        userNameLabel.text = user != nil ? user?.name : "请登录"
        introductionLabel.text = user?.introduction
    }

    @IBAction private func onLogout(_ sender: Any) {
        let alert = UIAlertController(title: "确定要登出么", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "登出", style: .default, handler: { _ in
            Account.current = nil
        }))
        rfPresent(alert, animated: true, completion: nil)
    }
}
