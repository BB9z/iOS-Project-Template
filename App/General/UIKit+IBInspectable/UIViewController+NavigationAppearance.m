
#import "UIViewController+NavigationAppearance.h"
#import "MBNavigationController.h"
#import <RFAlpha/RFSynthesizeCategoryProperty.h>
#import <RFKit/NSDictionary+RFKit.h>

@implementation UIViewController (RFDNavigationAppearance)

RFSynthesizeCategoryBoolProperty(RFPrefersStatusBarHidden, setRFPrefersStatusBarHidden)
RFSynthesizeCategoryBoolProperty(RFPrefersNavigationBarHidden, setRFPrefersNavigationBarHidden)
RFSynthesizeCategoryBoolProperty(RFPrefersNavigationBarShadowHidden, setRFPrefersNavigationBarShadowHidden)
RFSynthesizeCategoryBoolProperty(RFPrefersBottomBarShown, setRFPrefersBottomBarShown)
RFSynthesizeCategoryObjectProperty(RFPreferredNavigationBarColor, setRFPreferredNavigationBarColor, UIColor *, OBJC_ASSOCIATION_COPY)
RFSynthesizeCategoryBoolProperty(RFPrefersLightContentBarStyle, setRFPrefersLightContentBarStyle)
RFSynthesizeCategoryBoolProperty(RFPrefersPopGestureRecognizeAssistance, setRFPrefersPopGestureRecognizeAssistance)
RFSynthesizeCategoryBoolProperty(RFPrefersDisabledInteractivePopGesture, setRFPrefersDisabledInteractivePopGesture)
RFSynthesizeCategoryBoolProperty(pefersTransparentBar, setPefersTransparentBar)

- (NSMutableDictionary<RFViewControllerAppearanceAttributeKey,id> *)RFNavigationAppearanceAttributes {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
    dic[RFViewControllerPrefersNavigationBarHiddenAttribute] = @(self.RFPrefersNavigationBarHidden);
    dic[RFViewControllerPrefersBottomBarShownAttribute] = @(self.RFPrefersBottomBarShown);
    dic[RFViewControllerPefersTransparentBar] = @(self.pefersTransparentBar);
    [dic rf_setObject:self.RFPreferredNavigationBarColor forKey:RFViewControllerPreferredNavigationBarTintColorAttribute];
    if (self.RFPrefersLightContentBarStyle) {
        dic[RFViewControllerPreferredNavigationBarItemColorAttribute] = [UIColor whiteColor];
        dic[RFViewControllerPreferredNavigationBarTitleTextAttributes] = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    }
    return dic;
}

- (BOOL)prefersStatusBarHidden {
    return self.RFPrefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.RFPrefersLightContentBarStyle? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

@end

RFDefineConstString(RFViewControllerPefersTransparentBar);
