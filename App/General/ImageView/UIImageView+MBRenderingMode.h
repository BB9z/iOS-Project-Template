/*
 UIImageView+MBRenderingMode

 Copyright © 2018, 2020 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>

/**
 从 iOS 7 开始，系统就支持将图片按照给的颜色渲染，
 直到 iOS 13，image view 对 tint color 的处理才完全正确。

 iOS 11+ 的具体问题是：
 * iOS 11-12，nib 中设置的 tint color 在启动后第一个页面无效
 * iOS 11-12，tintColor 需要设置一个跟上次不同的色值才会有效
 */
@interface UIImageView (MBRenderingMode)

// @MBDependency:2
/**
 设置时强制将图片按 UIImageRenderingModeAlwaysTemplate 方式渲染

 不会影响以后设置 image 和其它相关属性
 */
@property (nonatomic) IBInspectable BOOL renderingAsTemplate;
@end
