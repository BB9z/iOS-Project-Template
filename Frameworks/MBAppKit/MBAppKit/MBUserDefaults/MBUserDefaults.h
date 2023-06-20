/*!
 MBUserDefaults
 MBAppKit
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 推荐用法
 
 NSUserDefaults 适合用来持久化少量数据，存储大量数据会增加保存失败的几率；
 NSUserDefaults 可以通过 xxxForKey:，setXXXForKey: 的方式来读写，但不推荐直接使用；
 推荐创建 category，用属性把 key 封装起来；
 如果应用有用户体系，推荐用户有自己的 NSUserDefaults，standardUserDefaults 作为共享数据库只存应用级别的数据；
 NSUserDefaults 里的键值应该有版本概念，应用升级时可以移除、转移旧的键值。
 */

/**
 扩展一些同步的方法
 */
@interface NSUserDefaults (Sync)

/**
 标记需要执行 synchronize
 
 同步操作将在一段时间之后执行，若反复调用会一直推迟同步。
 */
- (void)setNeedsSynchronized;

/**
 执行一些修改后立即调用 synchronize
 
 @return synchronize 是否成功
 */
- (BOOL)synchronizeBlock:(NS_NOESCAPE void (^__nonnull)(__kindof NSUserDefaults *__nonnull u))block;

@end

/**
 作为每一用户独立的数据库
 
 @warning standardUserDefaults 会自动同步，而这个不会。
 如果属性的实现用的是 _makeXXXProperty，同步操作已经有了妥当处理。
 为了统一，自定义实现的方法需要在设置时调用 setNeedsSynchronized。
 */
@interface NSAccountDefaults : NSUserDefaults

- (BOOL)synchronizeBlock:(NS_NOESCAPE void (^__nonnull)(NSAccountDefaults *__nonnull u))block;
@end

