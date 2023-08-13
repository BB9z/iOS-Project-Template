
#import "MBApplicationDelegate.h"

@interface MBApplicationDelegate ()
@property (nonatomic) NSHashTable<id<UIApplicationDelegate>> *_MBApplicationDelegate_eventListeners;
@end

@implementation MBApplicationDelegate

#pragma mark - 通用事件监听

- (NSHashTable<id<UIApplicationDelegate>> *)_MBApplicationDelegate_eventListeners {
    if (__MBApplicationDelegate_eventListeners) return __MBApplicationDelegate_eventListeners;
    __MBApplicationDelegate_eventListeners = [NSHashTable weakObjectsHashTable];
    return __MBApplicationDelegate_eventListeners;
}

- (void)addAppEventListener:(nullable id<UIApplicationDelegate>)listener {
    @synchronized(self) {
        [self._MBApplicationDelegate_eventListeners addObject:listener];
    }
    dispatch_async_on_main(^{
        if (![self._MBApplicationDelegate_eventListeners containsObject:listener]) return;
        if (self.remoteNotificationDeviceToken
            && [listener respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [listener application:UIApplication.sharedApplication didRegisterForRemoteNotificationsWithDeviceToken:self.remoteNotificationDeviceToken];
        }
    });
}

- (void)removeAppEventListener:(nullable id<UIApplicationDelegate>)listener {
    @synchronized(self) {
        [self._MBApplicationDelegate_eventListeners removeObject:listener];
    }
}

- (void)enumerateEventListenersUsingBlock:(NS_NOESCAPE void (^)(id<UIApplicationDelegate> _Nonnull))block {
    if (!block) return;
    NSArray *all = self._MBApplicationDelegate_eventListeners.allObjects;
    for (id<UIApplicationDelegate> listener in all) {
        block(listener);
    }
}

#define _app_delegate_event_notice1(SELECTOR)\
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
    for (id<UIApplicationDelegate> listener in all) {\
        if (![listener respondsToSelector:@selector(SELECTOR:)]) continue;\
        [listener SELECTOR:application];\
    }\

#define _app_delegate_event_notice2(SELECTOR, PARAMETER1)\
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
    for (id<UIApplicationDelegate> listener in all) {\
        if (![listener respondsToSelector:@selector(application:SELECTOR:)]) continue;\
        [listener application:application SELECTOR:PARAMETER1];\
    }

#define _app_delegate_event_notice3(SELECTOR1, PARAMETER1, SELECTOR2, PARAMETER2)\
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];\
    for (id<UIApplicationDelegate> listener in all) {\
        if (![listener respondsToSelector:@selector(application:SELECTOR1:SELECTOR2:)]) continue;\
        [listener application:application SELECTOR1:PARAMETER1 SELECTOR2:PARAMETER2];\
    }

#define _app_delegate_event_method(SELECTOR) \
    - (void)SELECTOR:(UIApplication *)application {\
        _app_delegate_event_notice1(SELECTOR) }

#define _app_delegate_event_method2(SELECTOR) \
    - (void)application:(UIApplication *)application SELECTOR:(id)obj {\
        _app_delegate_event_notice2(SELECTOR, obj) }

_app_delegate_event_method(applicationDidBecomeActive)
_app_delegate_event_method(applicationWillResignActive)

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSArray *all = [self._MBApplicationDelegate_eventListeners allObjects];
    for (id<UIApplicationDelegate> ls in all) {
        if (![ls respondsToSelector:@selector(application:openURL:options:)]) continue;
        if ([ls application:app openURL:url options:options]) return YES;
    }
    return NO;
}

_app_delegate_event_method(applicationDidReceiveMemoryWarning)
_app_delegate_event_method(applicationWillTerminate)
_app_delegate_event_method(applicationSignificantTimeChange)

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)p1 duration:(NSTimeInterval)p2 {
    _app_delegate_event_notice3(willChangeStatusBarOrientation, p1, duration, p2)
}
- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)p1 {
    _app_delegate_event_notice2(didChangeStatusBarOrientation, p1)
}
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)p1 {
    _app_delegate_event_notice2(willChangeStatusBarFrame, p1)
}
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)p1 {
    _app_delegate_event_notice2(didChangeStatusBarFrame, p1)
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [self willChangeValueForKey:@keypath(self.remoteNotificationDeviceToken)];
    _remoteNotificationDeviceToken = deviceToken;
    [self didChangeValueForKey:@keypath(self.remoteNotificationDeviceToken)];
    _app_delegate_event_notice2(didRegisterForRemoteNotificationsWithDeviceToken, deviceToken)
}
_app_delegate_event_method2(didFailToRegisterForRemoteNotificationsWithError)

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
_app_delegate_event_method2(didRegisterUserNotificationSettings)
_app_delegate_event_method2(didReceiveRemoteNotification)
_app_delegate_event_method2(didReceiveLocalNotification)
#endif

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary * _Nullable))reply {
    _app_delegate_event_notice3(handleWatchKitExtensionRequest, userInfo, reply, reply)
}

_app_delegate_event_method(applicationShouldRequestHealthAuthorization)

_app_delegate_event_method(applicationDidEnterBackground)
_app_delegate_event_method(applicationWillEnterForeground)

_app_delegate_event_method(applicationProtectedDataWillBecomeUnavailable)
_app_delegate_event_method(applicationProtectedDataDidBecomeAvailable)

_app_delegate_event_method2(userDidAcceptCloudKitShareWithMetadata)

@end
