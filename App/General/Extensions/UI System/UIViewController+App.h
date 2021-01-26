/*
 UIViewController+App

 Copyright © 2018, 2021 BB9z.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "UIKit+App.h"

@interface UIViewController (App)

// @MBDependency:4
/**
 安全的 presentViewController，仅当当前 vc 是导航中可见的 vc 时才 present
 
 @param completion presented 参数代表给定 vc 是否被弹出
 */
- (void)RFPresentViewController:(nonnull UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^ __nullable)(BOOL presented))completion;

@end
