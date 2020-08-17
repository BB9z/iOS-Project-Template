//
//  UserDefaults 字段定义
//  App
//

#import <MBAppKit/MBGeneralType.h>
#import <MBAppKit/MBUserDefaults.h>

@class AccountEntity;

/**
 迁移到 Swift 版本动力不足，定义与使用优势暂不明显，有 Codable 需求时再说

 参见技术选型 https://github.com/BB9z/iOS-Project-Template/wiki/%E6%8A%80%E6%9C%AF%E9%80%89%E5%9E%8B#userdefaults
 */
@interface NSUserDefaults (App)

/// 上次启动时间
@property (nullable, copy) NSDate *applicationLastLaunchTime;

/// 上次启动时版本
@property (nullable, copy) NSString *lastVersion;

/// 上次更新版本时的版本
@property (nullable, copy) NSString *previousVersion;

/// App 总启动次数
@property NSInteger launchCount;

/// 当前版本启动次数
@property NSInteger launchCountCurrentVersion;

#pragma mark - User Information

#if MBUserStringUID
@property (nullable) MBIdentifier lastUserID;
#else
@property int64_t lastUserID;
#endif

@property (nullable, copy) AccountEntity *accountEntity;
@property (nullable, copy) NSString *userToken;

@end

#pragma mark - 用户存储

@interface NSAccountDefaults (App)

@end
