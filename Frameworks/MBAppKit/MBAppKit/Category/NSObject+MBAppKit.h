/*!
 NSObject+MBAppKit
 MBAppKit

 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <Foundation/Foundation.h>

@interface NSObject (MBAppKit)

/// 类名字符串，Swift 类名只保留 . 最后的部分
@property (class, nonnull, readonly) NSString *className;

/// 类名字符串，Swift 类名只保留 . 最后的部分
@property (nonnull, readonly) NSString *className;

@end

/**
 比较两个对象，两个对象都是 nil 认为是相同的，要用 isEqual: 还得注意判空
 */
BOOL NSObjectIsEquail(id __nullable a, id __nullable b);
