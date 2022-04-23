import B9Condition

/**
 首页
 */
class HomeViewController: UIViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .main }

    @IBAction private func navigationPop(_ sender: Any) {
        AppHUD().showInfoStatus("主页的该按钮用于调整导航返回按钮图片位置，请删除")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 通知主页已加载完毕，启动闪屏会等待这个信号，见 RootViewController
        AppCondition().set(on: [.homeLoaded])
    }
}
