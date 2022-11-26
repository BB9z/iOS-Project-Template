/*
 Log.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

internal enum Log {

    static func info(_ string: CustomStringConvertible) {
        print(string.description)
    }

    static func warning(_ string: CustomStringConvertible) {
        print("⚠️ \(string)")
    }

    static func error(_ string: CustomStringConvertible) {
        print("❌ \(string)")
    }

    /// 在 Xcode 中输出警告
    static func xcWarning(message: String, file: CustomStringConvertible = #filePath, line: Int = #line, col: Int = #column) {
        print("\(file):\(line):\(col): warning: \(message)")
        guard Configuration.limitWarningCount > 0 else { return }
        tooManyWarningCounter += 1
        if tooManyWarningCounter >= Configuration.limitWarningCount {
            xcError(message: "警告太多了，处理一下再继续吧")
            abort()
        }
    }
    private static var tooManyWarningCounter = 0

    /// 在 Xcode 中输出错误
    static func xcError(message: String, file: CustomStringConvertible = #filePath, line: Int = #line, col: Int = #column) {
        print("\(file):\(line):\(col): error: \(message)")
    }
}
