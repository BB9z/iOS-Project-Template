
#import "MBCollectionViewDataSource.h"
#import <MBAppKit/MBGeneral.h>
#import <RFDelegateChain/RFDelegateChain.h>
#import "MBListDateItem.h"

@implementation MBCollectionViewDataSource

- (NSString * _Nonnull (^)(UICollectionView * _Nonnull, NSIndexPath * _Nonnull, id _Nonnull))cellReuseIdentifier {
    if (!_cellReuseIdentifier) {
        _cellReuseIdentifier = ^NSString *(UICollectionView *collectionView, NSIndexPath *indexPath, id item) {
            return @"Cell";
        };
    }
    return _cellReuseIdentifier;
}

- (void (^)(UICollectionView * _Nonnull, __kindof UICollectionViewCell * _Nonnull, NSIndexPath * _Nonnull, id _Nonnull))configureCell {
    if (!_configureCell) {
        _configureCell = ^(UICollectionView *collectionView, id<MBSenderEntityExchanging> cell, NSIndexPath *indexPath, id item) {
            if ([cell respondsToSelector:@selector(setItem:)]) {
                [cell setItem:item];
            }
        };
    }
    return _configureCell;
}

#pragma mark -

// @bug(iOS 14): CollectionView 的 _diffableDataSourceImpl 方法，会调用 dataSource 中的同名方法，当 delegate 指回 collectionView 产生死循环
// 目前的解决方案是忽略全部 _ 打头的方法；另外这个算 MBCollectionView 的 bug，但写在这里比较适普
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([NSStringFromSelector(anInvocation.selector) hasPrefix:@"_"]) {
        return;
    }
    [super forwardInvocation:anInvocation];
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) hasPrefix:@"_"]) {
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!self.collectionView) {
        self.collectionView = collectionView;
    }
    if (self.isSectionEnabled) {
        return self.items.count;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.isSectionEnabled) {
        return [(MBListSectionDataItem *)self.items[section] rows].count;
    }
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseIdentifier(collectionView, indexPath, item) forIndexPath:indexPath];
    RFAssert(cell, nil);
    self.configureCell(collectionView, cell, indexPath, item);
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (self.viewForSupplementaryElement) {
        return self.viewForSupplementaryElement(collectionView, kind, indexPath, self.delegate);
    }
    return (UICollectionReusableView *_Nonnull)[self.delegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

#pragma mark -

- (void)reconfigVisableCells {
    UICollectionView *tb = self.collectionView;
    for (UICollectionViewCell *cell in tb.visibleCells) {
        NSIndexPath *ip = [tb indexPathForCell:cell];
        if (!ip) continue;
        self.configureCell(tb, cell, ip, [self itemAtIndexPath:ip]);
    }
}

- (void)removeItem:(id)item {
    NSIndexPath *ip = [self indexPathForItem:item];
    if (!ip) return;
    [self.items removeObject:item];
    if (self.items.count == 0 && self.pageEnd) {
        self.empty = YES;
    }
    [self.collectionView deleteItemsAtIndexPaths:@[ ip ]];
}

- (void)setItemsWithRawData:(id)responseData {
    [super setItemsWithRawData:responseData];
    [self.collectionView reloadData];
}

@end
