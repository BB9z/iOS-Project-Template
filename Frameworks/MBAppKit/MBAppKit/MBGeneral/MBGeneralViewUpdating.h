/*!
 MBGeneralViewUpdating
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 统一 UIView 的生命周期

 基类应实现全部下面三个方法
 */
@protocol MBGeneralViewUpdating <NSObject>

@optional

/**
 做更新操作
 */
- (void)setNeedsUpdateView;

/**
 添加监听，子类应该调用 super
 */
- (void)addObservers;

/**
 移除监听，子类应该调用 super
 */
- (void)removeObservers;

@end

/**
 应该定义为私有属性
 */
#define MBDefineGeneralViewUpdatingProperties \
    @property (nonatomic) BOOL observingEventForGeneralViewUpdating;

/**
 setNeedsUpdateView 方法需要单独写，
willMoveToWindow:, setObservingEventForGeneralViewUpdating: 会生成
 */
#define MBSynthesizeGeneralViewUpdatingMethods \
    - (void)willMoveToWindow:(UIWindow *)newWindow {\
        if (newWindow) {\
            self.observingEventForGeneralViewUpdating = YES;\
            [self setNeedsUpdateView];\
        }\
        else {\
            self.observingEventForGeneralViewUpdating = NO;\
        }\
    }\
    - (void)setObservingEventForGeneralViewUpdating:(BOOL)observingEventForGeneralViewUpdating {\
        if (_observingEventForGeneralViewUpdating != observingEventForGeneralViewUpdating) {\
            if (_observingEventForGeneralViewUpdating) {\
                [self removeObservers];\
            }\
            _observingEventForGeneralViewUpdating = observingEventForGeneralViewUpdating;\
            if (observingEventForGeneralViewUpdating) {\
                [self addObservers];\
            }\
        }\
    }\
