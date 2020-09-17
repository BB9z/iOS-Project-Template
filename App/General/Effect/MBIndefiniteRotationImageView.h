/*
 MBIndefiniteRotationImageView
 
 Copyright © 2018, 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 无限旋转的 image view

 UIImageView 自带的 isAnimating、startAnimating()、stopAnimating() 已支持
 */
@interface MBIndefiniteRotationImageView : UIImageView

/// 可以控制动画停止
/// 初始化后默认播放动画
@property (nonatomic) IBInspectable BOOL animationStopped;

/// 设置逆时针旋转，默认 NO 顺时针
@property IBInspectable BOOL counterClockwiseDirection;

#if TARGET_INTERFACE_BUILDER
@property IBInspectable double rotateDuration;
#else
/// 动画时间，动画已开始设置不会自动更新动画，停止后再开启才会生效
@property NSTimeInterval rotateDuration;
#endif

@end
