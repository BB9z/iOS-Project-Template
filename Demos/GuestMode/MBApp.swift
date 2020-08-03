//
//  MBApp.swift
//  App
//

/**
 全局变量中心

 这里主要是挂载一些公共模块的实例
 */
@objc
class MBApp: NSObject {
    static var global = MBApp()
    @objc class func status() -> MBApp {
        return Self.global
    }

    // MARK: - 挂载的 manager

    /// UI 提示管理器
    @objc lazy var hud = MessageManager()

    /// 
    @objc var rootViewController: RootViewController?

    /// 全局导航
    @objc var globalNavigationController: NavigationController?
}
