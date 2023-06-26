/*!
 shadow.h
 MBAppKit
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 
 MBAppKit 套件是通用的，不能定义与业务直接关联的东西。
 但写一个通用的流程上的东西又难免需要引用业务模块，通过这个头文件来引入项目中的代码。
 其中的方法需要在项目中定义。
 */
#pragma once

#import <Foundation/Foundation.h>

#if defined(MBBuildConfiguration)
#   error "这个文件不应导出到项目"
#endif

#pragma mark - ShortCuts

@class MBApplicationDelegate;
MBApplicationDelegate *__nullable AppDelegate(void);

/// 当前登录的用户，可以用来判断是否已登录
id __nullable AppUser(void);

@class MBNavigationController;
/// 全局导航
MBNavigationController *__nullable AppNavigationController(void);
