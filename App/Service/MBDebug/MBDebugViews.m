
#import "MBDebugViews.h"
#import "NSUserDefaults+MBDebug.h"
#import "UIViewController+App.h"
#import "Common.h"
#if __has_include("FLEX/FLEX.h")
#import <FLEX/FLEX.h>
#endif

#import <RFAlpha/RFWindow.h>
#import "MBDebugFloatConsoleViewController.h"

@implementation MBDebugWindowButton
RFInitializingRootForUIView

- (void)onInit {
}

- (void)afterInit {
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self setupAsTopMostViewInWindow:self.window];
}

- (void)setupAsTopMostViewInWindow:(UIWindow *)window {
    if (!window || [window.subviews containsObject:self]) return;
    [window insertSubview:self atIndex:window.subviews.count];
}

@end
