
#import "MBShareManager.h"
#import "Common.h"
#import <AuthenticationServices/AuthenticationServices.h>

#if __has_include("TencentOpenAPI/TencentOAuth.h")
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#define QQEnabled 1
#else
#define QQEnabled 0
#endif

#if __has_include("WechatOpenSDK/WXApi.h")
#import <WechatOpenSDK/WXApi.h>
#import <WechatOpenSDK/WXApiObject.h>
#define WechatEnabled 1
static BOOL g_WechatRegisterFlag = NO;
#else
#define WechatEnabled 0
#endif

#if __has_include("Weibo_SDK/WeiboSDK.h")
#import <Weibo_SDK/WeiboSDK.h>
#define WeiboEnabled 1
static BOOL g_WeiboRegisterFlag = NO;
#else
#define WeiboEnabled 0
#endif

@interface MBShareManager () <
    ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding,
#if QQEnabled
    QQApiInterfaceDelegate,
    TencentSessionDelegate,
#endif
#if WechatEnabled
    WXApiDelegate,
#endif
#if WeiboEnabled
    WeiboSDKDelegate,
#endif
    UIApplicationDelegate
>
@property MBGeneralCallback lastCallback;
@property MBGeneralCallback restoreCallback;
#if QQEnabled
@property (null_resettable, nonatomic) TencentOAuth *qqAuthObject;
#endif
@end

@implementation MBShareManager

+ (instancetype)defaultManager {
    static id sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    [AppDelegate() addAppEventListener:self];
    return self;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
#if WechatEnabled
    if (g_WechatRegisterFlag) {
        if ([url.scheme hasPrefix:@"wx"]) {
            // 是微信回调，支付回调不应处理
            if ([url.host isEqualToString:@"pay"]) return NO;
        }
        if ([WXApi handleOpenURL:url delegate:self]) return YES;
    }
#endif
#if QQEnabled
    if ([QQApiInterface handleOpenURL:url delegate:self]) return YES;
    if ([TencentOAuth CanHandleOpenURL:url]) {
        if ([TencentOAuth HandleOpenURL:url]) return YES;
    }
#endif
#if WeiboEnabled
    if (g_WeiboRegisterFlag) {
        if ([WeiboSDK handleOpenURL:url delegate:self]) {
            return YES;
        }
    }
#endif
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
#if WechatEnabled
    if (g_WechatRegisterFlag) {
        if ([WXApi handleOpenUniversalLink:userActivity delegate:self]) return YES;
    }
#endif
    if (![userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) return NO;
    NSURL *url = userActivity.webpageURL;
    if (!url) return NO;
#if QQEnabled
    if ([QQApiInterface handleOpenUniversallink:url delegate:self]) return YES;
    if ([TencentOAuth CanHandleUniversalLink:url]) {
        return [TencentOAuth HandleUniversalLink:url];
    }
#endif
    return NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.restoreCallback = self.lastCallback;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    MBGeneralCallback cb = self.lastCallback;
    if (!cb) {
        self.restoreCallback = nil;
        return;
    }
    if (self.restoreCallback != cb) return;
    // 切换到微信、QQ 手动返回或取消返回，SDK 不会调通知方法，需手动取消
    self.restoreCallback = nil;
    self.lastCallback = nil;
#if QQEnabled
    self.qqAuthObject = nil;
#endif
    cb(NO, nil, nil);
}

#pragma mark - WeChat 通讯

#if WechatEnabled
+ (NSString *)wechatAppID {
    for (NSDictionary *item in NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"]) {
        NSArray<NSString *> *schemes = item[@"CFBundleURLSchemes"];
        if (![schemes isKindOfClass:NSArray.class]) continue;
        NSString *s = schemes.firstObject;
        if (![s isKindOfClass:NSString.class]) continue;
        if ([s hasPrefix:@"wx"]) {
            return s;
        }
    }
    return nil;
}

+ (void)registerWechatIfNeeded {
    if (g_WechatRegisterFlag) return;
    NSString *appid = self.wechatAppID;
    RFAssert(appid.length, @"请先在 Info.plist 中设置微信的回调链接");
    [WXApi registerApp:appid universalLink:@"https://example.com"];
    g_WechatRegisterFlag = YES;
}

+ (int)WXSceneFromType:(MBShareType)type {
    switch (type) {
        case MBShareTypeWechatSession:
            return WXSceneSession;
        case MBShareTypeWechatTimeline:
            return WXSceneTimeline;
        case MBShareTypeWechatFavorite:
            return WXSceneFavorite;
        default:
            return MBShareTypeInvaild;
    }
}

+ (BOOL)isWechatEnabled {
    return [WXApi isWXAppInstalled];
}

- (BOOL)_prepareWechatShareWithCB:(MBGeneralCallback)cb {
    if (!self.class.isWechatEnabled) {
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"你未安装微信，无法进行分享，请下载安装最新版微信"]);
        return NO;
    }
    [self.class registerWechatIfNeeded];
    return YES;
}

