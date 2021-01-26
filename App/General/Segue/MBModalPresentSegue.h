/*
 MBModalPresentSegue
 
 Copyright © 2018-2020 BB9z.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFSegue/RFSegue.h>

// @MBDependency:4
/**
 弹出新的视图，与 view controller 内建的弹出方式不同之处在于不会隐藏当前视图，新视图不是加在当前视图的 view 中的，而是尽可能加在根视图中，会覆盖导航条
 
 destinationViewController 需要符合 MBModalPresentDestination 协议
 */
@interface MBModalPresentSegue : RFSegue

@end

/**
 从弹出层 push 到其他视图需使用本 segue，否则可能会导致布局问题，已知的是返回后，隐藏导航栏视图布局不会上移
 */
@interface MBModalPresentPushSegue : UIStoryboardSegue
@end

/**
 MBModalPresentPushSegue 的 destination 只需符合该协议
 */
@protocol MBModalPresentDestination <NSObject>
@required
- (void)presentFromViewController:(nonnull UIViewController *)parentViewController animated:(BOOL)animated completion:(nullable void (^)(void))completion;
@end

#pragma mark - Present ViewController

/**
 可以用 MBModalPresentPushSegue 弹出的一个实现
 */
@interface MBModalPresentViewController : UIViewController <
    MBModalPresentDestination
>

#pragma mark 效果相关

/**
 控制弹出的样式和布局位置

 actionSheet 从底部平移显示出来，展现后固定到底部，alert 从下方有个固定距离的浮现，展现后的位置和初始位置一致
 默认 actionSheet
 */
@property (nonatomic) UIAlertControllerStyle preferredStyle;

/// 遮罩层，用于覆盖底部的其他页面
@property (weak, nullable, nonatomic) IBOutlet UIView *maskView;

/// 内容容器
@property (weak, nullable, nonatomic) IBOutlet UIView *containerView;

/// 子类重写以改变动效
- (void)setViewHidden:(BOOL)hidden animated:(BOOL)animated completion:(nullable void (^)(void))completion;

#pragma mark 弹出控制

/**
 从其他视图弹出
 */
- (void)presentFromViewController:(nullable UIViewController *)parentViewController animated:(BOOL)animated completion:(nullable void (^)(void))completion;

/// MBModalPresent 的标准 dismiss 方法
- (void)dismissAnimated:(BOOL)animated completion:(nullable void (^)(void))completion NS_SWIFT_NAME( dismissSelf(animated:completion:) );

/// 退出弹窗
- (IBAction)dismiss:(nullable id)sender;

/// 默认 segue 跳转时自动退出弹窗
@property IBInspectable BOOL disableAutoDismissWhenSegueTriggered;

/// 即将退出弹窗时调用
@property (nullable) void (^willDismiss)(__kindof MBModalPresentViewController *__nonnull vc);

@end
