/*!
 VersionManager
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import InterfaceApp
import Foundation

/**
 版本管理器
 */
public final class VersionManager {
    /// 创建时执行初始化逻辑，不应创建多个实例
    public static let shared = VersionManager()

    /// 短版本号，形如 1.0
    public let version: String

    /// 本次启动如有升级，值是旧版本号，否则为空
    private(set) var upgardeFrom: String?

    /// 是否是全新安装
    public let isFreshInstall: Bool

    /// 是否处于安全模式，连续未成功启动变为 true
    ///
    /// 业务侧应根据该状态进行兜底处理
    private(set) var isInSafeMode = false

    /// 应用启动后调用
    ///
    /// 建议在 AppDelegate 中尽早调用
    public func markAppLaunching() {
        guard launchCallGuardFlag == 0 else {
            MBAssert(launchCallGuardFlag != 1, "重复调用 \(#function)")
            MBAssert(launchCallGuardFlag != 2, "启动完成后又调用了 \(#function)")
            return
        }
        launchCallGuardFlag = 1
        self.storage._launchCount += 1
        self.storage._launchCountCurrentVersion += 1
        self.storage._unsafeLaunchCount += 1
        self.storage._applicationLastLaunchTime = Date()
        if self.storage._unsafeLaunchCount > 2 {
            isInSafeMode = true
        }
    }

    /// 已调用应用启动完成方法
    var isLaunchFinshed: Bool {
        launchCallGuardFlag == 2
    }

    /// 标记应用本次启动是成功的
    ///
    /// 典型的调用时机：主页已加载成功、应用进入前台、应用启动几秒后（尤其是后台启动）
    public func markAppLaunchedSuccessful() {
        guard launchCallGuardFlag == 1 else {
            MBAssert(launchCallGuardFlag != 0, "未调用 markAppLaunching()")
            MBAssert(launchCallGuardFlag != 2, "已标记启动结果")
            return
        }
        launchCallGuardFlag = 2
        self.storage._unsafeLaunchCount = 0
        isInSafeMode = false
    }

    // MARK: -

    private var launchCallGuardFlag = 0
    private var storage: IASimpleKeyValueStorage

    internal convenience init(storage: IASimpleKeyValueStorage = UserDefaults.standard) {
        guard let bundleVerison = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            fatalError()
        }
        self.init(storage: storage, version: bundleVerison)
    }

    // For testing
    internal init(storage: IASimpleKeyValueStorage, version: String) {
        self.storage = storage
        self.version = version

        guard let lastVersion = storage._lastVersion else {
            isFreshInstall = true
            // 全新启动
            self.storage._lastVersion = version
            return
        }
        isFreshInstall = false
        if lastVersion != version {
            // 应用升级了
            upgardeFrom = lastVersion
            self.storage._previousVersion = lastVersion
            self.storage._lastVersion = version
            self.storage._launchCountCurrentVersion = 0
        }
    }
}

extension IASimpleKeyValueStorage {
    // TODO: 上次启动时间
    var _applicationLastLaunchTime: Date? {
        get { try? date(forKey: #function) }
        set { try? set(date: newValue, forKey: #function) }
    }

    /// 上次启动时版本
    var _lastVersion: String? {
        get { try? string(forKey: #function) }
        set { try? set(string: newValue, forKey: #function) }
    }

    /// 上次更新版本时的版本
    var _previousVersion: String? {
        get { try? string(forKey: #function) }
        set { try? set(string: newValue, forKey: #function) }
    }

    /// App 总启动次数
    var _launchCount: Int {
        get { (try? int(forKey: #function)) ?? 0 }
        set { try? set(int: newValue, forKey: #function) }
    }

    /// 当前版本启动次数
    var _launchCountCurrentVersion: Int {
        get { (try? int(forKey: #function)) ?? 0 }
        set { try? set(int: newValue, forKey: #function) }
    }

    /// 连续不成功启动的次数
    var _unsafeLaunchCount: Int {
        get { (try? int(forKey: #function)) ?? 0 }
        set { try? set(int: newValue, forKey: #function) }
    }
}
