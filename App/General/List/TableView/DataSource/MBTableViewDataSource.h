/*
 MBTableViewDataSource
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBListDataSource.h"

// @MBDependency:4
@interface MBTableViewDataSource<CellType, ItemType> : MBListDataSource <
    UITableViewDataSource
>
@property (weak, nullable, nonatomic) IBOutlet UITableView *tableView;

/// 暂不可用
@property (weak, nullable, nonatomic) id<UITableViewDataSource> delegate;

/**
 完成后，列表已经刷新完毕
 */
- (void)fetchItemsFromViewController:(nullable id)viewController nextPage:(BOOL)nextPage success:(void (^__nullable)(MBTableViewDataSource *__nonnull dateSource, NSArray *__nonnull fetchedItems))success completion:(void (^__nullable)(MBTableViewDataSource *__nonnull dateSource))completion;

/**
 清除列表中已加载数据并重置状态，以便重新获取数据
 */
- (void)clearData;

/**
 Tableview 重载时是否添加动画
 
 @warning `YES` 有问题

 默认 `NO`
 */
@property IBInspectable BOOL animationReload;

/**
 获取第一页时禁用动画效果

 默认 `NO`
 */
@property IBInspectable BOOL animationReloadDisabledOnFirstPage;

#pragma mark - Cell 配置

/**
 可选，默认 Cell
 */
@property (null_resettable, nonatomic) NSString *__nonnull (^cellReuseIdentifier)(UITableView *__nonnull tableView, NSIndexPath *__nonnull indexPath, ItemType __nonnull item);

/**
 可选，默认在 cell 上执行 setItem 方法
 */
@property (null_resettable, nonatomic) void (^configureCell)(UITableView *__nonnull tableView, CellType __nonnull cell, NSIndexPath *__nonnull indexPath, ItemType __nonnull item);

#pragma mark -

/**
 刷新可见 cell
 */
- (void)reconfigVisableCells;

/// 删除条目
- (void)removeItem:(nullable ItemType)item withRowAnimation:(UITableViewRowAnimation)animation;

/// 添加到末尾
- (nullable NSIndexPath *)appendItem:(nullable ItemType)item withRowAnimation:(UITableViewRowAnimation)animation;

@end
