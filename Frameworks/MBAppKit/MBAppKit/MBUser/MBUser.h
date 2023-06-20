/*!
 MBUser
 MBAppKit
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import "MBModel.h"
#import <RFInitializing/RFInitializing.h>

/**
 当前用户的管理模块
 
 App 应重载这个类并重写其中的方法
 */
@interface MBUser : NSObject <
    RFInitializing
>

#pragma mark - 当前用户

/**
 当前已登录的用户，用户未登录返回 nil，置 nil 标记为登出
 */
@property (nullable, class) __kindof MBUser *currentUser;

/// 是否是当前用户
@property (readonly) BOOL isCurrent;

typedef void (^MBUserCurrentUserChangeCallback)(__kindof MBUser *__nullable currentUser);

/**
 添加当前用户变化的监听
 
 @param observer 非空对象。当 observer 释放时，监听会自行移除
 @param initial 是否立即调用回调，否则只有当当前用户再次变化时才会触发回调
 @param callback 仅当当前用户确实变化时（用户 ID 不同）才会调用，且同一个用户不会重复调用
 */
+ (void)addCurrentUserChangeObserver:(nonnull __weak id)observer initial:(BOOL)initial callback:(nonnull MBUserCurrentUserChangeCallback)callback;

/**
 将 observer 从用户变化监听的队列中移除
 */
+ (void)removeCurrentUserChangeObserver:(nullable id)observer;

#pragma mark - 状态

- (nullable instancetype)initWithID:(nonnull MBIdentifier)uid NS_DESIGNATED_INITIALIZER;

- (null_unspecified instancetype)init NS_UNAVAILABLE;

/// 用户 ID
@property (nonnull, readonly) MBIdentifier uid;

#pragma mark - 子类重写

/**
 子类重写，设置类 currentUser 属性后执行
 
 总是在主线程执行
 */
+ (void)onCurrentUserChanged:(__kindof MBUser *__nullable)currentUser;

/**
 子类重写，成为当前用户时执行的操作
 
 总是在主线程执行
 */
- (void)onLogin;

/**
 子类重写，用户登出时执行的操作
 
 总是在主线程执行
 */
- (void)onLogout;

@end
