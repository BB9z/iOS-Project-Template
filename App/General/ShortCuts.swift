/*!
 快速访问一些全局对象

 用函数而不是直接暴露全局变量，为了便于根据情况处理返回值，
 为日后解决模块间初始化依赖做铺垫，还利于调试（设置断点、打 log 都方便）

 函数替换为原始表达式也比变量替换更稳定

 实践过类似的方案，不如现在的用着舒服
 https://www.pointfree.co/blog/posts/21-how-to-control-the-world

 关于命名
 ----
 所有快捷访问函数均以 App 开头

 */

import Foundation

// swiftlint:disable force_cast identifier_name

/*
 实现备忘

 保持这里的纯粹性——只提供快捷访问，和必要的简单变量缓存。
 不在这写创建逻辑，会导致难于维护、破坏模块间依赖关系
 */

/// 应用状态，已进入前台，但不包括应用启动和前后台切换过程中
func AppActive() -> Bool {
    UIApplication.shared.applicationState == .active
}

/// 全局接口请求器
func AppAPI() -> API {
    MBApp.global.api
}

/// 编译环境，Debug、Alpha、Release
func AppBuildConfiguration() -> String {
    #if DEBUG
    "Debug"
    #elseif ALPHA
    "Alpha"
    #else
    "Release"
    #endif
}

/// 快速访问 application delegate 实例，可以在非主线程访问
func AppDelegate() -> ApplicationDelegate {
    appDelegate
}
// 直存一个变量，后续访问就不怕非主线程访问 delegate 了
private let appDelegate = UIApplication.shared.delegate as! ApplicationDelegate

/// 应用状态，是否处于后台
func AppInBackground() -> Bool {
    UIApplication.shared.applicationState == .background
}

/// 全局根视图
func AppRootViewController() -> RootViewController? {
    MBApp.global.rootViewController
}

/// 应用级别的配置项
func AppUserDefaultsShared() -> UserDefaults {
    UserDefaults.standard
}

/// 当前登录用户的配置项
func AppUserDefaultsPrivate() -> AccountDefaults? {
    AppUser()?.profile
}

/// 当前登录用户的账户信息
func AppUserInformation() -> AccountEntity? {
    AppUser()?.information
}
