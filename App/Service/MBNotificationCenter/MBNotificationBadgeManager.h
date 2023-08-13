/*!
 MBNotificationBadgeManager
 MBNotificationCenter
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFInitializing/RFInitializing.h>
#import "MBAppKit.h"

/**
 小红点管理，状态的轮训
 
 使用：
 
 - 必须重写子类
 - 定义每个红点对应的数量属性
 - 可选，重写 statusPolling 执行红点数量刷新操作

 */
@interface MBNotificationBadgeManager: NSObject <
    RFInitializing
>

+ (nonnull instancetype)defaultManager;
+ (void)setDefaultManager:(nullable __kindof MBNotificationBadgeManager *)defaultManager;

/**
 默认 YES，用户登录时开启状态轮询，登出关闭轮询并清理共享实例；否则什么也不做
 仅在初始化时设置有效
 */
@property BOOL requiresUser;

/**
 开启轮询，周期执行 statusPolling 方法
 */
@property (nonatomic) BOOL pollingEnabled;

/**
 轮询间隔，默认 10s

 重置 pollingEnabled 才会生效
 */
@property NSTimeInterval pollingInterval;

/**
 子类重写，执行轮训逻辑
 
 默认什么也没做，实现备忘：
 
 - 开启轮询后，大约每隔 pollingInterval 触发一次
 - 为了避免同时发起多个请求阻塞请求队列，应当每次轮询只检查一个状态
 */
- (void)statusPolling;

/**
 通知 badge view 们红点数已变更
 
 需要红点刷新逻辑在数量变更时手动调用，
 通知将延迟一点发送，多次密集调用不会产生多次操作
 */
- (void)setNeedsPostStatusChangedNotification;

@end

/// 状态变化时发出的通知
extern NSNotificationName __nonnull const MBNotificatioBadgeChangedNotification;
