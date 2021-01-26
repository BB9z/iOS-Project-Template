
#import "MBModalPresentSegue.h"
#import "ShortCuts.h"
#import <MBAppKit/MBAPI.h>
#import <MBAppKit/MBNavigationController.h>
#import <RFKit/UIView+RFAnimate.h>
#import <RFKit/UIView+RFKit.h>
#import <RFKit/UIViewController+RFKit.h>

@implementation MBModalPresentSegue

- (void)RFPerform {
    UIViewController *parent = [UIViewController rootViewControllerWhichCanPresentModalViewController];
    id<MBModalPresentDestination> vc = self.destinationViewController;
    if (![vc respondsToSelector:@selector(presentFromViewController:animated:completion:)]) {
        RFAssert(false, @"%@ must confirms to MBModalPresentDestination.", vc);
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

- (UINavigationController *)navigationController {
    if (!super.navigationController && [self.presentedViewController isKindOfClass:UINavigationController.class]) {
        return (UINavigationController *)self.presentedViewController;
    }
    return super.navigationController;
}

- (void)presentFromViewController:(UIViewController *)parentViewController animated:(BOOL)animated completion:(void (^)(void))completion {
    if ([parentViewController isKindOfClass:UINavigationController.class]) {
        NSLog(@"⚠️ 不应从导航展现 MBModalPresentViewController，会导致导航 vc 堆栈判断错误");
    }
    if (!parentViewController) {
        parentViewController = [UIViewController rootViewControllerWhichCanPresentModalViewController];
    }

    UIView *dest = self.view;
    dest.autoresizingMask = UIViewAutoresizingFlexibleSize;
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:dest resizeOption:RFViewResizeOptionFill];

    // 解决 iPad 上动画弹出时 frame 不正确
    dest.hidden = YES;
    dispatch_after_seconds(0.05, ^{
        dest.hidden = NO;
        [self setViewHidden:NO animated:YES completion:completion];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:UINavigationController.class]) return;
    if (!self.disableAutoDismissWhenSegueTriggered) {
        [self dismissAnimated:YES completion:nil];
    }
    [super prepareForSegue:segue sender:sender];
}

- (IBAction)dismiss:(id)sender {
    if ([sender respondsToSelector:@selector(setEnabled:)]) {
        [(UIControl *)sender setEnabled:NO];
    }
    [self dismissAnimated:YES completion:nil];
}

- (void)dismissAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [MBAPI cancelOperationsWithViewController:self];
    if (self.willDismiss) {
        self.willDismiss(self);
    }
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
