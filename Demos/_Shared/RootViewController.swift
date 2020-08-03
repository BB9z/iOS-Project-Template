//
//  RootViewController.swift
//  App
//

/**
 应用顶层 vc

 嵌入主导航，这样如需遮盖导航的弹窗，可以加入到这里，比如启动闪屏、教程弹窗
 基类里做了对 vc 样式声明的铰接处理
 */
class RootViewController: MBRootViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        MBApp.status().rootViewController = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nav = NavigationController.newFromStoryboard()
        addChild(nav)
        if let navView = nav.view {
            navView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            navView.frame = view.bounds
            view.insertSubview(navView, at: 0)
        }
    }
}
