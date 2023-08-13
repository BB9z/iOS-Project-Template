/*!
 MBGeneralViewControllerStateTransitions
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 View controller 生命周期约定
 */
@protocol MBGeneralViewControllerStateTransitions <NSObject>

@optional

/**
 view 是否显示过，一般用于初始化逻辑
 
 一般在 viewDidLoad 方法置 NO，在 viewDidAppear 方法置为 YES
 */
//@property (readwrite) BOOL hasViewAppeared;

/**
 view controller 的 viewDidAppear: 方法不会在应用从后台切回前台调用，自定义 vc 容器通知子 vc 显示更新也没有现成的方法。这个方法就是为了解决这两种情况约定的。
 
 如何使用
 - 导航控制器在应用从后台切回前台时，应该在当前显示的 vc 上调用该方法
 - 自定义容器 vc 在切换多个子 vc 显示时调用该方法

 @warning 该方法目前没有配对的 disappear 方法，类似通知监听添加/移除的操作不应放在该方法中维护，一次出现可能会调用该方法多次
 */
- (void)MBViewDidAppear:(BOOL)animated;

@end
