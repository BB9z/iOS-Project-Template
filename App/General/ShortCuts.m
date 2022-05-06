
#import "ShortCuts.h"
#import "Common.h"

/**
 备忘
 
 保持这里的纯粹性——只提供快捷访问，和必要的简单变量缓存。
 不在这写创建逻辑，会导致难于维护
 */

// 先保留，objc 组件有引用
id AppDelegate(void);  // 让编译器安静
id AppDelegate(void) {
    return [UIApplication sharedApplication].delegate;
}

NavigationController *__nullable AppNavigationController() {
    return [MBApp status].globalNavigationController;
}

//MBWorkerQueue *AppWorkerQueue() {
//    return [MBApp status].workerQueue;
//}

//MBWorkerQueue *AppBackgroundWorkerQueue() {
//    return [MBApp status].backgroundWorkerQueue;
//}

static BOOL _itemFitClass(id __nullable item, Class __nullable exceptClass) {
    if (!item) return NO;
    if (exceptClass) {
        return [item isKindOfClass:exceptClass];
    }
    else {
        return YES;
    }
}

id __nullable AppCurrentViewControllerItem(Class __nullable exceptClass) {
    MBNavigationController *nav = AppNavigationController();
    UIViewController<MBGeneralItemExchanging> *vc = (id)(nav.presentedViewController?: nav.topViewController);
    id item = nil;
    if ([vc respondsToSelector:@selector(item)]) {
        item = vc.item;
    }
    if (_itemFitClass(item, exceptClass)) {
        return item;
    }
    for (UIViewController<MBGeneralItemExchanging> *subVC in vc.childViewControllers) {
        if ([subVC respondsToSelector:@selector(item)]) {
            item = subVC.item;
        }
        if (_itemFitClass(item, exceptClass)) {
            return item;
        }
    }
    return nil;
}

API *AppAPI(void) {
    return MBApp.status.api;
}

//BadgeManager *__nonnull AppBadge(void) {
//    return BadgeManager.defaultManager;
//}

MessageManager *__nonnull AppHUD(void) {
    return MBApp.status.hud;
}

#pragma mark -

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

AccountEntity *AppUserInformation() {
    return AppUser().information;
}

#pragma mark -

NSUserDefaults *AppUserDefaultsShared() {
    return [NSUserDefaults standardUserDefaults];
}

NSAccountDefaults *_Nullable AppUserDefaultsPrivate() {
    return AppUser().profile;
}

BOOL AppActive() {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
}

BOOL AppInBackground() {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateBackground;
}
