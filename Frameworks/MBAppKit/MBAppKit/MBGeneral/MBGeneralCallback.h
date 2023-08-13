/*!
 MBGeneralCallback
 MBAppKit
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/*!
 统一异步操作的回调
 
 这个话题可以分为定义和使用两部分。首先是定义，
 一个异步操作的回调被定义为包含操作结果成功或失败、操作返回的对象、错误信息三部分。
 
 成功与否用一个 bool 区分，取消也算失败。失败时应该返回不为空的 NSError 对象

 响应的话可以统一为下面的形式

 @code

 ^(BOOL success, id _Nullable item, NSError *_Nullable error) {
     if (!success) {
         if (error) {
             // 明确失败
             // 处理失败，如提示用户
         }
         // 否则通常是取消
         return;
     }

     // 成功，使用数据
 }

 @endcode
 */


/**
 一般的异步请求数据回调
 
 success 表示成功、失败，取消也算失败。失败时 error 不应为空；取消 error 应为空
 */
typedef void (^MBGeneralCallback)(BOOL success, id _Nullable item, NSError *_Nullable error);

/**
 一般的异步请求数据回调
 
 success 表示成功、失败，取消也算失败。失败时 error 不应为空
 */
typedef void (^MBGeneralOperationCallback)(BOOL success, NSError *_Nullable error);


/**
 使用：

 typedef MBGeneralCallback(类型名, 对象类型);
 */
#define MBGeneralCallback(TYPE_NAME, OBJ_TYPE) void (^TYPE_NAME)(BOOL success, OBJ_TYPE _Nullable item, NSError *_Nullable error);

/**
 生成一个非空的，可在主线程同步安全执行的 callback
 */
FOUNDATION_EXPORT MBGeneralCallback _Nonnull MBSafeCallback(MBGeneralCallback _Nullable callback);

/**
 生成一个非空的 callback，并会在指定队列异步执行

 @param queue 回调执行的队列，不能为空。否则会抛出 NSInternalInconsistencyException 异常
 */
FOUNDATION_EXPORT MBGeneralCallback _Nonnull MBSafeCallbackExecutedOnDispatchQueue(MBGeneralCallback _Nullable callback, dispatch_queue_t _Nonnull queue);

/**
 其他备忘
 -----
 
 关于在同一个线程执行原始回调的备忘
 
 有这种需求看上去是很正常的，我在一个线程上申请做点东西，等后台处理完再回到原来的线程继续。但为什么 dispatch_get_current_queue() 被废弃并明确警告不要用、[NSOperationQueue currentQueue] 的返回可能是空？那我用 [NSThread currentThread] 获取当前线程，再 performSelector:onThread: 行不行？
 
 问题是线程也是有生命周期的，不论我们用 GCD 还是什么开了一个线程，预期的操作完了就应该结束掉这个线程。如果我们尝试获取这个线程，再试图在上面继续做点东西的话，这个回调的执行就是创建线程时预期外的。当我们尝试执行回调时，线程的状态是不确定的，可能已经释放掉了，可能执行完预定的任务准备销毁……
 
 所以，不要尝试这么做。我们无法保证回调一定会在原始线程上能执行，测试时这种情况并不少见。
 */
