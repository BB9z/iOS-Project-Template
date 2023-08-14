/*
 Current

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import UIKit

/**
 全局状态中心，挂载模块

 提供 mock 支持
 */
enum Current {
    // 请按字母顺序排列

    /// 当前登录的账号
    static var account: Account? {
        Mocked.account ?? AccountManager.current as? Account
    }

    /// 归属于当前账号的配置
    static var accountDefaults: AccountDefaults? {
        Mocked.accountDefaults ?? account?.profile
    }

    /// 全局接口请求器
    static var api: API {
        Mocked.api ?? {
            let instance = API()
            API.global = instance
            instance.networkActivityIndicatorManager = Current.hud
            Mocked.api = instance
            return instance
        }()
    }

    /// 快速访问 application delegate 实例
    static var appDelegate: ApplicationDelegate {
        Mocked.appDelegate ?? {
            let instance = UIApplication.shared.delegate as! ApplicationDelegate  // swiftlint:disable:this force_cast
            Mocked.appDelegate = instance
            return instance
        }()
    }

    /// 编译环境，Debug、Alpha、Release
    static var buildConfiguration: String {
        #if DEBUG
            "Debug"
        #elseif ALPHA
            "Alpha"
        #else
            "Release"
        #endif
    }

    /// 应用级别的配置项
    static var defualts: UserDefaults {
        Mocked.defualts ?? {
            let instance = UserDefaults.standard
            Mocked.defualts = instance
            return instance
        }()
    }

    /// UI 提示管理器
    static var hud: MessageManager {
        Mocked.hud ?? {
            let instance = MessageManager()
            Mocked.hud = instance
            return instance
        }()
    }

    static var identifierForVendor: String {
        Mocked.identifierForVendor ?? {
            let uuid = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
            Mocked.identifierForVendor = uuid
            return uuid
        }()
    }

    static var keyWindow: UIWindow? {
        Mocked.keyWindow ?? {
            (UIApplication.shared as DeprecatedKeyWindow).keyWindow
        }()
    }

    /// 主导航控制器
    static var navigationController: NavigationController? {
        Mocked.navigationController
    }

    /// 当前显示的根控制器
    static var rootViewController: RootViewController? {
        Mocked.rootViewController
    }

    /// 版本管理器
    static var version: VersionManager {
        Mocked.version ?? VersionManager.shared
    }
}

enum Mocked {
    static var account: Account?
    static var accountDefaults: AccountDefaults?
    static var api: API?
    static var appDelegate: ApplicationDelegate?
    static var defualts: UserDefaults?
    static var hud: MessageManager?
    static var identifierForVendor: String?
    static var keyWindow: UIWindow?
    static var navigationController: NavigationController?
    static var rootViewController: RootViewController?
    static var version: VersionManager?

    static func reset() {
        account = nil
        accountDefaults = nil
        api = nil
        appDelegate = nil
        defualts = nil
        hud = nil
        identifierForVendor = nil
        keyWindow = nil
        navigationController = nil
        rootViewController = nil
        version = nil
    }
}

private protocol DeprecatedKeyWindow {
    var keyWindow: UIWindow? { get }
}
extension UIApplication: DeprecatedKeyWindow {
}
