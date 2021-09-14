
#import "MBCollectionViewCarouselLayout.h"
#import <RFKit/UIView+RFAnimate.h>

@interface MBCollectionViewCarouselLayout () {
    CGFloat _viewSize;
    CGFloat _itemSize;
}

@end

@implementation MBCollectionViewCarouselLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (CGRectGetHeight(oldBounds) != CGRectGetHeight(newBounds)) {
            return YES;
        }
    }
    else {
        if (CGRectGetWidth(oldBounds) != CGRectGetWidth(newBounds)) {
            return YES;
        }
    }
    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

- (void)prepareLayout {
    [super prepareLayout];
    BOOL isVertical = (self.scrollDirection == UICollectionViewScrollDirectionVertical);
    _viewSize = isVertical? self.collectionView.height : self.collectionView.width;
    if (self.fixedCellPadding != 0) {
        _itemSize = _viewSize - self.fixedCellPadding * 2;
        CGSize itemSize = self.itemSize;
        if (isVertical) {
            itemSize.height = _itemSize;
        }
        else {
            itemSize.width = _itemSize;
        }
        self.itemSize = itemSize;
    }
    else {
        _itemSize = isVertical? self.itemSize.height : self.itemSize.width;
    }
    
    CGFloat padding = (_viewSize - _itemSize) / 2;
    UIEdgeInsets inset = self.sectionInset;
    if (isVertical) {
        inset.top = padding;
        inset.bottom = padding;
    }
    else {
        inset.left = padding;
        inset.right = padding;
    }
    self.sectionInset = inset;
    [self.collectionView invalidateIntrinsicContentSize];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGFloat offset = 0;
    CGFloat offsetCurrent = 0;
    CGFloat v = 0;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        offset = proposedContentOffset.y;
        offsetCurrent = self.collectionView.contentOffset.y;
        v = velocity.y;
    }
    else {
        offset = proposedContentOffset.x;
        offsetCurrent = self.collectionView.contentOffset.x;
        v = velocity.x;
    }
    
    CGFloat wPage = _itemSize + self.minimumLineSpacing;
    double ixTarget = offset / wPage;
    double ixCurrent = (v > 0)? floor(offsetCurrent / wPage) : ceil(offsetCurrent / wPage);
    _dout(@"offset: %f, %f\t ix: %f(%f), %f(%f)", offset, offsetCurrent, offset / wPage, ixTarget, offsetCurrent / wPage, ixCurrent);
    
    double ixFinal = ixTarget;
    // Limit page count change less than 2.
    if (fabs(ixCurrent - ixTarget) > 1) {
        ixFinal = ixCurrent > ixTarget ? ixCurrent - 1 : ixCurrent + 1;
    }
    CGFloat offsetFixed = round(ixFinal) * wPage;
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        proposedContentOffset.y = offsetFixed;
    }
    else {
        proposedContentOffset.x = offsetFixed;
    }
    
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.collectionView setContentOffset:proposedContentOffset animated:NO];
    } completion:nil];
    
    return proposedContentOffset;
}

@end
