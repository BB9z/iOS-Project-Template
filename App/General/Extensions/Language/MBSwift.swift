/*
 MBSwift.swift
 
 Copyright © 2018, 2020-2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 
 Swift 语言扩展
 */

// Swift 对象与指针间的转换，对标 Objective-C 中的 __bridge 转换
// REF: https://stackoverflow.com/a/33310021/945906
// @MBDependency:1

// 允许方法名 __ 开头
// swiftlint:disable identifier_name

func __bridge<T: AnyObject>(obj: T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func __bridge<T: AnyObject>(ptr: UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func __bridge_retained<T: AnyObject>(obj: T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

func __bridge_transfer<T: AnyObject>(ptr: UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}

// swiftlint:enable identifier_name

/// 语言辅助工具
enum MBSwift {

    /// 强转类型非空值
    ///
    /// - Parameters:
    ///   - obj: 必须非空，类型与 type 相符，否则终止运行
    ///   - type: 转换类型
    /// - Returns: 转换后的非空值
    static func cast<T>(_ obj: Any?, as type: T.Type) -> T {
        guard let instance = obj as? T else {
            fatalError("Cast object is nil or type mismatched.")
        }
        return instance
    }

    /**
     类型名，会去除泛型部分

     可传入实例或类型本身
     */
    static func typeName(_ obj: Any) -> String {
        var str = (obj is Any.Type) ? String(describing: obj.self) : String(describing: type(of: obj))
        if str.hasSuffix(">"),
           let partStart = str.lastIndex(of: "<") {
            str.removeSubrange(partStart..<str.endIndex)
        }
        if str.contains(Character(".")) {
            if let lastPart = str.split(separator: ".").last {
                str = String(lastPart)
            }
        }
        #if DEBUG
        assert(!str.isEmpty
                && !str.contains(Character("."))
                && !str.contains(Character(":"))
                && !str.contains(Character("<"))
        )
        #endif
        return str
    }
}

/// 包装一个 Swift 值以便能在 Objective-C 环境中作为对象传递
@objc final class Box: NSObject {
    private var value: Any
    init(_ value: Any) {
        self.value = value
        super.init()
    }

    func value<T>(as type: T.Type) -> T {
        MBSwift.cast(value, as: type)
    }
}

/// 包装一个 Swift 值以便能在 Objective-C 环境中作为对象传递
@objc final class OptionalBox: NSObject {
    private var value: Any?
    init(_ value: Any?) {
        self.value = value
        super.init()
    }

    func value<T>(as type: T.Type) -> T? {
        value as? T
    }
}
