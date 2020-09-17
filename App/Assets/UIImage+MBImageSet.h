/*
 UIImage+MBImageSet
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <UIKit/UIKit.h>

/**
 像工具的 icon，都是成套的，而且可能有很多套。过去的做法是写一个方法根据类型 switch 出相应的图片名来取出对应的图片，这样很不方便，加一个类型要各处改，套图有调整时容易遗忘，不熟悉的人不知道有哪些图，到哪找。
 
 有一种很简单的方式可以避免这种不便——直接把标识作为图片名的一部分。

 为了统一，我们需要约定一个命名规范，如下：
 
 zs_SETNAME_IDENTIFIER
 
 集合名+标识符的方式，加入 zs 前缀一是便于识别这是一套图，二是可以保证在搜索时结果准确。
 */
@interface UIImage (MBImageSet)

/**
 根据标识符取一套图中的相应图片

 @param set 集合名，需要以 zs_ 开头，为空抛出 NSInvalidArgumentException 异常
 @param identifier 图片标识符，可以是 NSString 或 NSNumber，number 会转为整型字符串。为空抛出 NSInvalidArgumentException 异常
 */
+ (nullable UIImage *)imageWithSetName:(nonnull NSString *)set identifier:(nonnull id)identifier;

@end
