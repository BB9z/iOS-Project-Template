/*
 MBTabController
 
 Copyright © 2018-2019 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFAlpha/RFPageTabController.h>
#import "MBGeneralListDisplaying.h"
#import "MBTabControl.h"

// @MBDependency:2
/**
 
 */
@interface MBTabController : RFPageTabController <
    RFTabControllerDelegate,
    MBGeneralListDisplaying
>
@property (weak, nullable, nonatomic) IBOutlet MBTabControl *tabControl;

/**
 设置 tab controller 的 navigationItem 左右按钮为当前 vc 的
 
 默认 NO，不会设置 title 或 titleView
 */
@property IBInspectable BOOL shouldSetNavigationBarButtonItemsToSelectedViewController;

#pragma mark - 切换事件

/**
 当前 vc 切换前后调用，供子类重载

 will did 可以保证成对出现，否则可能是个 bug
 
 默认什么也不做
 */
- (void)willSelectViewController:(nullable UIViewController *)viewController atIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)didSelectViewController:(nullable UIViewController *)viewController atIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 当前 vc 切换时调研，子类可重载
 
 默认做了不少事：尝试管理列表的 scrollsToTop 属性，尝试刷新未获取数据的列表，管理 APIGroupIdentifier 并取消之前 vc 的请求，可选设置导航 item
 */
- (void)updatesForSelectedViewControllerChanged:(nullable __kindof UIViewController *)selectedViewController animated:(BOOL)animated;

/// 标识当前切换是用户点击 tab 切换的还是用户滑动或代码调用
@property BOOL isTapTabControlSwichPage;

@end
