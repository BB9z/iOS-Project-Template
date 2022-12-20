//
//  RootViewController.swift
//  App
//

import B9Action
import B9Condition
import UIKit

/**
 作为应用全局根 view controller

 内嵌主导航，这样如需遮盖导航的弹窗，可以加入到这里，比如启动闪屏、教程弹窗

 As the application global root view controller.

 Embed the main navigation view controller. Any pop-ups that need to cover the main navigation can be added here. Eg: splash, tutorial pop-ups.

 It should forward the style or control method of the view controller to the first child.
 */
class RootViewController: UIViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        MBApp.status().rootViewController = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        debugAdjustTraitCollection()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplash()
    }

    // MARK: - Splash
    // 🔰 启动闪屏渐出
    private weak var splash: UIViewController?
    private func setupSplash() {
        let launchStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        guard let vc = launchStoryboard.instantiateInitialViewController() else {
            fatalError()
        }
        addChildViewController(vc, into: view)
        splash = vc
        AppCondition().wait([.homeLoaded], action: Action {
            self.splashFinish()
        })
        // 设置一个最长等待，即使主页未加载好也能进去
        dispatch_after_seconds(2) { [self] in
            if splash == nil { return }
            // 🔰 如果只是为了展示几秒启动页，可以调整这里的逻辑，删掉上面的等待和这里的提示；
            // 设计上的用法是，等主页加载好可以展示后再去掉启动页，这需要你在主页里设置 .homeLoaded 标记
            AppLog().warning("启动闪屏等待超时，未设置 .homeLoaded？")
            splashFinish()
        }
    }

    func splashFinish() {
        guard let vc = splash else { return }
        splash = nil
        UIView.animate(withDuration: 0.5, animations: {
            vc.view.alpha = 0
        }, completion: { _ in
            vc.removeFromParentViewControllerAndView()
            if AppCondition().meets([.navigationLoaded]) {
                NSLog("⚠️ NavigationController 中的标记设置需移除")
            }
            // 延迟导航准备时间
            AppCondition().set(on: [.navigationLoaded])
        })
    }
}

// MARK: - Debug
extension RootViewController {
#if DEBUG
    /// 强制修改第一个子 vc size class，用以测试尺寸适配
    /// Force modify the size class of the first child view controller to test layout adaptation
    func debugAdjustTraitCollection() {
        guard let vc = children.first else { return }

        let size = view.bounds.size
        let currentCollection = overrideTraitCollection(forChild: vc) ?? .current
        let hClass = size.width > 700 ? UIUserInterfaceSizeClass.regular : .compact
        let vClass = size.height > 500 ? UIUserInterfaceSizeClass.regular : .compact
        if currentCollection.horizontalSizeClass == hClass,
           currentCollection.verticalSizeClass == vClass {
            return
        }
        let horizontal = UITraitCollection(horizontalSizeClass: hClass)
        let vertical = UITraitCollection(verticalSizeClass: vClass)
        let collection = UITraitCollection(traitsFrom: [currentCollection, horizontal, vertical])
        setOverrideTraitCollection(collection, forChild: vc)
    }
#else
    @inlinable
    func debugAdjustTraitCollection() {}
#endif  // END: DEBUG
}

// MARK: - Style/Control forward
extension RootViewController {
    private var _keyViewController: UIViewController? {
        children.first
    }

    override var shouldAutorotate: Bool {
        _keyViewController?.shouldAutorotate ?? true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        _keyViewController?.supportedInterfaceOrientations ?? .all
    }

    override var childForStatusBarStyle: UIViewController? {
        _keyViewController
    }

    override var childForStatusBarHidden: UIViewController? {
        _keyViewController
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        _keyViewController
    }

    override var childViewControllerForPointerLock: UIViewController? {
        _keyViewController
    }

    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        _keyViewController
    }

    override func childContaining(_ source: UIStoryboardUnwindSegueSource) -> UIViewController? {
        _keyViewController
    }
}
