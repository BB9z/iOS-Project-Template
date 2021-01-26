
#import "MBCollectionViewColumnLayout.h"

@interface MBCollectionViewColumnLayout ()
@property (weak, nonatomic) id<UICollectionViewDelegateFlowLayout> delegateRefrence;
@end

@implementation MBCollectionViewColumnLayout
@dynamic delegateRefrence;

- (void)onInit {
    [super onInit];
    if (self.columnCount <= 0) {
        self.columnCount = 3;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.referenceItemSize = self.itemSize;
}

- (id<UICollectionViewDelegateFlowLayout>)delegateRefrence {
    return (id)self.collectionView.delegate;
}

- (void)setColumnCount:(NSInteger)columnCount {
    if (_columnCount != columnCount) {
        _columnCount = columnCount;
        if (!self.autoColumnDecideOnItemMinimumWidth) {
            [self invalidateLayout];
        }
    }
}

#pragma mark - 响应变化

- (void)prepareLayout {
    [super prepareLayout];
    BOOL layoutChanged = [self updateLayoutIfNeeded:self.collectionView.bounds];
    if (layoutChanged) {
        [self.collectionView invalidateIntrinsicContentSize];
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(oldBounds) != CGRectGetWidth(newBounds)) {
        [self updateLayoutIfNeeded:newBounds];
        return YES;
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

/// 返回是否更新了布局
- (BOOL)updateLayoutIfNeeded:(CGRect)bounds {
    if (self.collectionView.numberOfSections == 0) return NO;

    CGSize newItemSize = [self itemSizeForBounds:self.collectionView.bounds];
    if (CGSizeEqualToSize(newItemSize, self.itemSize)) {
        return NO;
    }
    self.itemSize = newItemSize;
    return YES;
}

#pragma mark - 布局计算

- (CGSize)itemSizeForBounds:(CGRect)bounds {
    CGSize reference = self.referenceItemSize;
    if (self.autoColumnDecideOnItemMinimumWidth) {
        CGFloat width = [self innerLayoutWidthForSection:0 bounds:bounds];
        self.columnCount = width/self.referenceItemSize.width;
    }

    CGFloat itemWidth = [self itemWidthInSectionAtIndex:0 bounds:bounds];

    CGFloat itemHeight = self.onlyAdjustWidth ? reference.height : round(itemWidth/reference.width * reference.height);
    return CGSizeMake(itemWidth, itemHeight);
}

- (CGFloat)innerLayoutWidthForSection:(NSInteger)section bounds:(CGRect)bounds {
    UIEdgeInsets sectionInset;
    if ([self.delegateRefrence respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInset = [self.delegateRefrence collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    } else {
        sectionInset = self.sectionInset;
    }
    return CGRectGetWidth(bounds) - sectionInset.left - sectionInset.right;
}

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section bounds:(CGRect)bounds {
    CGFloat width = [self innerLayoutWidthForSection:section bounds:bounds];
    NSInteger columnCount = self.columnCount;
    if (columnCount < 1) {
        columnCount = 1;
    }
    CGFloat itemWidth = floor((width - (columnCount - 1) * self.minimumInteritemSpacing) / columnCount);
    return itemWidth;
}

@end
