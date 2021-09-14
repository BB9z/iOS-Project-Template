
#import "MBCollectionView.h"
#import <MBAppKit/MBGeneralSetNeedsDoSomthing.h>
#import <RFAlpha/RFKVOWrapper.h>
#import <RFAlpha/UIScrollView+RFScrollViewContentDistance.h>
#import <RFKit/UIResponder+RFKit.h>
#import <RFKit/UIScrollView+RFScrolling.h>
#import <RFKit/UIView+RFAnimate.h>
#import <RFKit/UIView+RFKit.h>

@interface MBCollectionView ()
@property (nonatomic) MBCollectionViewDataSource *trueDataSource;
@property (nonatomic) BOOL refreshFooterViewStatusUpdateFlag;

@property BOOL autoFetchWhenScroll;

/// 真实的 contentInset 被劫持了，这个属性存储的是外部设置的 contentInset，实际 contentInset 会加上 header 高度
@property (nonatomic) UIEdgeInsets trueContentInset;
@property (weak, nonatomic) id footerStatusObserver;
@property (nonatomic) CGFloat lastHeaderViewHeight;
@property id dataSourceFetchingObserver;
@end

@implementation MBCollectionView
@dynamic dataSource;
RFInitializingRootForUIView

- (void)onInit {
    MBCollectionViewDataSource *ds = MBCollectionViewDataSource.new;
    ds.collectionView = self;
    ds.delegate = self;
    @weakify(self);
    [ds addFetchCompletionCallback:^(MBCollectionViewDataSource *d, NSError * _Nullable error) {
        @strongify(self);
        [self.refreshControl endRefreshing];
        self.autoFetchWhenScroll = !error;
    } refrenceObject:self];
    self.trueDataSource = ds;
    [super setDataSource:ds];
    self.alwaysBounceVertical = YES;
    self.adjustOffsetBeforeReload = ^(MBCollectionView * _Nonnull list) {
        [list scrollToTopAnimated:!list.refreshControl.isRefreshing];
    };
}

- (void)afterInit {
    self.dataSource.delegate = (id<UICollectionViewDataSource>)self;
    UIRefreshControl *rc = self.refreshControl;
    if (!rc && !self.disableRefreshControl) {
        UIRefreshControl *rc = [UIRefreshControl.alloc init];
        rc.tintColor = self.tintColor;
        self.refreshControl = rc;
    }
    @weakify(self);
    self.dataSourceFetchingObserver = [self RFAddObserver:self forKeyPath:@keypath(self, refreshFooterViewStatusUpdateFlag) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew queue:nil block:^(id observer, NSDictionary *change) {
        @strongify(self);
        self.refreshControl.enabled = !self.dataSource.fetching;
        [self MBCollectionView_setNeedsUpdateFooterRefreshing];
    }];
}

- (void)dealloc {
    [super setDataSource:nil];
    [super setDelegate:nil];
}

- (void)prepareForReuse {
    [self.dataSource prepareForReuse];
    [self reloadData];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        if (self.autoFetchWhenMoveToWindow
            && !self.dataSource.hasSuccessFetched
            && !self.dataSource.fetching) {
            [self fetchItemsNextPage:NO success:nil completion:nil];
        }
    }
}

#pragma mark - Refresh Control / Header

- (void)setRefreshControl:(UIRefreshControl *)refreshControl {
    SEL sel = @selector(MBCollectionView_onRefreshControlStatusChanged);
    [self.refreshControl removeTarget:self action:sel forControlEvents:UIControlEventValueChanged];
    [super setRefreshControl:refreshControl];
    [refreshControl addTarget:self action:sel forControlEvents:UIControlEventValueChanged];
}

- (void)MBCollectionView_onRefreshControlStatusChanged {
    [self fetchItemsNextPage:NO success:nil completion:nil];
}

#pragma mark Refresh Footer

