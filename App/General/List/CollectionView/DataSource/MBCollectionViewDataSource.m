
#import "MBCollectionViewDataSource.h"
#import <MBAppKit/MBGeneral.h>
#import <RFDelegateChain/RFDelegateChain.h>

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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (!self.collectionView) {
        self.collectionView = collectionView;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellReuseIdentifier(collectionView, indexPath, item) forIndexPath:indexPath];
    RFAssert(cell, nil);
    self.configureCell(collectionView, cell, indexPath, item);
    return cell;
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
