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
        #if DEBUG
        debugAdjustWindowSize()
        #endif
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        #if DEBUG
        debugAdjustTraitCollection()
        #endif
    }

    // MARK: - Splash
    /* 🔰 启动闪屏渐出
    private weak var splash: UIViewController?
    private func setupSplash() {
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        guard let vc = launchStoryboard.instantiateInitialViewController() else {
            fatalError()
        }
        addChildViewController(vc, into: view)
        splash = vc
        AppEnv().waitFlags(.homeLoaded, do: {
            self.splashFinish()
        }, timeout: 3)
    }

    func splashFinish() {
        guard let vc = splash else { return }
        splash = nil
        UIView.animate(withDuration: 0.3, animations: {
            vc.view.alpha = 0
        }, completion: { _ in
            vc.removeFromParentViewControllerAndView()
            if AppEnv().meetFlags(.naigationLoaded) {
                NSLog("⚠️ NavigationController 中的标记设置需移除")
            }
            // 延迟导航准备时间
            AppEnv().setFlagOn(.naigationLoaded)
        })
    }
    */

    // MARK: - UI 适配辅助

    #if DEBUG
    #if targetEnvironment(macCatalyst)
    /// 强制修改窗口的最小尺寸，用以调试小屏幕适配
    func debugAdjustWindowSize() {
        if let size = AppDelegate().window.windowScene?.sizeRestrictions {
            size.minimumSize = CGSize(width: 200, height: 100)
        }
    }

    /// 强制修改第一个子 vc size class，用以测试尺寸适配
    func debugAdjustTraitCollection() {
        if let vc = children.first {
            let currentCollection = overrideTraitCollection(forChild: vc) ?? UITraitCollection.current
            let hClass = view.width > 700 ? UIUserInterfaceSizeClass.regular : UIUserInterfaceSizeClass.compact
            let vClass = view.height > 500 ? UIUserInterfaceSizeClass.regular : UIUserInterfaceSizeClass.compact
            if currentCollection.horizontalSizeClass == hClass,
                currentCollection.verticalSizeClass == vClass {
                return
            }
            let horizontal = UITraitCollection(horizontalSizeClass: hClass)
            let vertical = UITraitCollection(verticalSizeClass: vClass)
            let collection = UITraitCollection(traitsFrom: [currentCollection, horizontal, vertical])
            setOverrideTraitCollection(collection, forChild: vc)
        }
    }
    #else
    func debugAdjustWindowSize() {}
    func debugAdjustTraitCollection() {}
    #endif  // END: macCatalyst
    #endif  // END: DEBUG
}
