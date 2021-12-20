/*!
 MBEntitiesTableView

 Copyright © 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFInitializing/RFInitializing.h>
#import <MBAppKit/MBAppKit.h>

// @MBDependency:2
/**
 一个简单快速的 table view 子类：

 - 数组作为单 section 的数据源
 - 默认 reuse identifier 为 "Cell"
 - Cell 点击时尝试执行 cell 的 onCellSelected 方法

 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
@interface MBEntitiesTableView<ItemType> : UITableView <
    RFInitializing,
    UITableViewDataSource,
    UITableViewDelegate
>
/// 设置时重载
@property (nonatomic, nullable) NSArray<ItemType> *items;

/**
 可选 cell 设置 block，默认直接给 item
 */
@property (nullable) void (^cellConfigBlock)(__kindof UITableViewCell *__nonnull cell, ItemType __nonnull item);

- (void)appendItem:(nullable ItemType)item;
- (void)removeItem:(nullable ItemType)item;
@end
