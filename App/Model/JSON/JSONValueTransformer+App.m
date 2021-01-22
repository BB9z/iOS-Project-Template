/*
 JSONValueTransformer (App)
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBModel.h"

/**
 JSON Mode 的 ValueTransformer，用于将 JSON 类型转为其他类型
 
 通常用于时间转换，请根据项目格式进行调整
 */
@interface JSONValueTransformer (App)
@end

@implementation JSONValueTransformer (App)

/* 时间是浮点时间戳的实现

 #pragma clang diagnostic push
 #pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
 - (NSDate *)NSDateFromNSNumber:(NSNumber *)string {
     NSTimeInterval time = [string floatValue];
     return [NSDate dateWithTimeIntervalSince1970:time];
 }
 #pragma clang diagnostic pop

 - (NSDate *)NSDateFromNSString:(NSString*)string {
     NSTimeInterval time = [string floatValue];
     return [NSDate dateWithTimeIntervalSince1970:time];
 }

 - (NSString *)JSONObjectFromNSDate:(NSDate *)date {
     return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
 }
 */

@end
