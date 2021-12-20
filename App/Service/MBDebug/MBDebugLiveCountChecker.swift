/*
 MBDebugLiveCountChecker
 MBDebug

 Copyright © 2021 BB9z.

 The MIT License
 https://opensource.org/licenses/MIT
 */

// swiftlint:disable identifier_name

/**
 添加对象到活动对象监控中，当相同类型的对象超出限制时报警

 线程安全，应避免重复添加同一个实例，仅在 DEBUG 模式起效；
 可以在任何合理的时机调用，不只限于常规的 init 或生命周期方法
 */
public func LiveCount(add obj: AnyObject, limit: Int) {
    #if DEBUG
    MBDebugLiveCountChecker.shared.add(obj, limit: limit)
    #endif
}

/**
 从活动对象监控中移除

 无需在释放（deinit）时调用，线程安全
 */
public func LiveCount(remove obj: AnyObject) {
    #if DEBUG
    MBDebugLiveCountChecker.shared.remove(obj)
    #endif
}

/**
 检查类型的数量不超过限定值
 */
public func LiveCount(check type: AnyClass, limit: Int, delay: TimeInterval = -1) {
    #if DEBUG
    func check() {
        let count = MBDebugLiveCountChecker.shared.count(for: type)
        if count > limit {
            AppLog().critical("\(type) 活动对象数量 \(count) 超出预期")
        }
    }
    if delay >= 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            check()
        }
    } else {
        check()
    }
    #endif
}

/**
 使用、实现极简的内存泄漏监测预防

 受 https://github.com/krzysztofzablocki/LifetimeTracker 启发，更简单但更好用
 */
final class MBDebugLiveCountChecker {
    static let shared = MBDebugLiveCountChecker()

    private lazy var lock = NSLock()
    private lazy var store = [String: [Weak]]()

    func add(_ obj: AnyObject, limit: Int) {
        let aKey = key(obj)
        lock.lock()
        defer { lock.unlock() }

        var lives = store[aKey] ?? []
        lives.removeAll(where: { $0.object == nil })
        lives.append(Weak(object: obj))
        if limit > 0, lives.count > limit {
            AppLog().critical("活动对象数量异常 \(obj)")
        }
        store[aKey] = lives
    }

    func remove(_ obj: AnyObject) {
        let aKey = key(obj)
        lock.lock()
        defer { lock.unlock() }

        var lives = store[aKey] ?? []
        guard let idx = lives.firstIndex(where: { $0.object === obj || $0.object == nil }) else {
            // deinit 中 remove，走到这里时可能已经被释放了
            fatalError("Instance has not been add.")
        }
        lives.remove(at: idx)
        store[aKey] = lives
    }

    /// 获得指定类型的活动对象数量
    func count(for type: AnyClass) -> Int {
        let aKey = key(type)
        lock.lock()
        let lives = store[aKey] ?? []
        lock.unlock()
        return lives.reduce(0) { count, weak in
            return weak.object == nil ? count : count + 1
        }
    }

    private func key(_ obj: AnyObject) -> String {
        MBSwift.typeName(obj)
    }

    private struct Weak {
        weak var object: AnyObject?
    }
}
