/*
 MBControlGroup

 Copyright © 2018-2020 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <MBAppKit/MBAppKit.h>

@protocol MBControlGroupDelegate;

// @MBDependency:4
/**
 用于管理一组 UIControl 的选择状态，这组 UIControl 同时只有一个处于 selected 状态
 
 当选中的控件发生变化时会发送 UIControlEventValueChanged 事件，
 但注意已选中控件没有实际变化时也可能发送 UIControlEventValueChanged 事件。
 
 这个类可以有多种用法，一般有：
 1. 作为 NSObject 而不是一个视图使用，用来控制逻辑，可以在 IB 中加入一个 NSObject 修改类，然后连接 controls 等属性，继承 UIControl 只是为了便于发送事件
 2. 作为子控件的父 view 静态使用，有几个按钮、默认选中哪个，均可以（并且是可选的）在 IB 中连线实现
 3. 作为子控件的父 view 动态使用，Control group 会管理布局，动态增减子按钮布局会随之更新，或者使用 UIStackView 管理按钮布局
 */
@interface MBControlGroup : UIControl <
    UIFocusItem,
    RFInitializing
>
/**
 如果 controls 未设置，从 nib 中载入后，自动把 stackLayoutView 或子 view 中是 UIControl 的 view 设置为 controls

 不确定是 Xcode bug 还是系统的，IBOutletCollection 实际加载顺序有时和 IB 的不一致，这样 index 就错了，安全起见可设置 tag 值并以此强制重排一下。因此建议自动加载不手动设置
 */
@property (nullable, nonatomic) IBOutletCollection(UIControl) NSArray *controls;

/// 当前选中的控件
@property (weak, nullable, nonatomic) IBOutlet UIControl *selectedControl;

/**
 切换选中控件

 子类如需切换控件时的定制可重载此方法
 */
- (void)setSelectedControl:(nullable UIControl *)selectedControl animated:(BOOL)animated;

/// 选中控件的 index，未选中任何控件是 NSNotFound
@property (nonatomic) NSInteger selectIndex;

/// 切换选中控件
- (void)setSelectIndex:(NSInteger)selectIndex animated:(BOOL)animated;

/// 设为 YES 当再次点击已选择控件时将取消该控件的选择状态，默认 NO
@property IBInspectable BOOL deselectWhenSelection;

/// 重写以修改选中效果
- (void)selectControl:(nonnull UIControl *)control;
- (void)deselectControl:(nonnull UIControl *)control;

/**
 切换操作的最短间隔，防止用户连点
 
 非 0 时，如果当前切换距上一次切换的时间短于给定阈值，则取消当前切换；
 同时，这个限制只针对用户点击触发，通过代码设置当前选中不会被取消
 */
#if TARGET_INTERFACE_BUILDER
@property IBInspectable double minimumSelectionChangeInterval;
#else
@property NSTimeInterval minimumSelectionChangeInterval;
#endif

/**
 默认 YES，只在用户点子按钮时告知 delegate tab 切换

 为 NO 时只要 selectedIndex 变化就会通知 delegate
 */
@property IBInspectable BOOL selectionNoticeOnlySendWhenButtonTapped;

#pragma mark - Layout

/**
 如果非空，将使用该 UIStackView 进行布局，下列的 layout 属性失效
 */
@property (weak, nullable) IBOutlet UIStackView *stackLayoutView;

// layout 相关属性都不是修改后立即生效的，但会在下次布局时使用
// 如果需要变化立即生效，可以手动调用 setNeedsLayout

/**
 设为 YES 会自行调整子控件的布局，默认 NO

 自行布局只会控制 controls 属性中的 view，且这些控件必需是 control group 的直接子 view，
 其它子 view 的布局不会做特殊调整。设为自行布局后，会去掉子控件除尺寸大小外的其它约束，
 控件间有等宽等高这样的约束也会被移除
 */
@property IBInspectable BOOL selfLayoutEnabled;

/// 控件间距，默认 0
@property IBInspectable CGFloat itemSpacing;

/// 控件距 frame 边框的边距
@property UIEdgeInsets itemInsets;
@property IBInspectable CGRect _itemInsets;

- (void)updateSelfLayout;

#pragma mark - Delegate

@property (nullable, weak) IBOutlet id<MBControlGroupDelegate> delegate;

@end


@protocol MBControlGroupDelegate <NSObject>
@optional

/// 将选中一个控件前（可能是已选中的）调用，取消选中不调用
- (BOOL)controlGroup:(nonnull MBControlGroup *)controlGroup shouldSelectControlAtIndex:(NSInteger)index;

@end
