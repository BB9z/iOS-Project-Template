
#import "MBEntitiesCollectionView.h"
#import "MBGeneralItemExchanging.h"
#import "MBGeneralCellResponding.h"

@implementation MBEntitiesCollectionView
RFInitializingRootForUIView

- (void)onInit {
    self.dataSource = self;
    if (!self.delegate) {
        self.delegate = self;
    }
    self.scrollsToTop = NO;
}

- (void)afterInit {
    // Nothing
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<MBGeneralItemExchanging> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if (self.cellConfigBlock) {
        self.cellConfigBlock(cell, self.items[indexPath.item]);
    }
    else {
        cell.item = self.items[indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(onCellSelected)]) {
        [(id<MBGeneralCellResponding>)cell onCellSelected];
    }
}

- (void)setItems:(NSArray *)items {
    if (_items != items) {
        _items = items;
        [self reloadData];
    }
}

- (void)appendItem:(id)item {
    if (!item) return;
    if (![_items isKindOfClass:NSMutableArray.class]) {
        _items = [NSMutableArray.alloc initWithArray:_items];
    }
    [(NSMutableArray *)_items addObject:item];
    [self insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:_items.count - 1 inSection:0] ]];
}

- (void)removeItem:(id)item {
    if (!item) return;
    NSInteger idx = [self.items indexOfObject:item];
    if (idx == NSNotFound) return;
    if (![_items isKindOfClass:NSMutableArray.class]) {
        _items = [NSMutableArray.alloc initWithArray:_items];
    }
    [(NSMutableArray *)_items removeObjectAtIndex:idx];
    [self deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:idx inSection:0] ]];
}

@end