- (void)sendWechatRequest:(__kindof BaseReq *)req {
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) return;
        MBGeneralCallback cb = self.lastCallback;
        if (!cb) return;
        self.lastCallback = nil;
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"调起微信失败"]);
    }];
}
#else
+ (BOOL)isWechatEnabled {
    return NO;
}
#endif

#pragma mark - 微信/QQ 共享回调

// 微信终端向第三方程序发起请求，要求第三方程序响应
// 第三方程序响应完后必须调用sendRsp返回
// 在调用sendRsp返回时，会切回到微信终端程序界面
- (void)onReq:(id)req {

}

// 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调
// sendReq 请求调用后，会切到微信终端程序界面
- (void)onResp:(id)response {
#if WechatEnabled
    if ([response isKindOfClass:BaseResp.class]) {
        __kindof BaseResp *resp = response;
        dout(@"MBShareManager> Wechat response: %@(%d) %@", resp.class, resp.errCode, resp.errStr);
        MBGeneralCallback cb = self.lastCallback;
        self.lastCallback = nil;
        if (!cb) return;

        if ([resp isKindOfClass:SendAuthResp.class]) {
            // 登入的响应有诸多特殊情形要处理，摘出来
            SendAuthResp *r = resp;
            NSString *code = r.code;

            if (resp.errCode == WXSuccess
                && code.length) {
                cb(YES, @{ MBSocailLoginResultTokenKey: code }, nil);
                return;
            }
            // 除以上外全失败

            if (resp.errCode == WXErrCodeUserCancel
                // 无错误信息当成取消
                || !resp.errStr.length) {
                cb(NO, nil, nil);
                return;
            }
            cb(NO, nil, [NSError errorWithDomain:@"Wechat" code:resp.errCode localizedDescription:resp.errStr]);
            return;
        }   // END: SendAuthResp 特殊处理

        switch (resp.errCode) {
            case WXSuccess:
                cb(YES, nil, nil);
                return;
            case WXErrCodeUserCancel:
                cb(NO, nil, nil);
                return;
            default:
                cb(NO, nil, [NSError errorWithDomain:@"Wechat" code:resp.errCode localizedDescription:resp.errStr]);
                return;
        }
    }   // END: Wechat resp
#else
    if (NO) { }
#endif
    else {
#if QQEnabled
        QQBaseResp *resp = response;
        dout(@"MBShareManager> QQ response: %@ %@ %@", resp.result, resp.errorDescription, resp.extendInfo);
        self.qqAuthObject = nil;

        MBGeneralCallback cb = self.lastCallback;
        self.lastCallback = nil;
        if (!cb) return;
        int r = resp.result.intValue;
        switch (r) {
            case 0:
                cb(YES, nil, nil);
                return;
            case -4:
                cb(NO, nil, nil);
                return;

            default:
                cb(NO, nil, [NSError errorWithDomain:self.className code:r localizedDescription:resp.errorDescription]);
                return;
        }
#endif
    }   // END: QQ resp
}

#pragma mark - QQ 通讯

#if QQEnabled
+ (NSString *)qqAppID {
    for (NSDictionary *item in NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"]) {
        NSArray<NSString *> *schemes = item[@"CFBundleURLSchemes"];
        if (![schemes isKindOfClass:NSArray.class]) continue;
        NSString *s = schemes.firstObject;
        if (![s isKindOfClass:NSString.class]) continue;
        if ([s hasPrefix:@"tencent"]) {
            return [s stringByReplacingOccurrencesOfString:@"tencent" withString:@""];
        }
    }
    return nil;
}

