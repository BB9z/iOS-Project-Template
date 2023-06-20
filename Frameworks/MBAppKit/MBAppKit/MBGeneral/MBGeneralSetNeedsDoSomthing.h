/*!
 MBGeneralSetNeedsDoSomthing
 MBAppKit

 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
*/
#import <RFKit/RFRuntime.h>
#import <objc/runtime.h>

/*!
 setNeedsDoSomething 是一种范式，其他代码请求我们做什么事，我们不立即去做而是设置了一个标示，
 等一段时间后再去执行实际操作，从而避免没必要的反复执行。

 熟悉的例子像 UIView 有 layoutSubviews 方法，但重新布局是很昂贵的，所以提供了 setNeedsLayout 方法，
 系统会在合适的时机去更新。
 */


/**
 @define MBSynthesizeSetNeedsMethodUsingAssociatedObject

 生成一个 setNeeds 方法
 
 使用 associated object 生成锁
 
 @param DO_METHOD 在主线程延迟执行，这个方法必须是同步的，否则锁可能过早释放
 */
#define MBSynthesizeSetNeedsMethodUsingAssociatedObject(METHOD_NAME, DO_METHOD, DELAY_IN_SECOND) \
    - (void)METHOD_NAME {\
        const void *key = _cmd;\
        if (objc_getAssociatedObject(self, key)) return;\
        objc_setAssociatedObject(self, key, @YES, OBJC_ASSOCIATION_ASSIGN);\
        dispatch_after_seconds((DELAY_IN_SECOND), ^{\
            if (objc_getAssociatedObject(self, key)) {\
                [self DO_METHOD];\
                objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);\
            }\
        });\
    }

/**
 @define MBSynthesizeSetNeedsDelayMethodUsingAssociatedObject
 
 和 MBSynthesizeSetNeedsMethodUsingAssociatedObject 类似，不同之处在于每次设置都会推迟最终操作的执行时间

 @param DO_METHOD 在主线程延迟执行，这个方法必须是同步的，否则锁可能过早释放
 */
#define MBSynthesizeSetNeedsDelayMethodUsingAssociatedObject(METHOD_NAME, DO_METHOD, DELAY_IN_SECOND) \
    - (void)METHOD_NAME {\
        const void *key = _cmd;\
        NSInteger count = [(NSNumber *)objc_getAssociatedObject(self, key) integerValue];\
        objc_setAssociatedObject(self, key, @(++count), OBJC_ASSOCIATION_ASSIGN);\
        dispatch_after_seconds((DELAY_IN_SECOND), ^{\
            NSInteger delayCount = [(NSNumber *)objc_getAssociatedObject(self, key) integerValue];\
            if (delayCount == count) {\
                [self DO_METHOD];\
                objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_ASSIGN);\
            }\
        });\
    }
