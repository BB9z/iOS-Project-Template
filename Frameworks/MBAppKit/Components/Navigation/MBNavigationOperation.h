/*!
 MBNavigationOperation
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFInitializing/RFInitializing.h>
#import <RFKit/RFRuntime.h>

@class MBNavigationController;

/**
 导航执行队列
 */
@interface MBNavigationOperation : NSObject <
    RFInitializing
>

/**
 创建导航队列对象
 
 @return 如果创建的对象不通过 `validateConfiguration` 方法的检测，返回空
 */
+ (nullable instancetype)operationWithConfiguration:(NS_NOESCAPE void (^__nonnull)(__kindof MBNavigationOperation *__nonnull operation))configBlock;

/**
 验证 operationWithConfiguration 创建的对象是否有效
 
 不同的的队列操作需要满足不同的状态，在加入执行队列前要进行检测
 */
- (BOOL)validateConfiguration;

/// 默认为NO，不提供动画
@property BOOL animating;

/// 用于限制导航操作只可在特定页面弹出
@property (nullable) NSArray<Class> *topViewControllers;

/// 子类重写，子类属性的 description 描述
- (nullable NSString *)subClassPropertyDescription;

/**
 子类重写
 
 @return 操作是否被实际执行了
 */
- (BOOL)perform:(nonnull MBNavigationController *)controller;

/// 自定义操作
@property (nullable) BOOL (^performBlock)(__kindof MBNavigationOperation *__nonnull operation, MBNavigationController *__nonnull controller);

@end

/**
 
 */
@interface MBPopNavigationOperation : MBNavigationOperation
@end

/**
 弹出一个 UIAlertController
 */
@interface MBAlertNavigationOperation : MBNavigationOperation
@property (nonnull) UIAlertController *alertController;
@end

