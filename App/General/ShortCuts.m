
#import "ShortCuts.h"
#import "Common.h"

// 先保留，objc 组件有引用
id AppDelegate(void);  // 让编译器安静
id AppDelegate(void) {
    return [UIApplication sharedApplication].delegate;
}

NavigationController *__nullable AppNavigationController() {
    return [MBApp status].globalNavigationController;
}

MessageManager *__nonnull AppHUD(void) {
    return MBApp.status.hud;
}

Account *__nullable AppUser() {
    return [Account currentUser];
}

#if MBUserStringUID
MBIdentifier AppUserID() {
    return AppUser().uid;
}
#else
MBID AppUserID() {
    return AppUser().uid;
}

static NSNumber *_UserIDNumberCache;
static MBID _UserIDNumberCacheVerify;
NSNumber *AppUserIDNumber() {
    if (_UserIDNumberCache
        && AppUserID() == _UserIDNumberCacheVerify) {
        return _UserIDNumberCache;
    }
    _UserIDNumberCache = @(AppUserID());
    return _UserIDNumberCache;
}
#endif
