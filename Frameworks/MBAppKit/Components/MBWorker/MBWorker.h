/*
 MBWorker
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>
#import "MBGeneralCallback.h"

@class MBWorkerQueue;
@class MBUser;

typedef NS_ENUM(int, MBWorkerPriority) {
    MBWorkerPriorityNormal = 0,

    /// 队列空闲才执行
    MBWorkerPriorityIdle,

    /// 放到队列最前面，第一时间执行
    MBWorkerPriorityImmediately
};

/**
 定义一个操作，放在队列中依次执行

 重写创建具体的 worker
 */
@interface MBWorker : NSObject <
    RFInitializing
>

/// 所在的队列，为空未加入队列
@property (nullable, readonly, weak) MBWorkerQueue *queue;

/// 队列优先级
@property (nonatomic) MBWorkerPriority priority;

/// 操作可以在后台执行，默认操作只在前台执行
@property BOOL allowsBackgroundExecution;

/**
 标记操作需要用户登入
 
 置为 YES，当用户为登入时加入队列会直接抛弃。入队后会记住当前用户，
 执行时如果不是刚才的用户或已登出，直接会被抛弃掉
 */
@property BOOL requiresUserContext;

/// 自动设置
@property (nonatomic, nullable, strong) MBUser *userRequired;

/// 队列轮到这个 worker 执行了，可以在执行实际操作前加一个延迟
@property NSTimeInterval enqueueDelay;

/// 设置操作的执行不应早于某个时间
@property (nullable, copy) NSDate *executeNoEarlierThan;

/// 参考执行时间，超过执行时间队列可能跳过处理下一个任务
@property NSTimeInterval refrenceExecutionDuration;

/**
 队列在执行 worker 前，会调用这个方法。
 worker 可以决定是否执行，并可以修改队列，达到操作合并、去重的目的。
 在调用该方法时，receiver 已经从队列中移除了。
 
 @warning 这个方法可能在各种线程上被调用，修改队列本身是线程安全的
 
 @param setRefrence 从队列中移除的操作
 @return YES 跳过当前操作的执行，NO 正常执行
 */
- (BOOL)shouldSkipExecutionWithWorkersWillRemove:(NSArray<MBWorker *> *__nullable *__nonnull)setRefrence;

#pragma mark -

/// 重写执行具体操作
/// 除了业务操作外，要手工调用 finish 和 completionBlock
- (void)perform;

/// 通知队列操作结束
- (void)finish;

/// 可选的完成回调，需要手工调用
@property (nullable, copy) MBGeneralCallback completionBlock;

#pragma mark - Debug

#if DEBUG
/// 把 worker 添加到队列时的调用堆栈
@property (nullable) NSArray<NSString *> *enqueueCallStack;
#endif

@end
