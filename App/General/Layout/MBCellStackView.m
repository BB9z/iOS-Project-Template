
#import "MBCellStackView.h"
#import "MBGeneralItemExchanging.h"
#import <RFKit/NSArray+RFKit.h>
#import <RFKit/UIView+RFKit.h>

@interface MBCellStackView ()
@end

@implementation MBCellStackView
RFInitializingRootForUIView

- (void)onInit {
    
}

- (void)afterInit {
    // Nothing
}

@dynamic cellNibName;
- (void)setCellNibName:(NSString *)cellNibName {
    self.cellNib = [UINib nibWithNibName:cellNibName bundle:nil];
}

- (void)setItems:(NSArray *)items {
    BOOL countChanged = _items.count != items.count;
    _items = items;
    if (countChanged) {
        [self _updateArrangedViews];
    }
    [self _updateViewItem];
}

- (void)_updateArrangedViews {
    NSUInteger oldCount = self.arrangedSubviews.count;
    NSUInteger newCount = self.items.count;
    if (oldCount == newCount) return;
    if (oldCount > newCount) {
        NSArray<UIView *> *viewsToRemove = [self.arrangedSubviews rf_subarrayWithRangeLocation:newCount length:oldCount - newCount];
        for (UIView *v in viewsToRemove) {
            [self removeSubview:v];
        }
        return;
    }
    UINib *nib = self.cellNib;
    if (!nib) return;
    for (NSInteger i = newCount - oldCount; i > 0; i--) {
        UIView *v = (id)[nib instantiateWithOwner:self options:nil].firstObject;
        if (![v isKindOfClass:UIView.class]) break;
        [self addArrangedSubview:v];
    }
}

- (void)_updateViewItem {
    [self.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView<MBGeneralItemExchanging> *v, NSUInteger idx, BOOL * _Nonnull stop) {
        id item = [self.items rf_objectAtIndex:idx];
        if (self.configureCell) {
            self.configureCell(self, v, idx, item);
            return;
        }
        if ([v respondsToSelector:@selector(setItem:)]) {
            [v setItem:item];
        }
    }];
}

@end
