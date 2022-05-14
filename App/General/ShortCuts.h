//
//  ShortCuts
//  App
//
#import <MBAppKit/MBModel.h>

/**
 快速访问一些全局对象，见 ShortCuts.swift
 */

NS_ASSUME_NONNULL_BEGIN

@class NavigationController;
/// 全局导航
FOUNDATION_EXPORT NavigationController *__nullable AppNavigationController(void);

@class MessageManager;
FOUNDATION_EXPORT MessageManager *__nonnull AppHUD(void);

@class Account;
/// 当前登录的用户，可以用来判断是否已登录
FOUNDATION_EXPORT Account *__nullable AppUser(void);

/// 当前用户的 ID
#if MBUserStringUID
FOUNDATION_EXPORT MBIdentifier __nullable AppUserID(void);
#else
FOUNDATION_EXPORT MBID AppUserID(void);

/// 总是非空
FOUNDATION_EXPORT NSNumber *AppUserIDNumber(void);
#endif

NS_ASSUME_NONNULL_END
