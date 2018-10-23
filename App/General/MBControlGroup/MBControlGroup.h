/*
 MBControlGroup

 Copyright © 2018 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <MBAppKit/MBAppKit.h>

@protocol MBControlGroupDelegate;

/**
 用于管理一组 UIControl 的选择状态，这组 UIControl 同时只有一个处于 selected 状态
 
 当选中的控件发生变化时会发送 UIControlEventValueChanged 事件，
 但注意已选中控件没有实际变化时也可能发送 UIControlEventValueChanged 事件。
 
 这个类可以有多种用法，一般有：
 1. 作为 NSObject 而不是一个视图使用，用来控制逻辑，可以在 IB 中加入一个 NSObject 修改类，然后连接 controls 等属性，继承 UIControl 只是为了便于发送事件
 2. 作为子控件的父 view 静态使用，有几个按钮、默认选中哪个，均可以（并且是可选的）在 IB 中连线实现
 3. 作为子控件的父 view 动态使用，Control group 会管理布局，动态增减子按钮布局会随之更新
 */
@interface MBControlGroup : UIControl <
    RFInitializing
>
@property (nonatomic, nullable) IBOutletCollection(UIControl) NSArray *controls;

@property (nonatomic, nullable, weak) IBOutlet UIControl *selectedControl;
- (void)setSelectedControl:(nullable UIControl *)selectedControl animated:(BOOL)animated;

/// 选中控件的 index，未选中任何控件是 NSNotFound
@property (nonatomic) NSInteger selectIndex;
- (void)setSelectIndex:(NSInteger)selectIndex animated:(BOOL)animated;

/// 设为 YES 当再次点击已选择控件时将取消该控件的选择状态，默认 NO
@property IBInspectable BOOL deselectWhenSelection;

/// 重写以修改选中效果
- (void)selectControl:(nonnull UIControl *)control;
- (void)deselectControl:(nonnull UIControl *)control;

/**
 切换操作的最短间隔
 
 非 0 时，如果当前切换距上一次切换的时间短于给定阈值，则取消当前切换；
 同时，这个限制只针对用户点击触发，通过代码设置当前选中不会被取消
 */
#if TARGET_INTERFACE_BUILDER
@property IBInspectable double minimumSelectionChangeInterval;
#else
@property NSTimeInterval minimumSelectionChangeInterval;
#endif

/**
 设为 YES，只在用户点子按钮时告知 delegate tab 切换，否则只要 selectedIndex 变化就会通知 delegate

 这个开关本不应该存在，应该默认开启。但因为历史原因，涉及代码太多，未默认开启，子类应该默认开启
 */
@property IBInspectable BOOL selectionNoticeOnlySendWhenButtonTapped;

#pragma mark - Layout
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
#if TARGET_INTERFACE_BUILDER
@property IBInspectable CGRect itemInsets;
#else
@property UIEdgeInsets itemInsets;
#endif

#pragma mark - Delegate

@property (nullable, weak) IBOutlet id<MBControlGroupDelegate> delegate;

@end


@protocol MBControlGroupDelegate <NSObject>
@optional

/// 将选中一个控件前（可能是已选中的）调用，取消选中不调用
- (BOOL)controlGroup:(nonnull MBControlGroup *)controlGroup shouldSelectControlAtIndex:(NSInteger)index;

@end