+ (NSSet *)keyPathsForValuesAffectingRefreshFooterViewStatusUpdateFlag {
    MBCollectionView *this;
    return [NSSet setWithObjects:@keypath(this, dataSource.fetching), @keypath(this, dataSource.pageEnd), @keypath(this, dataSource.empty), nil];
}

MBSynthesizeSetNeedsMethodUsingAssociatedObject(MBCollectionView_setNeedsUpdateFooterRefreshing, MBCollectionView_updateFooterRefreshing, 0)

- (void)MBCollectionView_updateFooterRefreshing {
    MBCollectionViewDataSource *ds = self.dataSource;
    MBCollectionRefreshFooterView *ft = self.refreshFooterView;
    if (ds.fetching) {
        ft.status = RFRefreshControlStatusFetching;
    }
    else if (ds.empty) {
        ft.status = RFRefreshControlStatusEmpty;
    }
    else if (ds.pageEnd) {
        ft.status = RFRefreshControlStatusEnd;
    }
    else {
        ft.status = RFRefreshControlStatusWaiting;
    }
    if (self.dataSourceStatusChanged) {
        self.dataSourceStatusChanged(ds);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSAssert(NO, @"⚠️ Section header 已启用，但没有修改 dataSource 的 delegate 或 viewForSupplementaryElement 回调");
    }
    __kindof UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RefreshFooter" forIndexPath:indexPath];
    if ([view isKindOfClass:MBCollectionRefreshFooterView.class]) {
        MBCollectionRefreshFooterView *rv = view;
        self.refreshFooterView = rv;
        if (self.refreshFooterConfig) {
            self.refreshFooterConfig(rv);
        }
        [self MBCollectionView_updateFooterRefreshing];
    }
    return view;
}

- (IBAction)loadNextPage:(id)sender {
    [self fetchItemsNextPage:YES success:nil completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.autoFetchWhenScroll) return;
    CGFloat distance = self.distanceBetweenContentAndBottom;
    if (distance < -200) return;
    if (self.refreshControl.isRefreshing
        || self.dataSource.fetching
        || self.dataSource.pageEnd) return;
    [self loadNextPage:self];
}

#pragma mark - DataSource Forward

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    self.trueDataSource.delegate = dataSource;

    // 视图释放时可能会调置空方法，此时不调 super
    if (!dataSource) return;
    // iOS 9 之后会缓存 delegate 响应方法的结果，需要重置刷新
    [super setDataSource:nil];
    [super setDataSource:self.trueDataSource];
}

- (id<UICollectionViewDataSource>)dataSource {
    return self.trueDataSource;
}

- (void)fetchItemsNextPage:(BOOL)nextPage success:(void (^)(MBCollectionViewDataSource * _Nonnull, NSArray * _Nullable))success completion:(void (^)(MBCollectionViewDataSource * _Nonnull))completion {
    UIRefreshControl *rc = self.refreshControl;
    if (rc) {
        if (!nextPage) {
            if (!rc.isRefreshing) {
                rc.enabled = NO;
            }
        }
    }
    if (!nextPage) {
        [self.dataSource cancelFetching];
        if (self.adjustOffsetBeforeReload) {
            self.adjustOffsetBeforeReload(self);
        }
    }
    [self.dataSource fetchItemsFromViewController:self.viewController nextPage:nextPage success:^(MBCollectionViewDataSource *dateSource, NSArray *fetchedItems) {
        [dateSource.collectionView reloadData];
        if (success) {
            success(dateSource, fetchedItems);
        }
    } completion:^(MBCollectionViewDataSource *dateSource) {
        if (rc.isRefreshing) {
            [rc endRefreshing];
        }
        if (completion) {
            completion(dateSource);
        }
    }];
}

#pragma mark - Collection Header View

/**
 利用 contentInset 增加顶部空间，独立于 UICollectionViewLayout 单独布局

 */
- (void)setContentInset:(UIEdgeInsets)contentInset {
    self.trueContentInset = contentInset;

    _dout_insets(contentInset)
    CGFloat headerViewHeight = self.collectionHeaderView.height;
    contentInset.top += headerViewHeight;
    _dout_insets(contentInset)
    [super setContentInset:contentInset];
}