- (void)tencentDidLogin {
    TencentOAuth *oa = self.qqAuthObject;
    self.qqAuthObject = nil;

    MBGeneralCallback cb = self.lastCallback;
    self.lastCallback = nil;
    if (!cb) return;

    if (!oa.accessToken.length) {
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"token 字段缺失"]);
        return;
    }
    NSMutableDictionary *info = [NSMutableDictionary.alloc initWithCapacity:3];
    [info rf_setObject:oa.accessToken forKey:MBSocailLoginResultTokenKey];
    [info rf_setObject:oa.openId forKey:MBSocailLoginResultUserIDKey];
    [info rf_setObject:oa.expirationDate forKey:MBSocailLoginResultExpirationKey];
    cb(YES, info, nil);
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    RFAssert(cancelled, nil); // 似乎只有取消能触发
    self.qqAuthObject = nil;

    MBGeneralCallback cb = self.lastCallback;
    self.lastCallback = nil;
    if (!cb) return;

    cb(NO, nil, nil);
}

- (void)tencentDidNotNetWork {
    self.qqAuthObject = nil;

    MBGeneralCallback cb = self.lastCallback;
    self.lastCallback = nil;
    if (!cb) return;

    cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"因网络问题无法登录，请检查网络"]);
}

- (void)isOnlineResponse:(NSDictionary *)response {

}

+ (BOOL)isQQEnabled {
    return [QQApiInterface isSupportShareToQQ];
}

+ (BOOL)isQQLoginEnabled {
    return [QQApiInterface isQQSupportApi];
}

- (TencentOAuth *)qqAuthObject {
    if (_qqAuthObject) return _qqAuthObject;
    NSString *appid = self.class.qqAppID;
    RFAssert(appid.length, @"请先在 Info.plist 中设置 tencent 回调链接");
    _qqAuthObject = [TencentOAuth.alloc initWithAppId:appid andDelegate:self];
    return _qqAuthObject;
}

- (void)sendQQContent:(__kindof QQApiObject *)content callback:(MBGeneralCallback)cb {
    SendMessageToQQReq *request = [SendMessageToQQReq reqWithContent:content];
    QQApiSendResultCode r = [QQApiInterface sendReq:request];
    if (r == EQQAPISENDSUCESS) {
        self.lastCallback = cb;
        return;
    }
    if (r == EQQAPIQQNOTINSTALLED) {
        cb(NO, nil, [NSError errorWithDomain:self.className code:r localizedDescription:@"QQ 未安装"]);
    }
    else {
        cb(NO, nil, [NSError errorWithDomain:self.className code:r localizedDescription:@"调起 QQ 失败"]);
    }
}
#else
+ (BOOL)isQQEnabled {
    return NO;
}
+ (BOOL)isQQLoginEnabled {
    return NO;
}
#endif

#pragma mark - 新浪微博通讯

#if WeiboEnabled
+ (NSString *)weiboAppID {
    for (NSDictionary *item in NSBundle.mainBundle.infoDictionary[@"CFBundleURLTypes"]) {
        NSArray<NSString *> *schemes = item[@"CFBundleURLSchemes"];
        if (![schemes isKindOfClass:NSArray.class]) continue;
        NSString *s = schemes.firstObject;
        if (![s isKindOfClass:NSString.class]) continue;
        if ([s hasPrefix:@"wb"]) {
            return [s stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        }
    }
    return nil;
}

+ (void)registerWeiboIfNeeded {
    if (g_WeiboRegisterFlag) return;
    NSString *appid = self.weiboAppID;
    RFAssert(appid.length, @"请先在 Info.plist 中设置微博的回调链接");
    [WeiboSDK registerApp:appid];
#if DEBUG
    [WeiboSDK enableDebugMode:YES];
#endif
    g_WeiboRegisterFlag = YES;
}

- (void)didReceiveWeiboResponse:(__kindof WBBaseResponse *)response {
    MBGeneralCallback cb = self.lastCallback;
    self.lastCallback = nil;
    if (!cb) return;

    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        WBAuthorizeResponse *r = response;

        NSString *userID = r.userID;
        NSString *token = r.accessToken;
        NSDate *expiration = r.expirationDate;
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            if (!userID || !token || !expiration) {
                cb(NO, nil, [NSError errorWithDomain:@"Weibo" code:0 localizedDescription:@"微博返回数据残缺"]);
                return;
            }
            cb(YES, @{
                MBSocailLoginResultTokenKey: token,
                MBSocailLoginResultUserIDKey: userID,
                MBSocailLoginResultExpirationKey: expiration
            }, nil);
            return;
        }
        // 继续一般处理
    }

    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
        cb(YES, nil, nil);
         return;
    }
    cb(NO, nil, [self _errorFromWeiboStatusCode:response.statusCode]);
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

