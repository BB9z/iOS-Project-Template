//
//  MBApp.swift
//  App
//

/**
 全局变量中心

 这里主要是挂载一些公共模块的实例
 */
@objc
class MBApp: NSObject {
    static var global = MBApp()
    @objc class func status() -> MBApp {
        return Self.global
    }

    override init() {
        super.init()
        MBEnvironment.setAsApplicationDefault(env)
        setupVersion()
    }

    private func setupVersion() {
        let defaults = AppUserDefaultsShared()
        let bundle = Bundle.main
        version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? bundle.versionString

        guard let lastVersion = defaults.lastVersion else {
            // 全新启动
            defaults.lastVersion = version
             // 一天内重新安装，通知会保留，需要清掉
             UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            return
        }
        if lastVersion != version {
            // 应用升级了
            previousVersion = lastVersion
            defaults.previousVersion = lastVersion
            defaults.lastVersion = version
            defaults.launchCountCurrentVersion = 0
        }
    }

    /// 短版本号，形如 1.0
    @objc private(set) var version: String = ""

    /// 本次启动如有升级，值是旧版本号，否则为空
    @objc private(set) var previousVersion: String?

    // MARK: - 挂载的 manager

    /// 状态管理器
    @objc private(set) var env = MBEnvironment()

    /// 网络接口层
    @objc lazy var api: API = {
        let instance = API()
        API.global = instance
        instance.networkActivityIndicatorManager = self.hud
        return instance
    }()

    /// UI 提示管理器
    @objc lazy var hud = MessageManager()

    /// 
    @objc var rootViewController: RootViewController?

    /// 全局导航
    @objc var globalNavigationController: NavigationController?

//    @objc lazy var workerQueue = MBWorkerQueue()
//    @objc lazy var backgroundWorkerQueue: MBWorkerQueue = {
//        let queue = MBWorkerQueue()
//        queue.dispatchQueue = DispatchQueue(label: "BackgroundWorker", qos: .background)
//        return queue
//    }()
}
