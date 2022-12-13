//
//  UserDefaults 字段定义
//  App
//

import Foundation

/**
 使用建议：

 UserDefaults 存一些简单的数据还是很好用的，方便，性能可以。但毕竟不是真正的数据库，应避免存入大量的数据。

 我记得它有存储量的限制，但文档里找不到了。在过去的实践中，存入量大时会出现存不进去的现象。

 一些 key 加了下滑线前缀，是为了兼容旧版；新加的属性直接用 #function 就好
 */
extension UserDefaults {
    /// 上次启动时间
    var applicationLastLaunchTime: Date? {
        get { object(forKey: "_" + #function) as? Date }
        set { set(newValue, forKey: "_" + #function) }
    }

    /// 上次启动时版本
    var lastVersion: String? {
        get { string(forKey: "_" + #function) }
        set { set(newValue, forKey: "_" + #function) }
    }

    /// 上次更新版本时的版本
    var previousVersion: String? {
        get { string(forKey: "_" + #function) }
        set { set(newValue, forKey: "_" + #function) }
    }

    /// App 总启动次数
    var launchCount: Int {
        get { integer(forKey: "_" + #function) }
        set { set(newValue, forKey: "_" + #function) }
    }

    /// 当前版本启动次数
    var launchCountCurrentVersion: Int {
        get { integer(forKey: "_" + #function) }
        set { set(newValue, forKey: "_" + #function) }
    }

    // MARK: - 用户信息

    /// 用户 ID，用作是否登入的判定
    var lastUserID: AccountID? {
        get { string(forKey: "_" + #function) }
        set { set(newValue, forKey: "_" + #function) }
    }

    var accountEntity: AccountEntity? {
        get { model(forKey: "_" + #function) }
        set { set(model: newValue, forKey: "_" + #function) }
    }

    var userToken: String? {
        get { string(forKey: "_" + #function) }
        set { set(newValue, forKey: "_" + #function) }
    }
}

// MARK: - 用户存储

/**
 专用于存需要跟用户账号绑定的状态

 区别于 UserDefaults.standard 存应用全局的状态
 */
class AccountDefaults: UserDefaults {
    override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
        migrateIfNeeded()
    }

    // 🔰 注意非 UserDefaults.standard 外，其他实例需要显式保存
//    var something: String? {
//        get { string(forKey: "_" + #function) }
//        set {
//            set(newValue, forKey: "_" + #function)
//            synchronize()
//        }
//    }

    private func migrateIfNeeded() {
        let currentVersion = MBApp.global.version
        guard let lastVersion = self.lastVersion else {
            self.lastVersion = currentVersion
            return
        }
        if lastVersion == currentVersion { return }
        // 具体迁移过程，比如移除新版不会在用的旧版 key，旧版 key 内容重新组装写入新版 key 中
        // 前面的版本写当前/新的版本
//        if <#"x.x.x"#>.compare(lastVersion, options: [.numeric]) == .orderedDescending {
//            removeObject(forKey: <#old-key-needs-removed-in-new-version#>)
//        }
        self.lastVersion = currentVersion
        synchronize()
    }
}

// MARK: - 存储类型支持

extension UserDefaults {
    // JSON Model 存储支持
    private func model<T: MBModel>(forKey key: String) -> T? {
        guard let data = data(forKey: key),
              let model = try? T(data: data) else {
            return nil
        }
        return model
    }
    private func set(model value: MBModel?, forKey key: String) {
        let data = value?.toJSONData()
        set(data, forKey: key)
    }

    // Codable 对象存储支持
    private func model<T: Codable>(forKey key: String) -> T? {
        guard let data = data(forKey: key),
              let model = try? JSONDecoder().decode(T.self, from: data) else {
            return nil
        }
        return model
    }
    private func set<T: Codable>(model value: T?, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: key)
    }
}
