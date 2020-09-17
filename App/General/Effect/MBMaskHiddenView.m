
#import "MBMaskHiddenView.h"
#import <RFKit/RFGeometry.h>

@interface MBMaskHiddenView ()
@property BOOL hiddenShouldBe;
@end

@implementation MBMaskHiddenView

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView *v = [UIView.alloc initWithFrame:self.bounds];
    v.opaque = YES;
    v.backgroundColor = UIColor.blackColor;
    self.maskView = v;
    self.hidden = YES;
    self.hiddenShouldBe = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.hidden) {
        // mask view 的 frame 不应用 auto resizing，需手动设置
        [self _setupUIHidden:self.hiddenShouldBe];
    }
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (self.hiddenShouldBe == hidden) return;
    self.hiddenShouldBe = hidden;
    if (!animated) {
        self.hidden = hidden;
        [self _setupUIHidden:hidden];
        return;
    }
    if (!hidden) {
        if (self.hidden) {
            self.hidden = NO;
            [self _setupUIHidden:YES];
        }
    }
    CGFloat damping = 1;
    CGFloat velocity = 0.5;
    NSTimeInterval duration = 0.3;

    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self _setupUIHidden:hidden];
    } completion:^(BOOL finished) {
        if (!finished) return;
        if (self.hiddenShouldBe && !self.hidden) {
            self.hidden = YES;
        }
    }];
}

- (void)_setupUIHidden:(BOOL)hidden {
    CGRect frame = (CGRect){ CGPointZero, self.bounds.size };
    if (hidden) {
        CGSize newSize = CGSizeMake(frame.size.width, 0);
        RFResizeAnchor anchor = RFResizeAnchorTop;
        if (self.transitionDirection == 1) {
            anchor = RFResizeAnchorBottom;
        }
        frame = CGRectResize(frame, newSize, anchor);
    }
    if (!CGRectEqualToRect(self.maskView.frame, frame)) {
        self.maskView.frame = frame;
    }
}

@end
