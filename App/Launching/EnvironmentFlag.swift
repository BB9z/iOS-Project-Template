//
//  EnvironmentFlag.swift
//  App
//

/**
关于状态

MBENVFlag 描述的应该是可以持续的状态，而不是一个瞬间发生的事件，
事件用通知、delegate 之类的响应就好了，MBEnvironment 不是干这个的。

@warning MBENVFlag 状态不应持久化
*/
extension MBENVFlag {
    //- 应用整体状态
    /// 应用现在处于前台
    static let appInForeground = MBENVFlag(rawValue: 1 << 0)

    /// 应用启动后至少进过一次前台
    static let appHasEnterForegroundOnce = MBENVFlag(rawValue: 1 << 1)

    /// 网络是否在线
    static let online = MBENVFlag(rawValue: 1 << 2)

    //- 用户状态
    /// 用户已登入
    static let userHasLogged = MBENVFlag(rawValue: 1 << 4)

    /// 本次启动当前用户的用户信息已成功获取过
    static let userInfoFetched = MBENVFlag(rawValue: 1 << 5)

    //- 模块生命周期
    /// 导航已加载
    static let naigationLoaded = MBENVFlag(rawValue: 1 << 10)

    /// 主页已载入
    static let homeLoaded = MBENVFlag(rawValue: 1 << 11)
}
