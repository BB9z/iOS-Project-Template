/*
 MBKeyboardFloatContainer
 
 Copyright © 2018, 2020 RFUI.
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardLayoutConstraint;

/**
 用于键盘收起时，调节约束的偏移量
 */
@property (nonatomic) IBInspectable CGFloat keyboardLayoutOriginalConstraint;

/**
 用于键盘弹出时，调节约束的偏移量
 */
@property (nonatomic) IBInspectable CGFloat offsetAdjust;

/**
 如果设置，弹出键盘时，点击该区域会隐藏键盘
 */
@property (nonatomic, weak) IBOutlet UIView *tapToDismissContainer;

/**
 键盘事件响应
 */
- (void)keyboardWillShow:(NSNotification *)note NS_REQUIRES_SUPER;
- (void)keyboardWillHide:(NSNotification *)note NS_REQUIRES_SUPER;

@end
