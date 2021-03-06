
#import "NSUserDefaults+App.h"
#import "Common.h"
#import <MBAppKit/MBModel.h>
#import <MBAppKit/MBUserDefaultsMakeProperty.h>

@implementation NSUserDefaults (App)

_makeObjectProperty(applicationLastLaunchTime, setApplicationLastLaunchTime)
_makeObjectProperty(lastVersion, setLastVersion)
_makeObjectProperty(previousVersion, setPreviousVersion)

_makeIntegerProperty(launchCount, setLaunchCount)
_makeIntegerProperty(launchCountCurrentVersion, setLaunchCountCurrentVersion)

#if MBUserStringUID
_makeObjectProperty(lastUserID, setLastUserID);
#else
@dynamic lastUserID;
- (int64_t)lastUserID {
    return (int64_t)[(NSNumber *)[self objectForKey:@"_lastUserID"] longLongValue];
}
- (void)setLastUserID:(int64_t)lastUserID {
    [self setObject:@(lastUserID) forKey:@"_lastUserID"];
    ClassSynchronize
}
#endif
_makeModelProperty(accountEntity, setAccountEntity, AccountEntity);
_makeObjectProperty(userToken, setUserToken);

@end

#pragma mark - 用户存储

@implementation NSAccountDefaults (App)

- (instancetype)initWithSuiteName:(NSString *)suitename {
    self = [super initWithSuiteName:suitename];
    if (![[MBApp status].version isEqualToString:self.lastVersion]) {
        [self updateFromVersion:self.lastVersion];
    }
    return self;
}

/// 版本迁移，移除旧的key
- (void)updateFromVersion:(NSString *)currentVersion {
    // 前面的版本写当前版本
//    if ([@"2.6.2" compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
//        [self removeObjectForKey:@"GoalHealthRecordForShare"];
//    }
    self.lastVersion = currentVersion;
    [self synchronize];
}

@end
