/*
 MBCollectionView
 
 Copyright © 2018, 2021 BB9z.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import "MBCollectionRefreshFooterView.h"
#import "MBCollectionViewDataSource.h"

// @MBDependency:1
@interface MBCollectionView : UICollectionView <
    RFInitializing
>
/**
 类里已内置了一个强引用的 MBCollectionViewDataSource

 外部不要直接使用 data source 的数据拉取方法，请使用 view 包装的
 */
@property (weak, null_resettable, nonatomic) MBCollectionViewDataSource *dataSource;

- (void)fetchItemsNextPage:(BOOL)nextPage success:(void (^__nullable)(MBCollectionViewDataSource *__nonnull dateSource, NSArray *__nullable fetchedItems))success completion:(void (^__nullable)(MBCollectionViewDataSource *__nonnull dateSource))completion;

/**
 移动到 window 时，如果之前数据没有成功加载，则尝试获取数据，默认关
 */
@property IBInspectable BOOL autoFetchWhenMoveToWindow;

/**
 在开始刷新开始前调整可视范围

 默认滚动使第一个 cell 位于顶部
 */
@property (nullable) void (^adjustOffsetBeforeReload)(MBCollectionView *__nonnull list);

/**
 数据源状态变化回调
 */
@property (nullable) void (^dataSourceStatusChanged)(MBCollectionViewDataSource *__nonnull dateSource);

#pragma mark - Header & footer

/// 默认 view 创建后如果 refreshControl 未设置会自动创建一个 UIRefreshControl
/// 如果不需要使用 refreshControl 需设置该属性为 YES
@property IBInspectable BOOL disableRefreshControl;

/**
 在 collection view 顶部增加的区域，相当于 table view 的 tableHeaderView

 内部通过修改 contentInset 实现。由于是往内容顶部开出区域来显示 header，到顶时的 content offset 会变负

 @bug 如果 collection view 用了 UIRefreshControl 会有冲突
 */
@property (nullable, nonatomic) UIView *collectionHeaderView;

/**
 底部刷新视图

 默认不会创建，需要启用 footer supplementary view 且 id 为 "RefreshFooter"、类型为 MBCollectionRefreshFooterView。view 结构可参考 MBCollectionRefreshFooterView.xib
 */
@property (nullable, nonatomic) MBCollectionRefreshFooterView *refreshFooterView;

/// 用于对 refreshFooterView 进行定制，因为其不会立即载入
@property (nullable) void (^refreshFooterConfig)(MBCollectionRefreshFooterView *__nonnull);

- (nonnull UICollectionReusableView *)collectionView:(nonnull UICollectionView *)collectionView viewForSupplementaryElementOfKind:(nonnull NSString *)kind atIndexPath:(nonnull NSIndexPath *)indexPath;

/// 重置，以便作为另一个列表展示
- (void)prepareForReuse;
@end


/**
 这类只能于 MBCollectionView，用来给 MBCollectionView 增加一个自适应高度的 header，其高度只能用 Auto Layout 控制。
 
 使用：
 - 把想要呈现的视图放在 contentView 中，用约束撑起（跟用 Auto Layout 撑起 UIScrollView 同理），该视图保持自身与 contentView 等高。
 - contentView 也要设置约束，但需要注意只应设置左右与上三个方向的约束，底部留空
 
 - 如果 contentView 为空，其高度将不会自动更新，你需要设置 MBCollectionViewHeaderFooterView 并手动调用 updateHeight，该方式并不推荐
 */
@interface MBCollectionViewHeaderFooterView : UIView <
    RFInitializing
>
@property (weak, nullable) IBOutlet UIView *contentView;

/**
 正常情况下，不需要调用下面的方法，contentView 高度发生变化时会自动更新相关视图
 */
- (void)updateHeight;
- (void)updateHeightAnimated:(BOOL)animated;

@end
