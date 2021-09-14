
#import "MBRefreshHeaderView.h"
#import <RFKit/UIView+RFKit.h>
#import <RFKit/UIView+RFAnimate.h>

@implementation MBRefreshHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)updateStatus:(RFPullToFetchIndicatorStatus)status distance:(CGFloat)distance control:(RFTableViewPullToFetchPlugin *)control {
    self.status = status;

    if (status == RFPullToFetchIndicatorStatusDragging) {
        BOOL isCompleteVisible = !!(distance >= self.height);
        self.statusLabel.text = isCompleteVisible? @"释放刷新" : @"继续下拉以刷新";
        self.indicatorImageView.transform = (isCompleteVisible)?CGAffineTransformMakeRotation(M_PI*2) : CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)setStatus:(RFPullToFetchIndicatorStatus)status {
    if (_status == status) return;
    _status = status;

    BOOL isProcessing = (status == RFPullToFetchIndicatorStatusProcessing);

    self.indicatorImageView.hidden = isProcessing;
    self.activityIndicatorView.hidden = !isProcessing;

    UILabel *label = self.statusLabel;
    switch (status) {
        case RFPullToFetchIndicatorStatusProcessing:
            label.text = @"正在刷新...";
            return;

        case RFPullToFetchIndicatorStatusDecelerating:
            label.text = @"下拉刷新";
            return;

        default:
            break;
    }
    [self updateOuterEmptyViewVisable];
}

- (void)updateOuterEmptyViewVisable {
    if (self.status == RFPullToFetchIndicatorStatusProcessing) {
        self.outerEmptyView.hidden = YES;
        return;
    }
    self.outerEmptyView.hidden = !self.empty;
}

- (void)setEmpty:(BOOL)empty {
    _empty = empty;
    [self updateOuterEmptyViewVisable];
}

- (void)setOuterEmptyView:(UIView *)outerEmptyView {
    _outerEmptyView = outerEmptyView;
    [self updateOuterEmptyViewVisable];
}

@end
