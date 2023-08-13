/*!
 MBShareManager
 
 Copyright © 2018-2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import "MBGeneralCallback.h"

/// 分享类型
typedef NS_ENUM(int, MBShareType) {
    MBShareTypeInvaild = -1,
    
    /// 微信好友
    MBShareTypeWechatSession,
    
    /// 微信朋友圈
    MBShareTypeWechatTimeline,
    
    /// 微信收藏
    MBShareTypeWechatFavorite,

    /// QQ
    MBShareTypeQQSession,

    /// Sina 微博
    MBShareTypeSinaWeibo,
};

typedef NSString * MBSocailLoginResultKey NS_TYPED_ENUM;

/**
 三方分享、登入

 微信、QQ、微博等原生分享、登入实现

 ## 集成

 - Current.appDelegate 必须是 MBApplicationDelegate
 - 相应 SDK 集成到项目后自动启用对应渠道的功能
 - App key/ID 之类的无需额外声明，直接读取 Info.plist 中 CFBundleURLTypes
响应跳转中的设置
 - Universal Link 需手动改代码设置
 - 三方登入的 scope 调整需手动改代码

 ### 微信

 - 可通过 pod 'WechatOpenSDK' 导入
 - Info.plist 中 LSApplicationQueriesSchemes 数组添加 wexin、weixinULAPI
 - Info.plist 中 CFBundleURLTypes 数组中添加微信的跳转，形如（复制可直接粘入 plist 中）

@code
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist version="1.0"> <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>weixin</string>
        <key>CFBundleURLSchemes</key>
        <array>
                <string>wx012345678</string>
        </array>
</dict>
</plist>
@endcode

 ### QQ

 - 暂无官方 pod，到 https://wiki.connect.qq.com/sdk%E4%B8%8B%E8%BD%BD 下载
 - Info.plist 中 LSApplicationQueriesSchemes 数组添加
mqqopensdkapiV2、openQQWithURL、openTIMWithURL、openQQWithCommand、mqq、mqqapi、tim
 - Info.plist 中 CFBundleURLTypes 数组中添加 QQ 的跳转，形如（复制可直接粘入 plist 中）

@code
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist version="1.0"> <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>tencent</string>
        <key>CFBundleURLSchemes</key>
        <array>
                <string>tencent01245678</string>
        </array>
</dict>
</plist>
@endcode

 ### 新浪微博

 - pod 'Weibo_SDK'
 - 项目配置参考 https://github.com/sinaweibosdk/weibo_ios_sdk ，主要是 LSApplicationQueriesSchemes 和 ATS 配置
 - Info.plist 中 CFBundleURLTypes 数组中添加微博的跳转，形如（复制可直接粘入 plist 中）

@code
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd"> <plist version="1.0"> <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>sina_webo</string>
        <key>CFBundleURLSchemes</key>
        <array>
                <string>wb012345678</string>
        </array>
</dict>
</plist>
@endcode

 ## 特殊注意

 因为微信 SDK 回调机制的缺陷，当用户分享后没有立即返回 app，回调可能收不到。这种情况 MBShareManager 当作取消处理，因而取消不应提示给用户。

 */
@interface MBShareManager : NSObject

@property (class, readonly, nonnull) MBShareManager *defaultManager;

/// 是否可以分享到微信
@property (class, readonly) BOOL isWechatEnabled;
/// 是否可以分享到 QQ
@property (class, readonly) BOOL isQQEnabled;
/// 是否支持 QQ 登入
@property (class, readonly) BOOL isQQLoginEnabled;

#pragma mark - 分享

/**
 分享链接

 @param thumb QQ 分享时可以是 UIImage 或 NSURL，微信暂时只支持 UIImage
 */
- (void)shareLink:(nonnull NSURL *)link title:(nonnull NSString *)title description:(nullable NSString *)description thumbImage:(nullable id)thumb type:(MBShareType)type callback:(nullable MBGeneralCallback)callback;

/// 分享图片
- (void)shareImage:(nonnull UIImage *)image type:(MBShareType)type callback:(nullable MBGeneralCallback)callback;

#pragma mark - 三方登入

/**
 微信登入

 item 内容：token（对应 code）
 */
- (void)loginWechatComplation:(nullable MBGeneralCallback)callback;

/**
 QQ 登入

 item 内容：token（对应 accessToken）、userID（对应 openId）、expiration（对应 expirationDate）
 */
- (void)loginQQComplation:(nullable MBGeneralCallback)callback;

/**
 微博登入

 item 内容：token（对应 accessToken）、userID、expiration（对应 expirationDate）
 */
- (void)loginWeiboComplation:(nullable MBGeneralCallback)callback;

/**
 Apple ID 登入

 item 内容：userID、userName、userEmail，后两者仅第一次验证才返回
 */
- (void)loginAppleIDComplation:(nullable MBGeneralCallback)callback;
@end

NS_ASSUME_NONNULL_BEGIN
// 下面是第三方登录结果的字段
FOUNDATION_EXTERN MBSocailLoginResultKey const MBSocailLoginResultTokenKey      NS_SWIFT_NAME(token);
FOUNDATION_EXTERN MBSocailLoginResultKey const MBSocailLoginResultUserIDKey     NS_SWIFT_NAME(userID);
/// 过期时间，NSDate
FOUNDATION_EXTERN MBSocailLoginResultKey const MBSocailLoginResultExpirationKey NS_SWIFT_NAME(expiration);
/// 用户名，仅 Apple ID 登入返回
FOUNDATION_EXTERN MBSocailLoginResultKey const MBSocailLoginResultUserNameKey   NS_SWIFT_NAME(userName);
/// 用户邮箱，仅 Apple ID 登入返回
FOUNDATION_EXTERN MBSocailLoginResultKey const MBSocailLoginResultUserEmailKey  NS_SWIFT_NAME(userEmail);
NS_ASSUME_NONNULL_END

@protocol MBEntitySharing
@optional
- (void)shareLinkWithType:(MBShareType)type callback:(nullable MBGeneralCallback)callback;
@end
