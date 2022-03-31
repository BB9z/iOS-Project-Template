/*
 PushManager

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UserNotifications

/**
 推送管理器，JPush（极光推送）封装

 https://www.jiguang.cn

 使用：
 1. 引入 jPush 模块，目前（2021-12）只能通过 objc 的 bridging header 引入；
 2. `init(configuration:)` 初始化实例，注意外部必须保存返回实例的引用，否则会自行释放掉；
 3. 创建后会自行注册到 MBApplicationDelegate 上，不需要在其他文件中写任何代码；
 4. 在合适的时机调用 `requestNotificationsAuthorization(options:completion:)` 申请推送权限；
 5. 在合适的时机调用 `startJPush(appKey:isDevelopment:)` 激活极光推送服务；
 6. 设置 `handleUserActivedNotificaton` 响应通知。

 别名、标签功能等暂时没写
 */
final class PushManager: NSObject,
    UIApplicationDelegate,
    UNUserNotificationCenterDelegate {

    /// 应用启动时的 launchOptions
    /// jpush 初始化后会被清空
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    /// 应用进入前台后重置角标
    var resetBadgeWhenApplicationBecomeActive = false

    /// 响应用户点击的通知
    var handleUserActivedNotificaton: (([AnyHashable: Any]) -> Void)?

    required init(configuration: (PushManager) -> Void) {
        super.init()
        configuration(self)
//        center.delegate = self
        perform(#selector(afterInit), with: nil, afterDelay: 0)
    }

    @objc func afterInit() {
        proccessLaunchOptions()
        AppDelegate().addAppEventListener(self)
    }

    /// 开启极光服务
    func startJPush(appKey: String, isDevelopment: Bool) {
        #if !targetEnvironment(macCatalyst)
        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: nil, apsForProduction: !isDevelopment)
        JPUSHService.setLocationEanable(false)
        #if !DEBUG
        JPUSHService.setLogOFF()
        #endif
        #else
        AppLog().info("jPush 已禁用")
        #endif
        proccessLaunchOptions()
    }

    private func proccessLaunchOptions() {
        if let options = launchOptions {
            if let push = options[.remoteNotification] as? [AnyHashable: Any] {
                didReceiveRemoteNotification(userInfo: push, isUserAction: true)
            }
            launchOptions = nil
        }
    }

    /// 未获取成功为 nil
    var clientID: String? {
        #if targetEnvironment(macCatalyst)
        return "macCatalyst"
        #else
        return JPUSHService.registrationID()
        #endif
    }

    /**
     获取 clientID / registrationID

     回调可能不会被调用
     */
    func queryClientID(_ callback: @escaping (String) -> Void) {
        #if !targetEnvironment(macCatalyst)
        if let id = JPUSHService.registrationID() {
            callback(id)
            return
        }
        clientIDUpdate = callback
        JPUSHService.registrationIDCompletionHandler { [weak self] result, id in
            if let cid = id {
                AppLog().info("jPush cid: \(cid)")
                self?.clientIDUpdate?(cid)
            } else {
                AppLog().error("jPush cid 获取失败: <\(result)>")
            }
            self?.clientIDUpdate = nil
        }
        #endif
    }
    private var clientIDUpdate: ((String) -> Void)?

    private let center = UNUserNotificationCenter.current()

    /// 请求推送权限
    func requestNotificationsAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound], completion: ((_ granted: Bool, Error?) -> Void)? = nil) {
        UIApplication.shared.registerForRemoteNotifications()
        #if targetEnvironment(macCatalyst)
        center.requestAuthorization(options: options) { granted, error in
            if let cb = completion {
                cb(granted, error)
                return
            }
            if let e = error {
                AppLog().error("通知权限获取失败 \(e)")
            }
        }
        #else
        notificationsAuthorizationCompletion = completion
        let entity = JPUSHRegisterEntity()
        entity.types = Int(options.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        #endif
    }
    private var notificationsAuthorizationCompletion: ((_ granted: Bool, Error?) -> Void)?

    struct PostOptions {
        var identifier: String = UUID().uuidString
        /// 如果设置为大于 0，将在指定延迟后自动移除该推送
        var autoRemoveDelay: TimeInterval = 0
    }

    /// 发送本地推送通知
    func postNotification(options: PostOptions = PostOptions(), content: (UNMutableNotificationContent) -> Void) {
        let cxt = UNMutableNotificationContent()
        content(cxt)
        let request = UNNotificationRequest(identifier: options.identifier, content: cxt, trigger: nil)
        center.add(request) { error in
            if let e = error {
                AppLog().warning("添加推送失败 \(e)")
            }
        }
        if options.autoRemoveDelay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + options.autoRemoveDelay) { [self] in
                center.removeDeliveredNotifications(withIdentifiers: [options.identifier])
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        didReceiveRemoteNotification(userInfo: content.userInfo, isUserAction: true)
        completionHandler()
    }

    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any], isUserAction: Bool) {
        AppLog().debug("收到通知: \(userInfo)")
        #if targetEnvironment(macCatalyst)
        UIApplication.shared.applicationIconBadgeNumber = 0
        #else
        JPUSHService.handleRemoteNotification(userInfo)
        #endif
        if isUserAction {
            handleUserActivedNotificaton?(userInfo)
        }
    }

    #if !targetEnvironment(macCatalyst)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if lastDeviceToken != deviceToken {
            // MBApplicatonDelegate 机制问题，会调用两遍
            lastDeviceToken = deviceToken
            JPUSHService.registerDeviceToken(deviceToken)
            AppLog().debug("注册 deviceToken 到 jpush")
        }
    }
    private var lastDeviceToken: Data?
    #endif

    func applicationDidBecomeActive(_ application: UIApplication) {
        if resetBadgeWhenApplicationBecomeActive {
            resetBadge()
        }
    }

    /// 清空应用角标
    func resetBadge() {
        #if !targetEnvironment(macCatalyst)
        JPUSHService.resetBadge()
        #endif
    }
}

#if !targetEnvironment(macCatalyst)
extension PushManager: JPUSHRegisterDelegate {
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        AppLog().debug("推送将要呈现: \(notification!)")
        if notification.request.trigger is UNPushNotificationTrigger {
            let info = notification.request.content.userInfo
            JPUSHService.handleRemoteNotification(info)
        }
        let present: UNNotificationPresentationOptions = [.alert, .badge, .sound]
        completionHandler(Int(present.rawValue))
    }

    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        AppLog().debug("推送已呈现: \(response!)")
        let info = response.notification.request.content.userInfo
        if response.notification.request.trigger is UNPushNotificationTrigger {
            didReceiveRemoteNotification(userInfo: info, isUserAction: true)
        }
        completionHandler()
    }

    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        if let link = URL(string: "\(NavigationController.appScheme)://push-setting") {
            NavigationController.jump(url: link, context: nil)
        }
    }

    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable: Any]!) {
        AppLog().debug("jpushNotificationAuthorization \(status) \(info?.description ?? "-")")
        notificationsAuthorizationCompletion?(status != .statusDenied, nil)
        notificationsAuthorizationCompletion = nil
    }
}
#endif
