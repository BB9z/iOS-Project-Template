//
//  UserDefaults 字段定义
//  App
//

#import <MBAppKit/MBGeneralType.h>
#import <MBAppKit/MBUserDefaults.h>

@class AccountEntity;

/**
 迁移到 Swift 版本动力不足，没有让定义与使用变得更轻松：
 key 多需要额外定义，用时也多需额外声明，不方便。
 */
@interface NSUserDefaults (App)

@property int64_t lastUserID;

@property (nullable, copy) AccountEntity *accountEntity;
@property (nullable, copy) NSString *userToken;

@end

#pragma mark - 用户存储

@interface NSAccountDefaults (App)

@end