- (UIEdgeInsets)contentInset {
    return self.trueContentInset;
}

- (void)setCollectionHeaderView:(UIView *)collectionHeaderView {
    // Setup frame
    UIEdgeInsets contentInset = self.trueContentInset;
    _dout_insets(contentInset)

    CGFloat headerHeight = collectionHeaderView.height;
    CGRect frame = collectionHeaderView.frame;
    frame.origin.x = 0;
    frame.origin.y = contentInset.top - headerHeight;
    frame.size.width = self.width;
    collectionHeaderView.frame = frame;
    _dout_rect(frame)

    // Setup view hierarchy
    if (_collectionHeaderView != collectionHeaderView) {
        if (_collectionHeaderView) {
            [_collectionHeaderView removeFromSuperview];
        }

        if (collectionHeaderView.superview != self) {
            [collectionHeaderView removeFromSuperview];
            collectionHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
            collectionHeaderView.translatesAutoresizingMaskIntoConstraints = YES;
            [self addSubview:collectionHeaderView];
        }

        // Adjust header offset when header is visible
        if (self.contentOffset.y <= 0) {
            CGPoint offset = self.contentOffset;
            offset.y = -headerHeight;
            self.contentOffset = offset;
        }

        _collectionHeaderView = collectionHeaderView;
    }
    else {
        // 同一个 header 的更新效果只是刷新 offset
        CGPoint offsetAdjust = self.contentOffset;
        offsetAdjust.y += self.lastHeaderViewHeight - headerHeight;
        self.contentOffset = offsetAdjust;
    }
    self.lastHeaderViewHeight = headerHeight;

    __unused CGFloat height = frame.size.height;

    _dout_rect(self.bounds)
    _dout_bool(CGRectContainsRect(frame, self.bounds))
    // 如果 header 在视野内，需要调整 offset 使内容向下移动
    // 不在视野内无操作防抖动
    //    if (CGRectContainsRect(frame, self.bounds)) {
    //        // 上面留出的空白
    //        CGFloat currentTopPadding = [super contentOffset].y - contentInset.top;
    //        dout_float(currentTopPadding)
    //        dout_float(height)
    //
    //        CGPoint offset = self.contentOffset;
    //        offset.y -= height - currentTopPadding;
    //        self.contentOffset = offset;
    //    }
    //    dout_point(self.contentOffset)

    // 调整 collection view 顶部空白
    // 在最后更新是因为 contentInset 内的设置依赖 header 高度
    self.contentInset = contentInset;
}

@end

@interface MBCollectionViewHeaderFooterView ()
@property (nonatomic) BOOL hasLayoutOnce;
@end

@implementation MBCollectionViewHeaderFooterView
RFInitializingRootForUIView

- (void)onInit {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    self.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)afterInit {
}

- (void)updateHeightIfNeeded {
    if (!self.contentView) return;

    CGFloat heightShouldBe = self.contentView.height + self.safeAreaInsets.top;
    if (self.height != heightShouldBe) {
        [self updateHeight];
    }
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    [self updateHeightIfNeeded];
}

- (void)updateHeight {
    if (self.contentView) {
        // ??: 图像高过小 contentView 会不断浮动导致死循环
        self.height = floor(self.contentView.height + self.safeAreaInsets.top);
    }

    MBCollectionView *tb = (id)self.superview;
    if ([tb isKindOfClass:[MBCollectionView class]]) {
        tb.collectionHeaderView = self;
    }
}

- (void)updateHeightAnimated:(BOOL)animated {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animated:animated beforeAnimations:nil animations:^{
        [self updateHeight];
    } completion:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.hasLayoutOnce) return;
    self.hasLayoutOnce = YES;
    [self RFAddObserver:self forKeyPath:@keypath(self, contentView.bounds) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial queue:nil block:^(MBCollectionViewHeaderFooterView *observer, NSDictionary *change) {
        [observer updateHeightIfNeeded];
    }];
}

@end
