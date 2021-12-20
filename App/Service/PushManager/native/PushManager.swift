/*
 PushManager
 
 Copyright © 2020-2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

import UserNotifications

/**
 推送管理器，原生实现

 使用：
 1. managerWithConfiguration: 初始化实例，注意外部必须保存返回实例的引用，否则会自行释放掉
 2. 创建后会自行注册到 MBApplicationDelegate 上，不需要在其他文件中写任何代码
 3. 设置 receiveRemoteNotificationHandler, receiveLocalNotificationHandler 响应通知
 */

final class PushManager: NSObject,
    UIApplicationDelegate,
    UNUserNotificationCenterDelegate {

    /// 应用启动时的 launchOptions
    /// manager 创建后会被清空
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    /// 应用进入前台后重置角标
    var resetBadgeWhenApplicationBecomeActive = false

    required init(configuration: (PushManager) -> Void) {
        super.init()
        configuration(self)
        center.delegate = self
        perform(#selector(afterInit), with: nil, afterDelay: 0)
    }

    @objc func afterInit() {
        if let push = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            didReceiveRemoteNotification(userInfo: push, isUserAction: true)
        }
        launchOptions = nil
        AppDelegate().addAppEventListener(self)
    }

    private let center = UNUserNotificationCenter.current()

    /// 请求推送权限
    func requestNotificationsAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound], completion: ((_ granted: Bool, Error?) -> Void)? = nil) {
        UIApplication.shared.registerForRemoteNotifications()
        center.requestAuthorization(options: options) { granted, error in
            if let cb = completion {
                cb(granted, error)
                return
            }
            if let e = error {
                AppLog().error("通知权限获取失败 \(e)")
            }
        }
    }

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
        didReceiveRemoteNotification(userInfo: content.userInfo, isUserAction: false)
        completionHandler()
    }

    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any], isUserAction: Bool) {
        AppLog().info("收到通知: \(userInfo)")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if resetBadgeWhenApplicationBecomeActive {
            resetBadge()
        }
    }

    /// 清空应用角标
    func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
