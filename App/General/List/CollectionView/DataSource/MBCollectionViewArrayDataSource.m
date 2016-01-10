
#import "MBCollectionViewArrayDataSource.h"

@interface MBCollectionViewArrayDataSource ()
@end

@implementation MBCollectionViewArrayDataSource
RFInitializingRootForNSObject

- (void)onInit {

}

- (void)afterInit {
    // Nothing
}

- (nonnull id)itemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    BOOL hasFirstItem = self.hasFirstItem;
    if ([self isFirstItemIndexPath:indexPath]) {
        return self.firstItemObject;
    }
    dout_int(indexPath.item - !!hasFirstItem)
    return [self.items rf_objectAtIndex:indexPath.item - !!hasFirstItem];
}

- (nullable NSIndexPath *)indexPathForItem:(nonnull id)item {
    BOOL hasFirstItem = self.hasFirstItem;
    NSInteger idx = [self.items indexOfObject:item];
    if (self.items // items 为空 idx 会是 0，所以需要明确检查一下
        && idx != NSNotFound) {
        return [NSIndexPath indexPathForRow:idx + !!hasFirstItem inSection:0];
    }
    if (item == self.firstItemObject) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return nil;
}

- (void)setItems:(NSMutableArray *)items {
    _items = items;
    [self.collectionView reloadData];
}

- (nonnull NSString *)cellIdentifierAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if ([self isFirstItemIndexPath:indexPath]) {
        return self.firstItemReuseIdentifier;
    }
    if (self.cellIdentifierProvider) {
        return self.cellIdentifierProvider(self, [self itemAtIndexPath:indexPath], indexPath);
    }
    return @"Cell";
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count + !!self.hasFirstItem;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<MBSenderEntityExchanging> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self cellIdentifierAtIndexPath:indexPath] forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setItem:)]) {
        cell.item = [self itemAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Additional Item

- (BOOL)hasFirstItem {
    return self.firstItemReuseIdentifier.length;
}

- (BOOL)isFirstItemIndexPath:(NSIndexPath *)indexPath {
    if (!self.hasFirstItem) return NO;
    return (indexPath.item == 0);
}

@end
