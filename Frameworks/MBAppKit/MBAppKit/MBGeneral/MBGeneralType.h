/*!
 MBGeneralType
 MBAppKit
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 
 定义一些有语义的类型，避免混用导致的逻辑错误
 */
#import <Foundation/Foundation.h>

#pragma mark - ID

/// 整形 ID
typedef int64_t MBID;

#pragma mark - 时间

/// 整形时长，秒
typedef NS_ENUM(int, MBDateIntDuration) {
    MBDateIntDurationUndifined = INT_MAX
};
/// 整形时间戳，毫秒
typedef NS_ENUM(long long, MBDateTimeStamp) {
    MBDateTimeStampUndifined = LONG_LONG_MAX
};
/// 浮点时长、时间戳统一使用 NSTimeInterval

/// 专用于标示日期哪一天
typedef NSString* MBDateDayIdentifier;

/**
 NSDate 的什么也没重写的子类，为了让 JSONModel 同时支持接口中正常的时间戳和毫秒时间
 */
@interface NSMilliDate : NSDate
@end
