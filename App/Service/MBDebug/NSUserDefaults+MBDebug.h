/*
 NSUserDefaults+MBDebug
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <MBAppKit/MBUserDefaults.h>

/**
 调试工具配置项
 */
@interface NSUserDefaults (MBDebug)

/// 接口请求 SSL 安全性最小化，便于抓包调试
@property BOOL _debugAPIAllowSSLDebug;

@end
