/*
 NSRegularExpression+App

 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import "UIKit+App.h"

@interface NSRegularExpression (App)

/// 中日韩字符 的正则
@property (class, readonly, nonnull) NSRegularExpression *CJKCharRegularExpression;

@end
