/*!
 AccountManager
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation
import InterfaceApp

/**
 当前用户的管理模块

 注意用户变化依据是看用户对象的地址，详见 [InterfaceApp.IAAccount]
 */
public enum AccountManager {
    public static var current: IAAccount? {
        didSet {
            if oldValue === current { return }
            DispatchQueue.main.async {
                updateCurrent(oldValue: oldValue, newValue: current)
            }
        }
    }

    /**
     添加当前用户变化的监听

     - parameter observer: 非空对象。当 observer 释放时，监听随之失效
     - parameter initial: 是否立即调用回调，否则只有当当前用户再次变化时才会触发回调
     - parameter callback: 仅当当前用户确实变化时才会调用，且同一个用户不会重复调用
     */
    public static func observeCurrentChange(_ observer: AnyObject, initial: Bool, callback: @escaping (IAAccount?) -> Void) {
        _ = observerSet.add(initial: initial, observer: observer, callback: callback)
    }

    /**
     添加当前用户变化的监听

     - parameter initial: 是否立即调用回调，否则只有当当前用户再次变化时才会触发回调
     - parameter callback: 仅当当前用户确实变化时才会调用，且同一个用户不会重复调用
     - Returns: 监听对象，外部需保持该对象的持有，该对象释放后监听随之失效
     */
    public static func observeCurrentChange(initial: Bool, callback: @escaping (IAAccount?) -> Void) -> MBObservation {
        observerSet.add(initial: initial, callback: callback)
    }

    /**
     将 observer 从用户变化监听的队列中移除
     */
    public static func removeCurrentChangeObserver(_ observer: AnyObject?) {
        if let observer = observer {
            observerSet.remove(observer)
        }
    }

    private static let observerSet = _AFObserverSet<IAAccount?>(comparator: { oldValue, newValue in
        // 已有旧账户，判断地址；否则忽略空的新值
        if let old = oldValue as? IAAccount {
            return old === newValue
        }
        return newValue == nil
    })

    private static func updateCurrent(oldValue: IAAccount?, newValue: IAAccount?) {
        if current !== oldValue {
            oldValue?.didLogout()
        }
        if current === newValue {
            newValue?.didLogin()
        }
        observerSet.perform(context: newValue)
    }
}

public extension IAAccount {
    /// 是否是当前用户
    var isCurrent: Bool {
        return AccountManager.current === self
    }
}
