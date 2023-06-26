
#import "ShortCuts.h"
#import "Common.h"

// 先保留，objc 组件有引用
id AppDelegate(void);  // 让编译器安静
id AppDelegate(void) {
    return [UIApplication sharedApplication].delegate;
}

id AppUser(void) {
    return nil;
}

NavigationController *__nullable AppNavigationController() {
    return [MBApp status].globalNavigationController;
}

MessageManager *__nonnull AppHUD(void) {
    return MBApp.status.hud;
}