- (NSError *)_errorFromWeiboStatusCode:(WeiboSDKResponseStatusCode)code {
    switch (code) {
        case WeiboSDKResponseStatusCodeSuccess:
        case WeiboSDKResponseStatusCodeUserCancel:
            return nil;
        case WeiboSDKResponseStatusCodeSentFail:
            return [NSError errorWithDomain:@"Weibo" code:code localizedDescription:@"发送失败"];
        case WeiboSDKResponseStatusCodeAuthDeny:
            return [NSError errorWithDomain:@"Weibo" code:code localizedDescription:@"授权失败"];
        case WeiboSDKResponseStatusCodeShareInSDKFailed:
            return [NSError errorWithDomain:@"Weibo" code:code localizedDescription:@"分享失败"];
        case WeiboSDKResponseStatusCodeUserCancelInstall:
            return [NSError errorWithDomain:@"Weibo" code:code localizedDescription:@"用户取消安装微博客户端"];
        case WeiboSDKResponseStatusCodeUnsupport:
            return [NSError errorWithDomain:@"Weibo" code:code localizedDescription:@"不支持的请求"];
        case WeiboSDKResponseStatusCodeUnknown:
        default:
            return [NSError errorWithDomain:@"Weibo" code:code localizedDescription:@"未知错误"];
    }
}

- (WBAuthorizeRequest *)_weiboAuthRequest {
    WBAuthorizeRequest *req = [WBAuthorizeRequest request];
    req.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    // https://open.weibo.com/wiki/Scope
    req.scope = @"email";
    req.shouldShowWebViewForAuthIfCannotSSO = YES;
    req.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    return req;
}
#endif

#pragma mark - 分享

// 分享调用
// https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Share_and_Favorites/iOS.html

- (void)shareLink:(NSURL *)link title:(NSString *)title description:(NSString *)description thumbImage:(id)thumb type:(MBShareType)type callback:(MBGeneralCallback)callback {
    MBGeneralCallback cb = MBSafeCallback(callback);
#if WeiboEnabled
    if (type == MBShareTypeSinaWeibo) {
        [self.class registerWeiboIfNeeded];
        WBAuthorizeRequest *authReq = [self _weiboAuthRequest];

        WBWebpageObject *webObject = WBWebpageObject.object;
        webObject.objectID = NSUUID.UUID.UUIDString;
        webObject.webpageUrl = link.absoluteString;
        webObject.title = title;
        webObject.description = description;
        if ([thumb isKindOfClass:UIImage.class]) {
            NSData *imageData = UIImageJPEGRepresentation((UIImage *)thumb, 0.8);
            NSData *thumbData = [self preparedThumbImageFromData:imageData shareType:type];
            webObject.thumbnailData = thumbData;
        }
        WBMessageObject *msg = WBMessageObject.message;
        msg.mediaObject = webObject;
        WBSendMessageToWeiboRequest *req = [WBSendMessageToWeiboRequest requestWithMessage:msg authInfo:authReq access_token:nil];
        if ([WeiboSDK sendRequest:req]) {
            self.lastCallback = cb;
            return;
        }
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"调起微博失败"]);
        return;
    }
#endif
#if QQEnabled
    if (type == MBShareTypeQQSession) {
        [self qqAuthObject];            // 分享前 auth 对象需要存在

        QQApiNewsObject *content = nil;
        if ([thumb isKindOfClass:NSString.class]) {
            thumb = [NSURL.alloc initWithString:thumb];
        }
        if ([thumb isKindOfClass:NSURL.class]) {
            content = [QQApiNewsObject objectWithURL:link title:title description:description previewImageURL:(NSURL *)thumb];
        }
        else if ([thumb isKindOfClass:UIImage.class]) {
            NSData *imageData = UIImageJPEGRepresentation((UIImage *)thumb, 0.8);
            NSData *thumbData = [self preparedThumbImageFromData:imageData shareType:type];
            content = [QQApiNewsObject objectWithURL:link title:title description:nil previewImageData:imageData];
            content.previewImageData = thumbData;
        }
        content.cflag = kQQAPICtrlFlagQQShare;
        [self sendQQContent:content callback:cb];
        return;
    }
