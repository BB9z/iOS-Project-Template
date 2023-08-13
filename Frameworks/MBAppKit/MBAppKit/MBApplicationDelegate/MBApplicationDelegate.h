/*!
 MBApplicationDelegate
 MBAppKit
 
 Copyright © 2018-2020 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 项目中可以重载这个类作为 AppDelegate
 
 主要功能是提供应用事件监听注册、分发。
 
 背景
 
 > 应用会有多个模块，模块间可能相互依赖，
 > 并假设这些模块不在启动时依次创建好，而是按需访问（这也是大型应用必须的）。
 >
 > UIApplicationDelegate 这么多通知调用的时机是不确定的，
 > 假如我们在 delegate 回调中创建这些模块，结果必然是模块创建时机不可控。
 >
 > 为了避免创建时序不确定带来的混乱，我们统一让模块创建后自己去添加监听事件。

 */
API_AVAILABLE(ios(9.0), tvos(9.0))
@interface MBApplicationDelegate : UIResponder <
    UIApplicationDelegate
>

/**
 注册应用事件通知
 
 @warning 只有部分事件会通知 listener，见实现
 另外，多个模块的事件处理之间不应该有顺序依赖，否则可能会产生难以追查的 bug
 
 @param listener 内部会弱引用保存，对象释放无需手动调用移除
 */
- (void)addAppEventListener:(nullable __weak id<UIApplicationDelegate>)listener;

/**
 移除应用事件监听
 */
- (void)removeAppEventListener:(nullable id<UIApplicationDelegate>)listener;

/**
 遍历已注册的事件监听，可用于自定义通知的发送
 */
- (void)enumerateEventListenersUsingBlock:(NS_NOESCAPE void (^)(id<UIApplicationDelegate> listener))block;

#pragma mark - UIApplicationDelegate

@property (nonatomic) UIWindow *window;

/**
 重写了大部分常用 UIApplicationDelegate 事件，不会重写的有：
 
 - iOS 9 以下废弃的方法，及当前 deployment target 下废弃的方法
 - 带完成回调的方法
 - UISceneSession 相关方法
 - application:willFinishLaunchingWithOptions:
 - application:didFinishLaunchingWithOptions:
 - application:supportedInterfaceOrientationsForWindow:
 - application:shouldAllowExtensionPointIdentifier:

 - 状态还原的方法，包括：
     - application:viewControllerWithRestorationIdentifierPath:coder:
     - application:shouldSaveApplicationState:
     - application:shouldSaveSecureApplicationState:
     - application:shouldRestoreApplicationState:
     - application:shouldRestoreSecureApplicationState:
     - application:willEncodeRestorableStateWithCoder:
     - application:didDecodeRestorableStateWithCoder:
 
 - application:willContinueUserActivityWithType:
 - application:continueUserActivity:restorationHandler:
 - application:didFailToContinueUserActivityWithType:error:
 - application:didUpdateUserActivity:

 - application:configurationForConnectingSceneSession:options:
 
 子类如果重写下列方法，必须调用 super 以免破坏通知机制
 */

- (void)applicationDidBecomeActive:(nonnull UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillResignActive:(nonnull UIApplication *)application NS_REQUIRES_SUPER;

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_REQUIRES_SUPER;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillTerminate:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationSignificantTimeChange:(UIApplication *)application NS_REQUIRES_SUPER;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame NS_REQUIRES_SUPER;
#endif

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply NS_REQUIRES_SUPER;

- (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_REQUIRES_SUPER;

- (void)applicationDidEnterBackground:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationWillEnterForeground:(UIApplication *)application NS_REQUIRES_SUPER;

- (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application NS_REQUIRES_SUPER;
- (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application NS_REQUIRES_SUPER;

- (void)application:(UIApplication *)application userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata API_AVAILABLE(ios(10.0)) NS_REQUIRES_SUPER;

#pragma mark - 推送

// Tips: 如需 application:didReceiveRemoteNotification:fetchCompletionHandler: 请在子类中实现

/**
 推送通知的 device token
 
 支持 KVO
 
 设置的时机不稳定，实测结果（调用 registerForRemoteNotifications 方法后）：
 iOS 12-13，联网后可以拿到，和是否授权无关，能拿到后可以一直拿到，卸载会变
 iOS 11，直接允许或从关到开时：有网立即设置，无网等网络可用时设置
 iOS 11，直接拒绝或从开到关时：token、error 都不调用
 iOS 9-10 未测试
 
 didFailToRegisterForRemoteNotificationsWithError: iOS 11-13 真机未见调用过
 */
@property (readonly, nullable) NSData *remoteNotificationDeviceToken;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_REQUIRES_SUPER;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_REQUIRES_SUPER;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
// iOS 10+ 替换
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_REQUIRES_SUPER;
// iOS 10+ 替换
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_REQUIRES_SUPER;
// iOS 10+ 替换
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification NS_REQUIRES_SUPER;
#endif

@end

NS_ASSUME_NONNULL_END

