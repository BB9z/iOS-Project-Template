/*!
 MBGeneralItemUpdating
 MBAppKit

 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

@protocol MBGeneralItemUpdating <NSObject>

@optional

#pragma mark - 界面更新

/**
 更新界面操作

 子类应该在开头调用 super
 */
- (void)updateUIForItem;

/**
 标记 model 更新了，需要刷新界面
 */
- (void)setNeedsUpdateUIForItem;

/**
 尝试立即更新界面，如果没有标记需要更新则不会更新

 默认会在 viewDidAppear: 时执行
 */
- (void)updateUIForItemIfNeeded;

#pragma mark - 数据获取

/**
 获取数据操作

 子类应该在结尾调用 super，默认实现不触发界面更新
 */
- (void)updateItem;

/**
 标记需要重新获取 Item
 */
- (void)setNeedsUpdateItem;

/**
 尝试立即获取新数据，如果没有标记需要更新则不会执行

 默认会在 viewDidAppear: 时执行
 */
- (void)updateItemIfNeeded;

@end
