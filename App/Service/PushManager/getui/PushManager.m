
#import "PushManager.h"
#import "Common.h"
#import <MBAppKit/MBApplicationDelegate.h>
#import <GTSDK/GeTuiSdk.h>
#import <RFKit/NSJSONSerialization+RFKit.h>
@import ObjectiveC;
@import UserNotifications;
// 这个类不应该跟应用业务扯上任何关系

@interface PushManager () <
    UNUserNotificationCenterDelegate,
    GeTuiSdkDelegate
> {
    BOOL _initWithConfiguration;
}
@property BOOL _pushManager_aliasToSet;
@property BOOL _pushManager_tagsToSet;
@end


@implementation PushManager
RFInitializingRootForNSObject;

+ (nonnull instancetype)managerWithConfiguration:(NS_NOESCAPE void (^_Nonnull)(PushManager *_Nonnull manager))configBlock {
    NSParameterAssert(configBlock);
    PushManager *this = [self new];
    configBlock(this);
    this->_initWithConfiguration = YES;

    NSAssert(this.appKey && this.appID && this.appSecret, @"个推应用配置没有正确设置");
    [GeTuiSdk startSdkWithAppId:this.appID appKey:this.appKey appSecret:this.appSecret delegate:this];
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = this;
    }
    return this;
}

- (void)onInit {
    self.resetBadgeAfterLaunching = YES;
    self.pushTags = [NSMutableSet setWithCapacity:20];
}

- (void)afterInit {
    RFAssert(_initWithConfiguration, @"You must create PushManager with managerWithConfiguration: method.");
    if (self.resetBadgeAfterLaunching) {
        // 在前台且未设置进入前台时自动清零才在这里清零
        if (AppActive() && !self.resetBadgeWhenApplicationBecomeActive) {
            [self resetBadge];
        }
    }

    [AppDelegate() addAppEventListener:self];
    [self registerForRemoteNotificationsIfNeeded];

    NSDictionary *lq = self.launchOptions;
    if (lq) {
        self.launchOptions = nil;
        if (@available(iOS 10.0, *)) {
            // iOS 10 走到这里 UNUserNotificationCenter 已经接收了
            return;
        }
        else {
            UILocalNotification *ln = lq[UIApplicationLaunchOptionsLocalNotificationKey];
            if (ln) {
                [self handleLocalNotification:ln fromLaunch:YES];
            }
            NSDictionary *dic = lq[UIApplicationLaunchOptionsRemoteNotificationKey];
            if (dic) {
                [self handleRemoteNotification:dic fromLaunch:YES];
            }
        }
    }
}

- (void)dealloc {
    self.resetBadgeWhenApplicationBecomeActive = NO;
}

- (void)registerForRemoteNotificationsIfNeeded {
    UIApplication *ap = [UIApplication sharedApplication];
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
        }];
    }
    else {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [ap registerUserNotificationSettings:settings];
    }
    [ap registerForRemoteNotifications];
}

#pragma mark -

+ (NSString *)pushID {
    return GeTuiSdk.clientId;
}

+ (nonnull NSString *)stringFromDeviceToken:(nonnull NSData *)deviceToken {
    const char *data = deviceToken.bytes;
    NSMutableString *token = [NSMutableString string];

    for (int i = 0; i < deviceToken.length; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    return token;
}

// 解开 APNS 中的 payload 消息，使之与透传结构一致
+ (nonnull NSDictionary *)normalizedPushUserInfo:(nonnull NSDictionary *)userInfo {
    id payload = userInfo[@"payload"];
    if ([payload isKindOfClass:NSString.class]) {
        payload = [NSJSONSerialization JSONObjectWithString:payload];
    }
    if ([payload isKindOfClass:NSDictionary.class]) {
        return payload;
    }
    return userInfo;
}

#pragma mark -

/**
 应用未启动，点击通知启动应用，launchOptions 和 didReceiveRemoteNotification 都会有这条推送的信息
 当应用切到后台，或从后台启动，didReceiveRemoteNotification 调用，此时 AppActive() 是 NO
 如果应用在前台，收到通知，didReceiveRemoteNotification 调用，此时 AppActive() 是 YES
 */
- (void)handleRemoteNotification:(NSDictionary *)notification fromLaunch:(BOOL)fromLaunch {
    dout_info(@"收到推送信息：%@", notification);
    RFAssert(notification, @"不应为空");
    if (!notification) return;
    [GeTuiSdk handleRemoteNotification:notification];
    if ([self.lastNotificationReceived isEqual:notification] && ![notification valueForKeyPath:@"aps.content-available"]) {
        // 通过 content-available 启动，会调两次，afterInit 只当用户打开时才会调用
        // 普通点推送即使有 launchOptions，因为应用事件是后注册的，这里只会收到一次
        RFAssert(false, @"目前期望不会有重复的推送");
        return;
    }

    // 这里不考虑 content-available 的影响了，正常期望让用户点击的推送不应该带 content-available，带 content-available 的不应该带标题让用户可点
    // 现在我们有两个状态量 fromLaunch（是不是首次启动），AppActive()（启动时是前台还是后台）
    // 分成四种情况：Y Y，用户点击推送启动；Y N，后台 content-available 唤醒启动；
    // N Y，应用在前台；N N，应用之前启动了，但现在处于后台，此时用户点击推送启动。
    BOOL isActive = AppActive();
    BOOL byUserClick = (fromLaunch && isActive) || (!fromLaunch && !isActive);
    if (self.receiveRemoteNotificationHandler) {
        self.receiveRemoteNotificationHandler(notification, nil, byUserClick);
    }
    self.lastNotificationReceived = notification;
}

- (void)handleLocalNotification:(UILocalNotification *)notification fromLaunch:(BOOL)fromLaunch {
    dout_info(@"收到本地推送信息：%@", notification);
    RFAssert(notification, @"不应为空");
    if (!notification) return;
    RFAssert(![self.lastNotificationReceived isEqual:notification], @"目前期望不会有重复的推送");

    BOOL isActive = AppActive();
    BOOL byUserClick = (fromLaunch && isActive) || (!fromLaunch && !isActive);
    if (self.receiveLocalNotificationHandler) {
        self.receiveLocalNotificationHandler(notification.userInfo, notification, byUserClick);
    }
    self.lastNotificationReceived = notification.userInfo;
}

#pragma mark - UNUserNotificationCenterDelegate

// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0)) {
    __unused NSDictionary *_ = notification.request.content.userInfo;
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)) {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        if (self.receiveRemoteNotificationHandler) {
            self.receiveRemoteNotificationHandler([self.class normalizedPushUserInfo:userInfo], response.notification, YES);
        }
        [GeTuiSdk handleRemoteNotification:userInfo];
        self.lastNotificationReceived = userInfo;
    } else {
        if (self.receiveLocalNotificationHandler) {
            self.receiveLocalNotificationHandler(userInfo, response.notification, YES);
        }
        self.lastNotificationReceived = userInfo;
    }
    completionHandler();
}

