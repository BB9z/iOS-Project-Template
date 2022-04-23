/*
 debug
 应用调试工具
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 Copyright © 2013-2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#pragma once

#import <Foundation/Foundation.h>
#import <RFKit/dout.h>

/**
 dout() 的行为可在 Build settings 的 Preprocessor Macros 项调节
 */

/**
 综合性调试方法，会在不同环境做合适的处理
 
 @param fatal 如果是 YES，在调试时会在这个位置停住
 @param recordID 非空时，会在正式和内测环境记录错误
 */
FOUNDATION_EXPORT void DebugLog(BOOL fatal, NSString *_Nullable recordID, NSString *_Nonnull format, ...) NS_FORMAT_FUNCTION(3, 4);

/**
 断言 obj 是 aClass
 
 @return obj 为空或时 aClass 返回 YES，类型不匹配返回 NO
 */
FOUNDATION_EXPORT BOOL RFAssertKindOfClass(id __nullable obj, Class __nonnull aClass);

/**
 断言在主线程
 
 @return YES 在主线程，NO 不在主线程
 */
FOUNDATION_EXPORT BOOL RFAssertIsMainThread(void);

/**
 断言在不主线程

 @return YES 不在主线程，NO 在主线程
 */
FOUNDATION_EXPORT BOOL RFAssertNotMainThread(void);

FOUNDATION_EXPORT unsigned long long MBApplicationMemoryUsed(void);
FOUNDATION_EXPORT unsigned long long MBApplicationMemoryAll(void);

#pragma mark - 网络调试

/// 如果你想模拟网络延迟，可以使用 Network Link Conditioner
/// 像 Charles 等代理软件也支持限速模拟
