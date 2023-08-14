/*!
 MBAssert
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/// 框架提供的断言方法，允许定制失败时的处理
public func MBAssert(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String = "assertion failure.", file: StaticString = #file, line: UInt = #line) {
    if condition() {
        return
    }
    (_assertHandler ?? _defaultHandler)(message(), file, line)
}

/// 自定义断言失败的处理，默认 NSLog
public func MBAssertSetHandler(_ handler: ((_ message: String, _ file: StaticString, _ line: UInt) -> Void)?) {
    _assertHandler = handler
}

private var _assertHandler: ((_ message: String, _ file: StaticString, _ line: UInt) -> Void)?
private func _defaultHandler(_ message: String, _ file: StaticString, _ line: UInt) {
    let filename = (file.description as NSString).lastPathComponent
    NSLog("%@", "\(filename):\(line):💥 \(message)")
}
