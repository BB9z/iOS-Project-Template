/*
 IdentifierEquatable.swift

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */


/*
 实现备忘：
 标准库中的 Identifiable iOS 13+ 可用，用 uid 除了与标准库区分外，
 更多的是历史因素：id 在 Objective-C 中是关键字。
 */

/**
 Unique identifier 相同生成

 不考虑属性，只要 id 相同即认为相同
 */
public protocol IdentifierEquatable: Equatable {
    associatedtype ID: Hashable

    /// Unique identifier 标识符
    var uid: ID { get }
}

extension IdentifierEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uid == rhs.uid
    }
}

extension IdentifierEquatable where Self: NSObjectProtocol {

    /**
     具体对象重载 isEqual 方法辅助用

     例子
     ```
     class SomeEntity: NSObject, IdentifierEquatable {
         var uid: MBID = -1

         override func isEqual(_ object: Any?) -> Bool { isUIDEqual(object) }
         override var hash: Int { uid.hashValue }
     }
     ```
     */
    func isUIDEqual(_ object: Any?) -> Bool {
        if let obj = object as? Self {
            return uid == obj.uid
        }
        return false
    }
}
