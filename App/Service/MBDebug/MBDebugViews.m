
#import "MBDebugViews.h"
#import "NSUserDefaults+MBDebug.h"
#import "UIViewController+App.h"
#import "Common.h"
#if __has_include("FLEX/FLEX.h")
#import <FLEX/FLEX.h>
#endif

@implementation MBDebugContainerView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!NSUserDefaults.standardUserDefaults._debugEnabled) {
        [self removeFromSuperview];
    }
}

@end


@implementation MBDebugContainerScrollView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!NSUserDefaults.standardUserDefaults._debugEnabled) {
        [self removeFromSuperview];
    }
}

@end

#import <RFAlpha/RFWindow.h>
#import "MBDebugFloatConsoleViewController.h"

@interface MBDebugWindowButton ()
@property (nonatomic) BOOL enableObserverActived;
@end

@implementation MBDebugWindowButton
RFInitializingRootForUIView

- (void)onInit {
    [self addTarget:self action:@selector(onButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

#if TARGET_OS_SIMULATOR

- (void)afterInit {
    self.enableObserverActived = YES;
#if __has_include("FLEX/FLEX.h") && DEBUG
    FLEXManager *fm = [FLEXManager sharedManager];
    [fm registerSimulatorShortcutWithKey:@"d" modifiers:UIKeyModifierControl action:^{
        NSUserDefaults.standardUserDefaults._debugEnabled = YES;
        [self onButtonTapped];
    } description:@"Toggle debug menu"];
#endif
}

- (void)setEnableObserverActived:(BOOL)enableObserverActived {
    if (_enableObserverActived == enableObserverActived) return;
    if (_enableObserverActived) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:NSUserDefaults.standardUserDefaults];
    }
    _enableObserverActived = enableObserverActived;
    if (enableObserverActived) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onUserDefaultsChanged) name:NSUserDefaultsDidChangeNotification object:NSUserDefaults.standardUserDefaults];
    }
}

- (void)onUserDefaultsChanged {
    dispatch_async_on_main(^{
        BOOL debugMode = NSUserDefaults.standardUserDefaults._debugEnabled;
        self.hidden = !debugMode;
    });
}

- (void)dealloc {
    self.enableObserverActived = NO;
}
#else
- (void)afterInit {
}
#endif // END: TARGET_OS_SIMULATOR

- (void)didMoveToWindow {
    [super didMoveToWindow];
#if TARGET_OS_SIMULATOR
    [self setupAsTopMostViewInWindow:self.window];
    self.hidden = !NSUserDefaults.standardUserDefaults._debugEnabled;
#else
    if (!NSUserDefaults.standardUserDefaults._debugEnabled) {
        [self removeFromSuperview];
    }
    else {
        [self setupAsTopMostViewInWindow:self.window];
    }
#endif
}

- (void)setupAsTopMostViewInWindow:(UIWindow *)window {
    if (!window || [window.subviews containsObject:self]) return;
    [window insertSubview:self atIndex:window.subviews.count];
}

- (void)onButtonTapped {
    if (!self.win) {
        RFWindow *win = [[RFWindow alloc] init];
        win.backgroundColor = nil;
        self.win = win;
    }
    self.win.rootViewController = [MBDebugFloatConsoleViewController newWithStoryboardName:@"MBDebug" identifier:nil];
    self.win.hidden = NO;
}

+ (void)installToKeyWindow {
    UIWindow *w = UIApplication.sharedApplication.keyWindow;
    MBDebugWindowButton *button = [MBDebugWindowButton.alloc initWithFrame:CGRectMake(5, w.frame.size.height -20 -5, 20, 20)];
    button.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    [w addSubview:button];
}

@end
