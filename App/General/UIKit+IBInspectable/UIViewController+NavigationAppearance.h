/*
 UIViewController+NavigationAppearance
 
 Copyright © 2016-2018, 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFAlpha/RFNavigationController.h>

/**
 在 Interface Builder 中直接定义 vc 相关样式
 */
@interface UIViewController (NavigationAppearance)

/// 隐藏状态栏？
@property IBInspectable BOOL RFPrefersStatusBarHidden;

/// 状态栏浅色文字？
@property IBInspectable BOOL RFPrefersLightContentBarStyle;

/// 隐藏导航栏？
@property IBInspectable BOOL RFPrefersNavigationBarHidden;

/// 导航栏颜色
@property (nullable, copy) IBInspectable UIColor *RFPreferredNavigationBarColor;

/// 需要显示底部 tab？
@property IBInspectable BOOL RFPrefersBottomBarShown;

/// 阻止侧滑返回手势
@property IBInspectable BOOL RFPrefersDisabledInteractivePopGesture;

/// 透明导航
@property IBInspectable BOOL pefersTransparentBar;

- (nullable NSMutableDictionary<RFViewControllerAppearanceAttributeKey, id> *)RFNavigationAppearanceAttributes;

@end

FOUNDATION_EXTERN RFViewControllerAppearanceAttributeKey const _Nonnull RFViewControllerPefersTransparentBar;
