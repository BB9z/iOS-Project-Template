/*
 MBCollectionViewDataSource
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "MBListDataSource.h"

// @MBDependency:3
/**
 单一 section，可从服务器上分页获取数据的数据源
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

///
@property (nullable) UICollectionReusableView*_Nonnull (^viewForSupplementaryElement)(UICollectionView *__nonnull collectionView, NSString *__nonnull kind, NSIndexPath *__nonnull indexPath, id<UICollectionViewDataSource> __nullable delegate);

#pragma mark -

/**
 刷新可见 cell
 */
- (void)reconfigVisableCells;

/// 删除条目
- (void)removeItem:(nullable id)item;

@end
