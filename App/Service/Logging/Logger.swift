//
//  Logger.swift
//  App
//

#if canImport(Logging)
// https://github.com/apple/swift-log
import Logging

/// Logger 单例
func AppLog() -> Logger {  // swiftlint:disable:this identifier_name
    AppLogHandler.sharedLogger
}

private struct AppLogHandler: LogHandler {
    fileprivate static let sharedLogger: Logger = {
        #if DEBUG
        LoggingSystem.bootstrap { _ in AppLogHandler() }
        #else
        // 简单处理，生产环境完全禁用 log
        LoggingSystem.bootstrap { _ in SwiftLogNoOpLogHandler() }
        #endif
        return Logger(label: "App")
    }()

    var metadata: Logger.Metadata = [:]

    var logLevel = Logger.Level.info

    // swiftlint:disable:next function_parameter_count
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        // 🔰 按需调整实现
        switch level {
        case .error:
            NSLog(String(describing: message))
        case .critical:
            NSLog(String(describing: message))
            ThrowExceptionToPause()
        default:
            print("\(timestamp()): [\(level)] \(message)")
        }
    }

    subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }

    private func timestamp() -> String {
        var buffer = [Int8](repeating: 0, count: 127)
        var timestamp = time(nil)
        let localTime = localtime(&timestamp)
        strftime(&buffer, buffer.count, "%H:%M:%S", localTime)
        return buffer.withUnsafeBufferPointer {
            $0.withMemoryRebound(to: CChar.self) {
                String(cString: $0.baseAddress!)
            }
        }
    }
}

#endif
