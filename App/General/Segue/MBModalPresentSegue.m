
#import "MBModalPresentSegue.h"
#import <MBAPI.h>
#import "MBNavigationController.h"
#import "UIView+RFAnimate.h"
#import "UIViewController+RFKit.h"

@implementation MBModalPresentSegue

- (void)RFPerform {
    UIViewController *parent = [UIViewController rootViewControllerWhichCanPresentModalViewController];
    MBModalPresentViewController *vc = self.destinationViewController;
    if (![vc isKindOfClass:[MBModalPresentViewController class]]) {
        RFAssert(false, @"%@ is not a MBModalPresentViewController.", vc);
        return;
    }

    [vc presentFromViewController:parent animated:YES completion:nil];
}

@end

@implementation MBModalPresentPushSegue

- (void)perform {
    [(UINavigationController *)AppNavigationController() pushViewController:self.destinationViewController animated:YES];
}

@end

@implementation MBModalPresentViewController

- (void)presentFromViewController:(UIViewController *)parentViewController animated:(BOOL)animated completion:(void (^)(void))completion {
    if (!parentViewController) {
        parentViewController = [UIViewController rootViewControllerWhichCanPresentModalViewController];
    }

    UIView *dest = self.view;
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:dest resizeOption:RFViewResizeOptionFill];

    // 解决 iPad 上动画弹出时 frame 不正确
    dest.hidden = YES;
    dispatch_after_seconds(0.05, ^{
        dest.hidden = NO;
        [(id<MBModalPresentSegueDelegate>)self setViewHidden:NO animated:YES completion:completion];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self dismissAnimated:YES completion:nil];
}

- (IBAction)dismiss:(UIButton *)sender {
    if ([sender respondsToSelector:@selector(setEnabled:)]) {
        sender.enabled = NO;
    }
    [self dismissAnimated:YES completion:nil];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self dismissAnimated:flag completion:completion];
}

- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [MBAPI.global cancelOperationsWithGroupIdentifier:self.APIGroupIdentifier];
    @weakify(self);
    [self setViewHidden:YES animated:YES completion:^{
        @strongify(self);
        [self removeFromParentViewControllerAndView];
        if (completion) {
            completion();
        }
    }];
}

- (void)setViewHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(void))completion {
    UIView *mask = self.maskView;
    UIView *menu = self.containerView;

    CGFloat menuY = menu.bounds.origin.y;
    BOOL acStyle = (self.preferredStyle == UIAlertControllerStyleActionSheet);
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animated:animated beforeAnimations:^{
        mask.alpha = hidden? 1 : 0;
        if (!acStyle) {
            menu.alpha = hidden? 1 : 0;
        }
        if (!hidden) {
            if (acStyle) {
                menu.y = menu.superview.height;
            }
            else {
                CGRect b = menu.bounds;
                b.origin.y -= 40;
                menu.bounds = b;
            }
        }
    } animations:^{
        mask.alpha = hidden? 0 : 1;
        if (!acStyle) {
            menu.alpha = hidden? 0 : 1;
        }
        CGRect b = menu.bounds;
        if (hidden) {
            if (acStyle) {
                menu.y = menu.superview.height;
            }
            else {
                b.origin.y -= 40;
            }
        }
        else {
            if (acStyle) {
                menu.y = menu.superview.height - menu.height;
            }
            else {
                b.origin.y = menuY;
            }
        }
        menu.bounds = b;
    } completion:^(BOOL finished) {
        if (hidden) {
            if (acStyle) {
                menu.y = menu.superview.height - menu.height;
            }
            else {
                CGRect b = menu.bounds;
                b.origin.y = menuY;
                menu.bounds = b;
            }
        }
        if (completion) {
            completion();
        }
    }];
}

@end
