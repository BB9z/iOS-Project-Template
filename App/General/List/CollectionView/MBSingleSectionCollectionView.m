
#import "MBSingleSectionCollectionView.h"
#import "MBGeneralItemExchanging.h"
#import <RFKit/NSArray+RFKit.h>

@interface MBSingleSectionCollectionView ()
@property (strong, nonatomic) UICollectionViewDataSourceChain *trueDataSource;
@property (strong, nonatomic) UICollectionViewDelegateFlowLayoutChain *trueDelegate;
@end

@implementation MBSingleSectionCollectionView
@synthesize selectedItem = _selectedItem;
@dynamic delegate;
RFInitializingRootForUIView

- (void)afterInit {
}

#pragma mark - Item

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) return nil;
    return [self.items rf_objectAtIndex:indexPath.item];
}

- (NSIndexPath *)indexPathForItem:(id)item {
    NSInteger idx = [self.items indexOfObject:item];
    if (idx != NSNotFound) {
        return [NSIndexPath indexPathForRow:idx inSection:0];
    }
    return nil;
}

- (void)setSelectedItem:(id)selectedItem {
    _selectedItem = selectedItem;
    [self selectCellForItem:selectedItem];
}

- (id)selectedItem {
    NSIndexPath *ip = [self indexPathsForSelectedItems].firstObject;
    return [self itemAtIndexPath:ip];
}

- (void)selectCellForItem:(id)item {
    NSIndexPath *ip = [self indexPathForItem:item];
    if (ip) {
        [self selectItemAtIndexPath:ip animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)updateItems {
    [self reloadData];
    if (self.keepItemSelectionAfterReload) {
        [self selectCellForItem:_selectedItem];
    }
}

#pragma mark - DataSource/Delegate

- (void)onInit {
    [super setDataSource:self.trueDataSource];
    self.delegate = self.trueDelegate;
}

- (void)dealloc {
    [super setDataSource:nil];
    [super setDelegate:nil];
}

- (UICollectionViewDelegateFlowLayoutChain *)trueDelegate {
    if (!_trueDelegate) {
        UICollectionViewDelegateFlowLayoutChain *fc = [UICollectionViewDelegateFlowLayoutChain new];
        _trueDelegate = fc;
    }
    return _trueDelegate;
}

- (UICollectionViewDataSourceChain *)trueDataSource {
    if (!_trueDataSource) {
        UICollectionViewDataSourceChain *ds = [UICollectionViewDataSourceChain new];
        @weakify(self);
        [ds setNumberOfItemsInSection:^NSInteger(UICollectionView *collectionView, NSInteger section, id<UICollectionViewDataSource> delegate) {
            @strongify(self);
            return self.items.count;
        }];
        [ds setCellForItemAtIndexPath:^UICollectionViewCell *(UICollectionView *collectionView, NSIndexPath *indexPath, id<UICollectionViewDataSource> delegate) {
            @strongify(self);
            id cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            if ([cell respondsToSelector:@selector(setItem:)]) {
                [(id<MBGeneralItemExchanging>)cell setItem:[self itemAtIndexPath:indexPath]];
            }
            return cell;
        }];
        _trueDataSource = ds;
    }
    return _trueDataSource;
}

#pragma mark DataSource/Delegate Forward

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    if (self.dataSource == dataSource) {
        [super setDataSource:dataSource];
    }
    else {
        self.trueDataSource.delegate = dataSource;
    }
}

- (id<UICollectionViewDataSource>)dataSource {
    return self.trueDataSource;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    if (self.trueDelegate == delegate) {
        [super setDelegate:nil];
        [super setDelegate:delegate];
    }
    else {
        self.trueDelegate.delegate = (id)delegate;
    }
}

@end
