//
//  UserDefaults 字段定义
//  App
//

import Foundation

/**
 使用建议：

 UserDefaults 存一些简单的数据还是很好用的，方便，性能可以。但毕竟不是真正的数据库，应避免存入大量的数据。
 */
extension UserDefaults {
    /// 用户 ID，用作是否登入的判定
    var lastUserID: AccountID? {
        get { object(forKey: #function) as? Int64 }
        set { set(newValue, forKey: #function) }
    }

    var accountEntity: AccountEntity? {
        get { model(forKey: #function) }
        set { set(model: newValue, forKey: #function) }
    }

    var userToken: String? {
        get { string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}

// MARK: - 用户存储

/**
 专用于存需要跟用户账号绑定的状态

 区别于 UserDefaults.standard 存应用全局的状态
 */
class AccountDefaults: UserDefaults {
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
