
#import "MBSearchViewController.h"
#import "Common.h"
#import <RFAlpha/RFAnimationTransitioning.h>
#import <RFKeyboard/RFKeyboard.h>
#import <RFKit/NSLayoutConstraint+RFKit.h>
#import <MBAppKit/MBAPI.h>

@interface MBSearchTransitioning : RFAnimationTransitioning
@end

@interface MBSearchViewController ()
@property (nonatomic) BOOL keyboardNotificationFlag;
@end

@implementation MBSearchViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.keyboardAdjustLayoutConstraint) {
        @weakify(self);
        [RFKeyboard.defaultManager setKeyboardShowCallback:^(NSNotification *note) {
            @strongify(self);
            self.keyboardAdjustLayoutConstraint.constant = [RFKeyboard keyboardLayoutHeightForNotification:note inView:self.container];
            [self.keyboardAdjustLayoutConstraint updateLayoutIfNeeded];
        }];
        [RFKeyboard.defaultManager setKeyboardHideCallback:^(NSNotification *note) {
            @strongify(self);
            self.keyboardAdjustLayoutConstraint.constant = 0;
            [self.keyboardAdjustLayoutConstraint updateLayoutIfNeeded];
        }];
    }
    if (self.focusSearchBarWhenAppear) {
        [self.searchTextField becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.keyboardAdjustLayoutConstraint) {
        RFKeyboard.defaultManager.keyboardShowCallback = nil;
        RFKeyboard.defaultManager.keyboardHideCallback = nil;
    }
}

- (void)onCancel:(id)sender {
    MBSearchTextField *sf = self.searchTextField;
    BOOL skipPop = sf.isFirstResponder && sf.text.length;
    if (sf.isFirstResponder) {
        [sf resignFirstResponder];
    }
    sf.text = nil;
    if (sf.isSearching && sf.APIName) {
        [MBApp.status.api cancelOperationWithIdentifier:sf.APIName];
        sf.isSearching = NO;
    }
    if (!skipPop) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *)RFTransitioningStyle {
    return MBSearchTransitioning.className;
}

@end

@implementation MBSearchTransitioning

- (NSTimeInterval)duration {
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {

    UIView *containerView = transitionContext.containerView;
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromVC];
    CGRect toFrame = [transitionContext finalFrameForViewController:toVC];
    BOOL reverse = self.reverse;

    MBSearchViewController *searchViewController = (id)(reverse? fromVC : toVC);
    UIView *container = searchViewController.container;

    // Navigation bar hidden may change between transition.
    // Let initial frame bigger can avoid user see window background.
    toView.frame = CGRectContainsRect(toFrame, fromFrame)? toFrame : fromFrame;

    if (reverse) {
        [containerView insertSubview:toView belowSubview:fromView];
    }
    else {
        [containerView insertSubview:toView aboveSubview:fromView];
    }

    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animated:YES beforeAnimations:^{
        if (reverse) {
        }
        else {
            container.y = toView.height;
            toView.alpha = 0;
        }
    } animations:^{
        if (reverse) {
            fromView.alpha = 0;
        }
        else {
            container.bottomMargin = 0;
            toView.alpha = 1;
        }
        toView.frame = toFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
