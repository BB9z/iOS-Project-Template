
#import "NSUserDefaults+App.h"
#import "Common.h"
#import <MBAppKit/MBModel.h>
#import <MBAppKit/MBUserDefaultsMakeProperty.h>

@implementation NSUserDefaults (App)

@dynamic lastUserID;
- (int64_t)lastUserID {
    return (int64_t)[(NSNumber *)[self objectForKey:@"_lastUserID"] longLongValue];
}
- (void)setLastUserID:(int64_t)lastUserID {
    [self setObject:@(lastUserID) forKey:@"_lastUserID"];
    ClassSynchronize
}
_makeModelProperty(accountEntity, setAccountEntity, AccountEntity);
_makeObjectProperty(userToken, setUserToken);

@end

#pragma mark - 用户存储

@implementation NSAccountDefaults (App)
@end
