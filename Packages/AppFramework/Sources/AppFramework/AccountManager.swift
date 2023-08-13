/*!
 AccountManager
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import B9Action
import B9MulticastDelegate
import Foundation
import InterfaceApp

/**
 当前用户的管理模块
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

    public typealias AccountChangedCallback = (IAAccount?) -> Void

    /**
     添加当前用户变化的监听

     - parameter observer: 非空对象。当 observer 释放时，监听会自行移除
     - parameter initial: 是否立即调用回调，否则只有当当前用户再次变化时才会触发回调
     - parameter callback: 仅当当前用户确实变化时（用户 ID 不同）才会调用，且同一个用户不会重复调用
     */
    public static func addCurrentUserChangeObserver(_ observer: AnyObject, initial: Bool, callback: @escaping AccountChangedCallback) {
        DispatchQueue.main.async {
            let obj = ChangedObserver(callback)
            obj.observer = observer
            obj.calledID = UUID().uuidString
            changeObservers.append(obj)
            if initial {
                noticeCurrentChanged.set()
            }
        }
    }

    /**
     将 observer 从用户变化监听的队列中移除
     */
    public static func removeCurrentUserChangeObserver(_ observer: AnyObject?) {
        DispatchQueue.main.async {
            changeObservers = changeObservers.filter { obj in
                obj.observer != nil && obj.observer !== observer
            }
        }
    }

    private static func updateCurrent(oldValue: IAAccount?, newValue: IAAccount?) {
        if current !== oldValue {
            oldValue?.onLogout()
        }
        if current === newValue {
            newValue?.onLogin()
        }
        noticeCurrentChanged.set()
    }
    private static var noticeCurrentChanged = DelayAction(Action(_noticeUserChanged))
    private static func _noticeUserChanged() {
        let user = current
        var needsClean = false
        for obj in changeObservers {
            if obj.observer == nil {
                needsClean = true
                continue
            }
            if obj.calledID != user?.id {
                obj.calledID = user?.id
                obj.callback(user)
            }
        }
        if needsClean {
            changeObservers = changeObservers.filter { $0.observer != nil }
        }
    }

    private final class ChangedObserver {
        weak var observer: AnyObject?
        let callback: AccountChangedCallback
        var calledID: String?

        init(_ handler: @escaping AccountChangedCallback) {
            callback = handler
        }
    }
    private static var changeObservers = [ChangedObserver]()
}


public extension IAAccount {
    /// 是否是当前用户
    var isCurrent: Bool {
        return AccountManager.current === self
    }
}
