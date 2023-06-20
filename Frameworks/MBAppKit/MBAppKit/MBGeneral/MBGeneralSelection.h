/*
 MBGeneralSelection
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <Foundation/Foundation.h>

/**
 声明对象会响应选取事件
 
 典型场景：组件嵌套时，里层的代码通过响应者链把选取事件发送给上层
 */
@protocol MBGeneralSelection <NSObject>
@optional
- (void)onSelect:(nonnull id)sender;

- (void)onDeselect:(nonnull id)sender;

@end
