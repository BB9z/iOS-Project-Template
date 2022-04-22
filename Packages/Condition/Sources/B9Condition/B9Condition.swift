/*
 B9Condition.swift

 Copyright © 2022 BB9z.
 https://github.com/b9swift/Condition

 The MIT License
 https://opensource.org/licenses/MIT
 */

@_exported import B9Action
import Foundation

/**
 维护一组状态，当满足特定状态时执行相应的监听操作

 支持多线程，可以在任意线程设置状态；当状态满足后，监听将在指定的队列（未指定用 Condition 自身的队列）被触发。但通常情况，状态设置和监听操作建议都用主线程，因为有些极端情况无法做到完美：

 1. 虽然在监听操作执行前会再次检查状态是否满足，即触发时正常都是满足条件的。但可能状态这边刚检查完，又在其他线程被改了，导致操作执行时与预期状态不符；
 2. 在一个线程周期变化状态，在另外的线程触发监听，最坏情况是监听操作永远不会被执行（到监听队列检查时，状态又被改回了）

 监听操作的执行总是会延后于状态变更

 需要有强引用以保持实例，引用解除会立即释放并取消全部任务，但有一个例外：

 - 如果有在其他线程执行中的任务，会临时保持实例
 */
public final class Condition<T: SetAlgebra> {

    /// 创建 Condition 实例
    ///
    /// - Parameter queue: 队列，默认主线程
    public init(queue: DispatchQueue = .main) {
        self.queue = queue
    }

    /// 默认队列，监听若未特别设置队列，则在这个队列上执行
    public let queue: DispatchQueue

    /// 检查当前状态是否满足给定的标记
    public func meets(_ flags: T) -> Bool {
        self.flags.isSuperset(of: flags)
    }

    /// 开启状态标记
    /// - Parameter flags: 需要开启的状态
    public func set(on flags: T) {
        lock.lock()
        self.flags = self.flags.union(flags)
        flagsChange.set()
        lock.unlock()
    }

    /// 关掉状态标记
    /// - Parameter flags: 需要关闭的状态
    public func set(off flags: T) {
        lock.lock()
        self.flags.subtract(flags)
        flagsChange.set()
        lock.unlock()
    }

    /// 添加状态监听，当状态满足时执行操作
    ///
    /// - Parameters:
    ///   - flags: 需要满足的状态
    ///   - action: 状态满足时执行的操作
    ///   - queue: 操作执行的队列，可选
    ///   - autoRemove: 执行一次后是否自动移除监听，默认不自动移除
    /// - Returns: 可以用于取消监听的对象，监听被取消前 `Condition` 会持有该对象
    @discardableResult
    public func observe(_ flags: T, action: Action, queue: DispatchQueue? = nil, autoRemove: Bool = false) -> AnyObject {
        let observer = Observer(flags, action)
        observer.shouldAutoRemove = autoRemove
        observer.queue = queue
        lock.lock()
        observers.append(observer)
        lock.unlock()
        return observer
    }

    /// 移除给定监听
    ///
    /// - Parameter observer: 添加监听方法返回的对象
    public func remove(observer: AnyObject?) {
        guard let observer = observer else { return }
        lock.lock()
        defer { lock.unlock() }
        if let idx = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: idx)
        }
    }

    /// 等待状态满足后执行操作
    ///
    /// - Parameters:
    ///   - flags: 需要满足的状态
    ///   - action: 状态满足时执行的操作
    ///   - timeout: 超时，大于 0 时启用，超时操作会被丢弃
    public func wait(_ flags: T, action: Action, timeout: TimeInterval = 0) {
        let observer = Observer(flags, action)
        observer.shouldAutoRemove = true
        appendAndCheck(observer: observer)
        if timeout > 0 {
            queue.asyncAfter(deadline: .now() + timeout) { [weak self, weak observer] in
                guard let sf = self, let observer = observer else { return }
                sf.remove(observer: observer)
            }
        }
    }

    // MARK: -

    internal var flags = T()
    internal var observers = [Observer]()
    /// flags 写保护，observers 读写保护
    private let lock = NSLock()

    private lazy var flagsChange = DelayAction(Action({ [weak self] in
        self?.onFlagsChange()
    }, reference: nil), delay: 0, queue: queue)

    private func onFlagsChange() {
        lock.lock()
        let observersSnapshot = observers
        lock.unlock()
        if observersSnapshot.isEmpty { return }
        for observer in observersSnapshot {
            if meets(observer.flags) {
                if !observer.hasCalledWhenMeet {
                    if let otherQueue = observer.queue {
                        otherQueue.async {
                            // 需临时保持实例
                            if self.meets(observer.flags) {
                                self.execute(observer: observer)
                            }
                        }
                    } else {
                        execute(observer: observer)
                    }
                }
            } else {
                if observer.hasCalledWhenMeet {
                    observer.hasCalledWhenMeet = false
                }
            }
        }
    }

    internal final class Observer: CustomDebugStringConvertible {
        let flags: T
        let action: Action
        var shouldAutoRemove = false
        var hasCalledWhenMeet = false
        var queue: DispatchQueue?

        init(_ flags: T, _ action: Action) {
            self.flags = flags
            self.action = action
        }

        internal var debugDescription: String {
            let properties: [(String, Any?)] = [("flags", flags), ("queue", queue), ("shouldAutoRemove", shouldAutoRemove), ("action", action)]
            let propertyDiscription = properties.compactMap { key, value in
                if let value = value {
                    return "\(key) = \(value)"
                }
                return nil
            }.joined(separator: ", ")
            return "<Observer \(Unmanaged.passUnretained(self).toOpaque()): \(propertyDiscription)>"
        }
    }

    private func execute(observer: Observer) {
        assert(meets(observer.flags))
        observer.action.perform(with: nil)
        observer.hasCalledWhenMeet = true
        if observer.shouldAutoRemove {
            remove(observer: observer)
        }
    }

    private func appendAndCheck(observer: Observer) {
        lock.lock()
        observers.append(observer)
        lock.unlock()
        (observer.queue ?? queue).async { [weak self, weak observer] in
            guard let sf = self, let observer = observer else { return }
            if sf.meets(observer.flags) {
                sf.execute(observer: observer)
            }
        }
    }
}

extension Condition: CustomDebugStringConvertible {
    public var debugDescription: String {
        let properties: [(String, Any?)] = [("flags", flags), ("queue", queue), ("observers", observers)]
        let propertyDiscription = properties.compactMap { key, value in
            if let value = value {
                return "\(key) = \(value)"
            }
            return nil
        }.joined(separator: ", ")
        return "<Condition \(Unmanaged.passUnretained(self).toOpaque()): \(propertyDiscription)>"
    }
}
