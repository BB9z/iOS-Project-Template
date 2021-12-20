/*
 ObjectPool.swift

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 弱引用存储 model 实例，用于保证相同 id 的对象有唯一实例，线程安全

 项目模版的 model 更新后刷新机制依赖 model 实例的唯一性
 */
final class ObjectPool<Key: Hashable, Value: AnyObject> {
    private var store = [Key: Weak]()
    private let lock = NSLock()

    init() {
    }

    /**
     只读或写线程安全

     但如果类似下列代码，不存在则创建保存这种，请用 `object(key: Key, creator: @autoclosure () -> Value)` 方法

     ```
     // 反例，下述方法不是线程安全的，相同 id 的 Obj 可以创建多个并返回
     fun someFunc(id: Key) -> Obj {
         if let old = pool[id] {
           return old
         } else {
           let new = Obj(id)
           pool[id] = new
           return new
         }
     }
     ```
     */
    subscript(index: Key) -> Value? {
        get {
            lock.lock()
            let value = store[index]
            lock.unlock()
            return value?.object
        }
        set {
            lock.lock()
            store[index] = Weak(object: newValue)
            lock.unlock()
        }
    }

    /**
     返回 key 对应的对象，如果未在对象池中不存在，则用 creator 创建，存储后返回
     */
    func object(key: Key, creator: @autoclosure () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        if let obj = store[key]?.object {
            return obj
        }
        let obj = creator()
        store[key] = Weak(object: obj)
        return obj
    }

    func removeAll() {
        lock.lock()
        store = [:]
        lock.unlock()
    }

    private struct Weak {
        weak var object: Value?
    }
}
