/*
 MBKeyboardFloatContainer

 Copyright © 2018, 2020-2021 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <UIKit/UIKit.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:1
/**
 一般是界面底部的一个容器，键盘弹出来跟着向上浮动，键盘收起又回落了

 使用：
 - 连接 keyboardLayoutConstraint
 - 设置其他可选参数

 */
@interface MBKeyboardFloatContainer : UIView <
    RFInitializing
>

/**
 键盘弹出时会设置该约束为键盘高度，收起时设置成 0
 */
@property (weak, nullable) IBOutlet NSLayoutConstraint *keyboardLayoutConstraint;

/**
 可选，keyboardLayoutConstraint 变更时需要重新布局的 view

 如果 keyboardLayoutConstraint 是里层 view 的，只会通知里层 view 更新布局，但外层 view 也可能收到影响了，导致动画不同步
 */
@property (weak, nullable) IBOutlet UIView *needsLayoutView;

/**
 用于键盘收起时，调节约束的偏移量
 */
@property IBInspectable CGFloat keyboardLayoutOriginalConstraint;

/**
 用于键盘弹出时，调节约束的偏移量
 */
@property IBInspectable CGFloat offsetAdjust;

/**
 如果设置，弹出键盘时，点击该区域会隐藏键盘
 */
@property (weak, nullable) IBOutlet UIView *tapToDismissContainer;

/**
 键盘事件响应
 */
- (void)keyboardWillShow:(nonnull NSNotification *)note NS_REQUIRES_SUPER;
- (void)keyboardWillHide:(nonnull NSNotification *)note NS_REQUIRES_SUPER;

/**
 跳过接下来的隐藏键盘事件，直到键盘显示事件恢复正常处理

 用于优化手动隐藏紧接着显示键盘时的动画效果
 */
@property BOOL ignoreUpcomingHideNotificationUntilShow;

@end
