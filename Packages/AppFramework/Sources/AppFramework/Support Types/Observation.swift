/*!
 Observation.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/// 注册的观察对象，被释放或者掉用 invalidate 方法后失效
public protocol MBObservation: AnyObject {
    func invalidate()
}

/**
 一种内部实现

 支持：重复传参判断，单一参数 callback
 */
fileprivate final class _AFObservation<Context>: MBObservation {
    /// 上次传参
    var lastContext: Context?

    var callback: ((Context) -> Void)?

    /// 参照对象，为空意味着观察失效
    weak var reference: AnyObject?

    /// 设置了外部参照对象时，用于保持自身
    var keepSelf: AnyObject?

    weak var parent: _AFObserverSet<Context>?

    func invalidate() {
        reference = nil
        lastContext = nil
        callback = nil
        parent?.remove(self)
    }
}

/**
 Observation 集合管理
 */
internal final class _AFObserverSet<Context> {
    /// callback 调用的队列，也是维护状态的队列
    let queue: DispatchQueue
    private var store = [Weak]()
    private(set) var lastContext: (Context?)?
    let contextComparator: (_ oldValue: Context?, _ newValue: Context) -> Bool

    /**
     - Parameters:
     - comparator: 对 context 进行比较，如果相同，通知事件不会重复发送；默认不去重
     */
    init(queue: DispatchQueue = .main, comparator: ((_ oldValue: Context?, _ newValue: Context) -> Bool)? = nil) {
        self.queue = queue
        self.contextComparator = comparator ?? { _, _ in false }
    }

    @discardableResult
    func add(initial: Bool = false, observer: AnyObject? = nil, callback: @escaping (Context) -> Void) -> MBObservation {
        let obj = _AFObservation<Context>()
        obj.parent = self
        obj.reference = observer ?? obj
        if observer != nil {
            obj.keepSelf = obj
        }
        obj.callback = callback
        queue.async(flags: .barrier) { [self] in
            store.append(Weak(object: obj))
            if initial, let context = lastContext as? Context {
                assert(obj.lastContext == nil)
                obj.lastContext = context
                callback(context)
            }
        }
        return obj
    }

    func remove(_ observer: AnyObject) {
        queue.async(flags: .barrier) { [self] in
            store.removeAll {
                $0.object?.reference === observer || $0.object == nil
            }
        }
    }

    func perform(context: Context) {
        queue.async(flags: .barrier) { [self] in
            lastContext = context

            var shouldClean = false
            for box in store {
                guard let obj = box.object,
                      obj.reference != nil else {
                    shouldClean = true
                    continue
                }
                if contextComparator(obj.lastContext, context) {
                    continue
                }
                obj.lastContext = context
                obj.callback?(context)
            }
            if shouldClean {
                store.removeAll { $0.object?.reference == nil }
            }
        }
    }

    internal func observerCountForTesting() -> Int {
        store.count
    }

    private struct Weak {
        weak var object: _AFObservation<Context>?
    }
}

