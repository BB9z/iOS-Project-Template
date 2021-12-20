
#import "MBKeyboardFloatContainer.h"
#import <RFKeyboard/RFKeyboard.h>
#import <RFKit/UIResponder+RFKit.h>
#import <RFKit/NSLayoutConstraint+RFKit.h>
#import <RFKit/UIView+RFKit.h>

@interface MBKeyboardFloatContainer ()
/// 弹出键盘时添加蒙板
@property (nonatomic) UIControl *maskButton;
@property NSUUID *animationID;
@end

@implementation MBKeyboardFloatContainer
RFInitializingRootForUIView

- (void)onInit {
    [self setupKeyboardObserver];
}

- (void)afterInit {
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)setupKeyboardObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    if (self.ignoreUpcomingHideNotificationUntilShow) {
        self.ignoreUpcomingHideNotificationUntilShow = NO;
    }
    CGFloat keyboardHeight = [RFKeyboard keyboardLayoutHeightForNotification:note inView:self.superview ?: self];
    NSUUID *identify = [NSUUID UUID];
    self.animationID = identify;
    [RFKeyboard viewAnimateWithNotification:note animations:^{
        if (![self.animationID isEqual:identify]) return;
        CGFloat newConstraint = keyboardHeight + self.offsetAdjust - self.safeAreaInsets.bottom;
        [self updateKeyboardLayoutConstraint:newConstraint layoutImmediately:YES];
    } completion:nil];

    if (self.tapToDismissContainer) {
        if (self.maskButton.superview
            && self.maskButton.superview != self.tapToDismissContainer) {
            [self.tapToDismissContainer removeFromSuperview];
        }
        [self.tapToDismissContainer addSubview:self.maskButton resizeOption:RFViewResizeOptionFill];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    if (self.ignoreUpcomingHideNotificationUntilShow) return;
    if (self.tapToDismissContainer) {
        [self.tapToDismissContainer removeSubview:self.maskButton];
    }
    NSUUID *identify = [NSUUID UUID];
    self.animationID = identify;
    [RFKeyboard viewAnimateWithNotification:note animations:^{
        if (![self.animationID isEqual:identify]) return;
        CGFloat newConstraint = self.keyboardLayoutOriginalConstraint ?: 0;
        [self updateKeyboardLayoutConstraint:newConstraint layoutImmediately:YES];
    } completion:nil];
}

- (void)updateKeyboardLayoutConstraint:(CGFloat)constant layoutImmediately:(BOOL)layoutImmediately {
    if (self.keyboardLayoutConstraint.constant == constant) return;
    self.keyboardLayoutConstraint.constant = constant;

    if (!layoutImmediately) return;
    if (self.needsLayoutView) {
        [self.needsLayoutView layoutIfNeeded];
    }
    else {
        [self.keyboardLayoutConstraint updateLayoutIfNeeded];
    }
}

- (UIControl *)maskButton {
    if (_maskButton) return _maskButton;
    UIControl *bt = [UIControl new];
    bt.autoresizingMask = UIViewAutoresizingFlexibleSize;
    [bt addTarget:self action:@selector(onAutoDismissKeyboardButtonTapped) forControlEvents:UIControlEventTouchDown];
    _maskButton = bt;
    return _maskButton;
}

- (void)onAutoDismissKeyboardButtonTapped {
    [self.viewController dismissKeyboard];
}

@end
