/*
 AppError
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 应用程序通用错误
 General application errors.

 我们如何定义错误应该遵循我们如何处理它们的方式。
 How we define errors should follow how we handle them.

 我们如何处理错误？通常有以下几种方式：
 How do we handle errors? There are usually several ways:

 1. 记录日志或者忽略它们。这种方式并不好，但是很常见。
    Log or ignore them. This is not good, but it is common.
 2. 将错误消息显示给用户。
    Display error messages to the user.
 3. 记录为日志收集系统中的异常，以供以后分析和故障排除。
    Record as exceptions in the log collection system for later analysis and troubleshooting.
 4. 仅在少数情况下，我们基于特定错误进行特殊处理。
    Only in a few cases, we handle them specifically based on specific errors.

 因此，在大多数情况下，我们不关心具体的错误是什么。对于大多数情况，一条消息就足够了。
 Therefore, in most cases, we don't care what the specific error is. For most cases, one message is enough.
 */
public enum AppError: LocalizedError {

    /// 包含一条信息的错误
    case message(_ message: String)

    public var errorDescription: String? {
        switch self {
        case let .message(text):
            return text
        }
    }

    /**
     判断错误是否是取消操作导致的

     目前支持的种类有：

     - ``Swift.CancellationError``
     - ``URLError.cancelled``
     */
    public static func isCancel(_ err: Error?) -> Bool {
        if err is CancellationError {
            return true
        }
        if let urlError = err as? URLError {
            return urlError.code == .cancelled
        }
        return false
    }
}
