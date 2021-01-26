/*
 MBBadgeLabel
 
 Copyright © 2018, 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 红点 label
 
 自动加圆角，调整大小和文字边距
 */
@interface MBBadgeLabel : UILabel

/**
 文字边距
 
 默认 { 2, 4, 2, 4 }
 */
@property UIEdgeInsets contentInset;
@property IBInspectable CGRect _contentInset;

/**
 大于 0 时，超出数量显示 maxCount+
 */
@property IBInspectable NSInteger maxCount;

/**
 设置显示数量

 为 0 隐藏
 */
- (void)updateCount:(NSInteger)count;

@end
