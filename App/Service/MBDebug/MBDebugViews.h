/*
 MBDebugViews
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing.h>

@class RFWindow;

@interface MBDebugWindowButton : UIButton <
    RFInitializing
>
@property (nonatomic, strong) RFWindow *win;

@end