#endif
#if WechatEnabled
    {
        if (![self _prepareWechatShareWithCB:cb]) return;

        WXMediaMessage *message = WXMediaMessage.message;
        message.title = title;
        message.description = description;
        if ([thumb isKindOfClass:UIImage.class]) {
            UIImage *image = thumb;
            if (image.pixelSize.width > 240 || image.pixelSize.height > 240) {
                image = [image imageAspectFillSize:CGSizeMake(240, 240) opaque:YES scale:1];
            }
            [message setThumbImage:image];
        }

        WXWebpageObject *ext = WXWebpageObject.object;
        ext.webpageUrl = link.absoluteString;
        message.mediaObject = ext;

        SendMessageToWXReq *req = SendMessageToWXReq.new;
        req.bText = NO;
        req.message = message;
        req.scene = [self.class WXSceneFromType:type];

        self.lastCallback = cb;
        [self sendWechatRequest:req];
        return;
    }
#endif
    cb(NO, nil, [NSError errorWithDomain:MBShareManager.className code:0 localizedDescription:@"暂不支持的分享"]);
}

- (void)shareImage:(UIImage *)image type:(MBShareType)type callback:(MBGeneralCallback)callback {
    MBGeneralCallback cb = MBSafeCallback(callback);
#if QQEnabled
    if (type == MBShareTypeQQSession) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSData *thumbData = [self preparedThumbImageFromData:imageData shareType:type];

        [self qqAuthObject];            // 分享前 auth 对象需要存在

        QQApiImageObject *content = [QQApiImageObject.alloc initWithData:imageData previewImageData:thumbData title:nil description:nil];
        content.cflag = kQQAPICtrlFlagQQShare;
        [self sendQQContent:content callback:cb];
        return;
    }
#endif
#if WechatEnabled
    {
        if (![self _prepareWechatShareWithCB:cb]) return;

        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 0.6);

        WXMediaMessage *message = WXMediaMessage.message;
        message.mediaObject = imageObject;

        SendMessageToWXReq *req = SendMessageToWXReq.new;
        req.bText = NO;
        req.message = message;
        req.scene = [self.class WXSceneFromType:type];

        self.lastCallback = cb;
        [self sendWechatRequest:req];
        return;
    }
#endif
    cb(NO, nil, [NSError errorWithDomain:MBShareManager.className code:0 localizedDescription:@"暂不支持的分享"]);
}

#pragma mark - 第三方登录

- (void)loginWechatComplation:(MBGeneralCallback)callback {
#if WechatEnabled
    [self.class registerWechatIfNeeded];
    MBGeneralCallback cb = MBSafeCallback(callback);
    SendAuthReq *req = SendAuthReq.new;
    req.scope = @"snsapi_userinfo";
    req.state = UIDevice.currentDevice.identifierForVendor.UUIDString;

    self.lastCallback = cb;
    [self sendWechatRequest:req];
#else
    NSAssert(NO, @"Wechat SDK 未导入");
#endif
}

- (void)loginQQComplation:(MBGeneralCallback)callback {
#if QQEnabled
    MBGeneralCallback cb = MBSafeCallback(callback);
    NSArray *permissions = @[
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                             kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_OTHER_INFO ];
    self.lastCallback = cb;
    self.qqAuthObject.authMode = kAuthModeClientSideToken;
    // QQ 在 authorize 方法调用内部有时就调结果，需要先设置 qqAuthObject 和 lastCallback
    if ([self.qqAuthObject authorizeWithQRlogin: permissions]) {
        return;
    }
    self.qqAuthObject = nil;
    self.lastCallback = nil;
    cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"调起 QQ 认证失败"]);
#else
    NSAssert(NO, @"QQ SDK 未导入");
#endif
}

- (void)loginWeiboComplation:(MBGeneralCallback)callback {
#if WeiboEnabled
    [self.class registerWeiboIfNeeded];
    MBGeneralCallback cb = MBSafeCallback(callback);

    WBAuthorizeRequest *req = [self _weiboAuthRequest];
    if ([WeiboSDK sendRequest:req]) {
        self.lastCallback = cb;
        return;
    }
    cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"调起微博失败"]);