#pragma mark - Application 事件响应

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *tokenString = [self.class stringFromDeviceToken:deviceToken];
    [GeTuiSdk registerDeviceToken:tokenString];
    self.deviceToken = tokenString;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleRemoteNotification:userInfo fromLaunch:NO];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self handleLocalNotification:notification fromLaunch:NO];
}

#pragma mark - 个推事件处理

- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    NSDictionary *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:nil];
    }
    dout(@"taskId=%@,messageId:%@,payloadMsg:%@%@",taskId,msgId, payloadMsg,offLine ? @"<离线消息>" : @"")
    if (self.receiveRemoteNotificationHandler) {
        NSDictionary *n = @{
                            @"offline": @(offLine)
                            };
        self.receiveRemoteNotificationHandler(payloadMsg, n, NO);
    }
}

- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    if (!clientId) return;
    if (self._pushManager_aliasToSet) {
        if (self.pushAlias) {
            [GeTuiSdk bindAlias:self.pushAlias andSequenceNum:self.pushAlias];
        }
        self._pushManager_aliasToSet = NO;
    }
    if (self._pushManager_tagsToSet) {
        if (self.pushTags) {
            [GeTuiSdk setTags:self.pushTags.allObjects];
        }
        self._pushManager_tagsToSet = NO;
    }
}

- (void)GeTuiSdkDidOccurError:(NSError *)error {
    dout_error(@"收到个推错误: %@", error);
}

#pragma mark - Alias Tag

- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError {
    dout_info(@"个推别名 %@ %@ %@ %@", action, isSuccess? @"成功" : @"失败", aSn, aError);
}

- (void)setPushAlias:(NSString *)pushAlias {
    if (!GeTuiSdk.clientId) {
        // 只有 cid 注册后设置才会生效
        self._pushManager_aliasToSet = YES;
        _pushAlias = pushAlias.copy;
        return;
    }
    if ([_pushAlias isEqualToString:pushAlias]) return;
    if (_pushAlias) {
        [GeTuiSdk unbindAlias:_pushAlias andSequenceNum:_pushAlias andIsSelf:YES];
    }
    _pushAlias = pushAlias.copy;
    if (pushAlias) {
        [GeTuiSdk bindAlias:pushAlias andSequenceNum:pushAlias];
    }
}

- (void)setPushTags:(NSSet *)pushTags {
    if (!GeTuiSdk.clientId) {
        // 只有 cid 注册后设置才会生效
        self._pushManager_tagsToSet = YES;
        _pushTags = pushTags.copy;
        return;
    }
    if ([GeTuiSdk setTags:pushTags.allObjects]) {
        _pushTags = pushTags.copy;
    }
}

#pragma mark - 角标管理

- (void)setResetBadgeWhenApplicationBecomeActive:(BOOL)resetBadgeWhenApplicationBecomeActive {
    if (_resetBadgeWhenApplicationBecomeActive != resetBadgeWhenApplicationBecomeActive) {
        if (_resetBadgeWhenApplicationBecomeActive) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        }
        _resetBadgeWhenApplicationBecomeActive = resetBadgeWhenApplicationBecomeActive;
        if (resetBadgeWhenApplicationBecomeActive) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationBecomeActiveThenResetBadge) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
}

- (void)onApplicationBecomeActiveThenResetBadge {
    // 保持两秒在前台才去清零
    dispatch_after_seconds(2, ^{
        if (AppActive()) {
            [self resetBadge];
        }
    });
}

- (void)resetBadge {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [GeTuiSdk resetBadge];
}

@end
