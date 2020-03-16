/*
 MBCollectionViewDataSource
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import "MBListDataSource.h"

// @MBDependency:3
/**
 单一 sction，可从服务器上分页获取数据的数据源
 */
@interface MBCollectionViewDataSource : MBListDataSource <
    UICollectionViewDataSource
>

@property (weak, nullable) IBOutlet UICollectionView *collectionView;

#pragma mark -

/// 返回 cell 的 reuse identifier，默认实现返回 "Cell"
@property (null_resettable, nonatomic) NSString *__nonnull (^cellReuseIdentifier)(UICollectionView *__nonnull collectionView, NSIndexPath *__nonnull indexPath, id __nonnull item);

/// 对 cell 进行定制，默认实现尝试设置 item 属性
@property (null_resettable, nonatomic) void (^configureCell)(UICollectionView *__nonnull collectionView, __kindof UICollectionViewCell *__nonnull cell, NSIndexPath *__nonnull indexPath, id __nonnull item);

#pragma mark -

/**
 刷新可见 cell
 */
- (void)reconfigVisableCells;

/// 删除条目
- (void)removeItem:(nullable id)item;

@end
