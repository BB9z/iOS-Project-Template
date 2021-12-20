/*
 MBLoadButton
 
 Copyright © 2018, 2021 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBButton.h"

/**
 加载时 enabled 状态变为 NO，加载结束时恢复；加载失败时状态变为 selected
 
 跟 RFRefreshButton 类似，加载状态通过观察属性的方式自动设置
 */
@interface MBLoadButton : MBButton

@property (nonatomic) IBInspectable BOOL hidesWhenCompletion;

- (void)setLoadding:(BOOL)loadding;
- (void)setSuccess:(BOOL)success;

#pragma mark - Auto update statue
@property (readonly, getter = isObserving, nonatomic) BOOL observing;
@property (weak, readonly, nullable) id observeTarget;
@property (copy, readonly, nullable) NSString *observeKeypath;

/**
 @param target Must not be nil.
 @param keypath Must not be nil.
 @param ifProcessingBlock Return `YES` if the observed target is processing. This parameter may be nil.
 */
- (void)observeTarget:(nonnull id)target forKeyPath:(nonnull NSString *)keypath evaluateBlock:(BOOL (^__nullable)(id __nullable evaluatedVaule))ifProcessingBlock;
- (void)stopObserve;
@end
