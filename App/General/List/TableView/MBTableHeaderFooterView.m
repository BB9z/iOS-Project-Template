
#import "MBTableHeaderFooterView.h"
#import <RFAlpha/RFKVOWrapper.h>
#import <RFKit/UIView+RFAnimate.h>
#import <RFKit/UIView+RFKit.h>

@interface MBTableHeaderFooterView ()
@property (nonatomic) id contentViewHeightChangeObserver;
@end

@implementation MBTableHeaderFooterView
RFInitializingRootForUIView

- (void)onInit {
}

- (void)afterInit {
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.contentViewHeightChangeObserver) {
        [self updateHeightIfNeeded];
        self.contentViewHeightChangeObserver = [self RFAddObserver:self forKeyPath:@keypath(self, contentView.bounds) options:NSKeyValueObservingOptionNew queue:nil block:^(MBTableHeaderFooterView *observer, NSDictionary *change) {
            [observer updateHeightIfNeeded];
        }];
    }
}

- (void)updateHeightIfNeeded {
    if (!self.contentView) return;
    if (self.height != self.contentView.height) {
        [self updateHeight];
    }
}

- (void)updateHeight {
    if (!self.contentView) return;
    [self layoutIfNeeded];
    self.height = self.contentView.height;
    _dout_float(self.height)
    UITableView *tb = (id)self.superview;
    if ([tb isKindOfClass:[UITableView class]]) {
        if (tb.tableHeaderView == self) {
            tb.tableHeaderView = self;
        }

        if (tb.tableFooterView == self) {
            tb.tableFooterView = self;
        }
    }
    else {
        NSLog(@"MBTableHeaderFooterView’s superview must be a tableView. Current is %@", self.superview);
    }
}

- (void)updateHeightAnimated:(BOOL)animated {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animated:animated beforeAnimations:nil animations:^{
        [self updateHeight];
    } completion:nil];
}

- (void)setupAsHeaderViewToTableView:(UITableView *)tableView {
    if (tableView.tableHeaderView != self) {
        [self removeFromSuperview];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.translatesAutoresizingMaskIntoConstraints = YES;
    }
    tableView.tableHeaderView = self;
}

- (void)setupAsFooterViewToTableView:(UITableView *)tableView {
    if (tableView.tableFooterView != self) {
        [self removeFromSuperview];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        self.translatesAutoresizingMaskIntoConstraints = YES;
    }
    tableView.tableFooterView = self;
}

@end
