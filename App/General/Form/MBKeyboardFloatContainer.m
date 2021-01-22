
#import "MBKeyboardFloatContainer.h"
#import <RFKeyboard/RFKeyboard.h>
#import <RFKit/UIResponder+RFKit.h>
#import <RFKit/NSLayoutConstraint+RFKit.h>
#import <RFKit/UIView+RFKit.h>

@interface MBKeyboardFloatContainer ()
/**
 弹出键盘时添加蒙板
 */
@property (nonatomic) UIControl *maskButton;
@end

@implementation MBKeyboardFloatContainer
RFInitializingRootForUIView

- (void)onInit {
    [self setupKeyboardObserver];
}

- (void)afterInit {
}

- (UIControl *)maskButton {
    if (_maskButton) return _maskButton;
    UIControl *bt = [UIControl new];
    bt.autoresizingMask = UIViewAutoresizingFlexibleSize;
    [bt addTarget:self action:@selector(onAutoDismissKeyboardButtonTapped) forControlEvents:UIControlEventTouchDown];
    _maskButton = bt;
    return _maskButton;
}

- (void)setupKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGFloat keyboardHeight = [RFKeyboard keyboardLayoutHeightForNotification:note inView:self];
    [RFKeyboard viewAnimateWithNotification:note animations:^{
        self.keyboardLayoutConstraint.constant = keyboardHeight + self.offsetAdjust;
        [self.keyboardLayoutConstraint updateLayoutIfNeeded];
    } completion:nil];
    if (self.tapToDismissContainer) {
        if (self.maskButton.superview
            && self.maskButton.superview != self.tapToDismissContainer) {
            [self.tapToDismissContainer removeFromSuperview];
        }
        [self.tapToDismissContainer addSubview:self.maskButton resizeOption:RFViewResizeOptionFill];
    }
}

- (void)onAutoDismissKeyboardButtonTapped {
    [self.viewController dismissKeyboard];
}

- (void)keyboardWillHide:(NSNotification *)note {
    if (self.tapToDismissContainer) {
        [self.tapToDismissContainer removeSubview:self.maskButton];
    }
    [RFKeyboard viewAnimateWithNotification:note animations:^{
        if (self.keyboardLayoutOriginalConstraint) {
            self.keyboardLayoutConstraint.constant = self.keyboardLayoutOriginalConstraint;
        }
        else {
            self.keyboardLayoutConstraint.constant = 0;
        }
        [self.keyboardLayoutConstraint updateLayoutIfNeeded];
    } completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
