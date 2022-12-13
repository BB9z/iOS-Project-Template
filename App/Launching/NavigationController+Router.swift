//
//  NavigationController+Router.swift
//  App
//

import B9Condition

/**
 导航对 URL 跳转的支持
 */
extension NavigationController {

    /// 应用的自定义 scheme
    @objc class var appScheme: String { "example" }

    /**
     应用支持的跳转

     http/https 链接，打开 Safari；
     其它跳转需要以 appScheme:// 起始
     */
    @objc class func jump(url: URL, context: Any?) {
        if AppCondition().meets([.navigationLoaded]) {
            AppNavigationController()?.jump(url: url, context: context)
            return
        }
        let hasWaiting = navigatorBlockedJumpURL != nil
        navigatorBlockedJumpURL = url
        navigatorBlockedJumpContext = context
        if hasWaiting { return }
        AppCondition().wait([.navigationLoaded], action: Action {
            if let url = navigatorBlockedJumpURL {
                AppNavigationController()?.jump(url: url, context: navigatorBlockedJumpContext)
            }
        })
    }

    /// 跳转路由具体实现
    private func jump(url: URL, context: Any?) {
        if url.isHTTP {
            // http 链接交由系统处理
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("⚠️ \(url) 转为 components 失败")
            return
        }
        guard components.scheme == Self.appScheme else { return }
        // 相同页面不再跳转
        if url == currentPageURL() { return }

        // 🔰 实现各种跳转，下列演示处理 URL 符合 appScheme://command/{id} 形式

        // 无命令则不是一个有效命令，忽略
        guard let command = components.host else { return }
        let optionalItemID = url.pathComponents.element(at: 1)
        // 🔰 整型 ID 可用下列代码
//        let optionalItemID: MBID? = {
//            if let idString = url.pathComponents.element(at: 1) {
//                return MBID(idString)
//            }
//            return nil
//        }()

        guard let itemID = optionalItemID else {
            return
        }
        if command == "topic" {
            let item = TopicEntity()
            item.uid = itemID
            let vc = TopicDetailViewController.newFromStoryboard()
            vc.item = item
            pushViewController(vc, animated: true)
        }
    }

    /// 当前显示页面的 URL
    func currentPageURL() -> URL? {
        (visibleViewController as? AppPageURL)?.pageURL
    }
}

/// 暂存导航未准备好时的跳转
private var navigatorBlockedJumpURL: URL?
private var navigatorBlockedJumpContext: Any?

/**
 导航通过 URL 跳转时，如果当前页面声明的 pageURL 和即将跳转的 URL 一致，可以避免重复的跳转

 实现例子：

 ```
 extension TopicDetailViewController: AppPageURL {
     var pageURL: URL? {
         URL(string: "\(NavigationController.appScheme)://topic/\(item.uid)")
     }
 }
 ```
 */
protocol AppPageURL {
    var pageURL: URL? { get }
}
