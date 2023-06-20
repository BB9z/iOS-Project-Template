/*!
 MBButton
 MBAppKit
 
 Copyright © 2018, 2021 RFUI.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

/**
 按钮基类

 主要用于外观定制
 */
@interface MBButton : UIButton <
    RFInitializing
>

/**
 样式名，以便让同一个按钮类支持多个样式
 
 一般在 setupAppearance 根据 styleName 做相应配置
 */
@property (nullable) IBInspectable NSString *styleName;

/**
 子类重写该方法设置外观
 
 外观设置的时机是在 button 初始化后尽可能的早，在初始化时就不能通过 skipAppearanceSetup 略过设置，太晚可能会覆盖正常业务代码的设置。从 nib 载入的设置时机稳定在 awakeFromNib，通过代码创建时时机不定，可通过 appearanceSetupDone 属性辅助判断
 
 通常不用调用 super
 
 @code
- (void)setupAppearance {
    [self setBackgroundImage:[UIImage imageNamed:@"button_white_disabled"] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"button_white_normal"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"button_white_highlighted"] forState:UIControlStateHighlighted];

    [self setTitleColor:[UIColor colorWithRGBHex:0xCCCCCC] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor colorWithRGBHex:0x157EFB] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithRGBHex:0xFFFFFF] forState:UIControlStateHighlighted];
}
 @endcode
 */
- (void)setupAppearance;

/**
 子类重写，当按钮尺寸变化时执行
 */
- (void)setupAppearanceAfterSizeChanged;

/**
 外观代码设置完成标记，一般只有通过代码创建 button 时才需要判断
 */
@property (readonly) BOOL appearanceSetupDone;

@property (nonatomic) IBInspectable BOOL skipAppearanceSetup;

#pragma mark -

/**
 扩展按钮可响应点击的区域
 */
@property (nonatomic) UIEdgeInsets touchHitTestExpandInsets;
@property (nonatomic) IBInspectable CGRect _touchHitTestExpandInsets;

/**
 非空时按钮原有的点击事件不在发送，而改为执行该 block
 
 设计时的场景是增加一种禁用状态，可以点击但不走正常的事件
 */
@property (nullable) void (^blockTouchEvent)(void);

/**
 点击按钮时执行的操作，默认什么也不做
 */
- (void)onButtonTapped;

@end

/**
 作为按钮容器，解决按钮在 view 的 bounds 外不可点的问题
 */
@interface MBControlTouchExpandContainerView : UIView
@property (nonatomic, nullable) IBOutletCollection(UIControl) NSArray *controls;
@end
