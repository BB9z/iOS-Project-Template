
#import "UIViewController+App.h"

@implementation UIViewController (App)

- (void)RFPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(BOOL presented))completion {
    UINavigationController *nav = self.navigationController;
    if (!nav) {
        NSLog(@"⚠️ 当前 vc 不在导航中，RFPresent 只支持处于导航中的 vc 管理");
        if (completion) {
            completion(NO);
        }
        return;
    }
    UIViewController *navVisible = nav.visibleViewController;
    BOOL isNavVisible = NO;
    UIViewController *vc = self;
    while (vc) {
        if (vc == navVisible) {
            isNavVisible = YES;
            break;
        }
        vc = vc.parentViewController;
    }
    if (!self.isViewAppeared
        || !isNavVisible) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    [nav presentViewController:viewControllerToPresent animated:flag completion:^{
        if (completion) {
            completion(YES);
        }
    }];
}

@end