#else
    NSAssert(NO, @"微博 SDK 未导入");
#endif
}

#pragma mark - Sign In with Apple

- (void)loginAppleIDComplation:(MBGeneralCallback)callback {
    MBGeneralCallback cb = MBSafeCallback(callback);
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDProvider *provide = [ASAuthorizationAppleIDProvider.alloc init];
        ASAuthorizationAppleIDRequest *request = provide.createRequest;
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

        ASAuthorizationController *ac = [ASAuthorizationController.alloc initWithAuthorizationRequests:@[ request ]];
        ac.delegate = self;
        ac.presentationContextProvider = self;
        [ac performRequests];
        self.lastCallback = cb;
    }
    else {
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"Sign In with Apple 需要至少 iOS 13"]);
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){
    MBGeneralCallback cb = self.lastCallback;
    self.lastCallback = nil;
    if (!cb) return;
    ASAuthorizationAppleIDCredential *ced = (id)authorization.credential;
    if (![ced isKindOfClass:ASAuthorizationAppleIDCredential.class]) {
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"认证凭据格式异常，重启试试？"]);
        return;
    }
    NSString *userID = ced.user;
    if (!userID.length) {
        cb(NO, nil, [NSError errorWithDomain:self.className code:0 localizedDescription:@"凭据异常，用户 ID 为空"]);
        return;
    }
    NSString *email = ced.email;
    NSPersonNameComponents *nameComponents = ced.fullName;
    NSString *userName = nil;
    if (nameComponents) {
        userName = [NSPersonNameComponentsFormatter localizedStringFromPersonNameComponents:nameComponents style:NSPersonNameComponentsFormatterStyleMedium options:0];
    }
    NSMutableDictionary *info = [NSMutableDictionary.alloc initWithCapacity:3];
    [info rf_setObject:userID forKey:MBSocailLoginResultUserIDKey];
    [info rf_setObject:userName forKey:MBSocailLoginResultUserNameKey];
    [info rf_setObject:email forKey:MBSocailLoginResultUserEmailKey];
    if (ced.identityToken) {
        [info rf_setObject:[NSString.alloc initWithData:ced.identityToken encoding:NSUTF8StringEncoding] forKey:MBSocailLoginResultTokenKey];
    }
    cb(YES, info, nil);
}
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0)){
    MBGeneralCallback cb = self.lastCallback;
    self.lastCallback = nil;
    if (!cb) return;
    if ([error.domain isEqualToString:ASAuthorizationErrorDomain]) {
        // 未启用两步验证取消时返回 unknown
        if (error.code == ASAuthorizationErrorCanceled) {
            error = nil;
        }
    }
    cb(NO, nil, error);
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    return UIApplication.sharedApplication.keyWindow;
}

#pragma mark -

- (nullable NSData *)preparedThumbImageFromData:(nonnull NSData *)data shareType:(MBShareType)type {
    RFAssert(data, nil);
    NSInteger maxLength = NSIntegerMax;
    switch (type) {
        case MBShareTypeWechatSession:
        case MBShareTypeWechatTimeline:
        case MBShareTypeWechatFavorite:
        case MBShareTypeSinaWeibo:
            maxLength = 32000;
            break;
        case MBShareTypeQQSession:
            maxLength = 1000000;
        default:
            break;
    }

    @autoreleasepool {
        if (data.length > maxLength) {
            UIImage *image = [UIImage imageWithData:data scale:2];
            image = [image imageAspectFillSize:CGSizeMake(120, 120) opaque:YES scale:2];
            if (!image) return nil;

            double quality = 0.6;
            do {
                data = UIImageJPEGRepresentation(image, quality);
                dout_int(data.length)
                if (!data) return nil;
                quality *= .7;
            } while (data.length > maxLength && quality > .1);
        }
    }
    return data;
}

@end

MBSocailLoginResultKey const MBSocailLoginResultTokenKey = @"token";
MBSocailLoginResultKey const MBSocailLoginResultUserIDKey = @"userID";
MBSocailLoginResultKey const MBSocailLoginResultExpirationKey = @"expiration";
MBSocailLoginResultKey const MBSocailLoginResultUserNameKey = @"userName";
MBSocailLoginResultKey const MBSocailLoginResultUserEmailKey = @"userEmail";
