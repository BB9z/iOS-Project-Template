/*!
 MBUser
 MBAppKit

 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
import B9Action
import B9MulticastDelegate

/**
 当前用户的管理模块
 */
enum AccountManager {
    static var current: (any MBUser)? {
        didSet {
            if oldValue === current { return }
            DispatchQueue.main.async {
                updateCurrent(oldValue: oldValue, newValue: current)
            }
        }
    }

    typealias AccountChangedCallback = (MBUser?) -> Void

    /**
     添加当前用户变化的监听

     - parameter observer: 非空对象。当 observer 释放时，监听会自行移除
     - parameter initial: 是否立即调用回调，否则只有当当前用户再次变化时才会触发回调
     - parameter callback: 仅当当前用户确实变化时（用户 ID 不同）才会调用，且同一个用户不会重复调用
     */
    static func addCurrentUserChangeObserver(_ observer: AnyObject, initial: Bool, callback: @escaping AccountChangedCallback) {
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
    static func removeCurrentUserChangeObserver(_ observer: AnyObject?) {
        DispatchQueue.main.async {
            changeObservers = changeObservers.filter { obj in
                obj.observer != nil && obj.observer !== observer
            }
        }
    }

    private static func updateCurrent(oldValue: MBUser?, newValue: MBUser?) {
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


protocol MBUser: AnyObject {
    var id: String { get }
    /// 成为当前用户时执行的操作，总是在主线程执行
    func onLogin()
    /// 用户登出时执行的操作，总是在主线程执行
    func onLogout()
}
extension MBUser {
    /// 是否是当前用户
    var isCurrent: Bool {
        return AccountManager.current === self
    }
}
