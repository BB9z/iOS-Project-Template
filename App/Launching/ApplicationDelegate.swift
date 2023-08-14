//
//  ApplicationDelegate.swift
//  App
//

import AppFramework
import B9Condition
import Debugger

/**
 注意是基于 MBApplicationDelegate 的，大部分 UIApplicationDelegate 方法需要调用 super

 外部推荐尽可能通过 addAppEventListener() 来监听事件；
 MBApplicationDelegate 默认未分发的方法可以自定义，通过 enumerateEventListeners() 方法进行分发。
 */
@UIApplicationMain
class ApplicationDelegate: MBApplicationDelegate {
    override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Current.version.markAppLaunching()
        // 🔰 模版简单延迟一下认为启动成功了，可结合实际业务调整时机
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            Current.version.markAppLaunchedSuccessful()
        }
        #if DEBUG
        MBAssertSetHandler { msg, file, line in
            AppLog().error("\(msg)")
            assertionFailure(msg, file: file, line: line)
        }
        #endif
        return true
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if PREVIEW
        #elseif DEBUG
        // https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#tools-implement-faster
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
        _ = Current.api
        Account.setup()
//        MBEnvironment.registerWorkers()
        RFKeyboard.autoDisimssKeyboardWhenTouch = true
        setupUIAppearance()
        dispatch_after_seconds(0, setupDebugger)
        return true
    }

    private func setupDebugger() {
        Debugger.installTriggerButton()
        Debugger.globalActionItems = [
            DebugActionItem("FLEX") {
                MBFlexInterface.showFlexExplorer()
            }
        ]
        Debugger.urlJumpHandler = {
            NavigationController.jump(url: $0, context: nil)
        }
        Debugger.vauleInspector = { value in
            if let vc = MBFlexInterface.explorerViewController(for: value) {
                Current.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    private func setupUIAppearance() {
        // 统一全局色，storyboard 的全局色只对部分 UI 生效，比如无法对 UIAlertController 应用
        window.tintColor = UIColor(named: "primary")!

        #if DEBUG
        // 强制修改窗口的最小尺寸，用以调试小屏幕适配
        window.windowScene?.sizeRestrictions?.minimumSize = CGSize(width: 200, height: 300)
        #endif

        // 列表 data source 全局调整
        MBListDataSource<AnyObject>.defualtPageStartZero = false
        MBListDataSource<AnyObject>.defaultPageSizeParameterName = "size"
        MBListDataSource<AnyObject>.defaultFetchFailureHandler = { _, error in
            let e = error as NSError
            if e.domain == NSURLErrorDomain &&
                (e.code == NSURLErrorTimedOut
                || e.code == NSURLErrorNotConnectedToInternet) {
                // 超时断网不报错
            } else {
                Current.hud.alertError(e, title: nil, fallbackMessage: "列表加载失败")
            }
            return false
        }
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        if !AppCondition().meets([.appHasEnterForegroundOnce]) {
            AppCondition().set(on: [.appHasEnterForegroundOnce])
        }
        AppCondition().set(on: [.appInForeground])
        super.applicationDidBecomeActive(application)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        AppCondition().set(off: [.appInForeground])
        super.applicationDidEnterBackground(application)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        var hasHande = false
        enumerateEventListeners { listener in
            if listener.application?(application, continue: userActivity, restorationHandler: restorationHandler) ?? false {
                hasHande = true
            }
        }
        return hasHande
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.scheme == NavigationController.appScheme {
            NavigationController.jump(url: url, context: nil)
            return true
        }
        return super.application(app, open: url, options: options)
    }
}
