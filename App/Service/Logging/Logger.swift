//
//  Logger.swift
//  App
//

#if canImport(Logging)
// https://github.com/apple/swift-log
import Logging

import B9Debug

/// Logger 单例
func AppLog() -> Logger {  // swiftlint:disable:this identifier_name
    AppLogHandler.shared
}

private struct AppLogHandler: LogHandler {
    fileprivate static let shared: Logger = {
        LoggingSystem.bootstrap { _ in AppLogHandler() }
        return Logger(label: "App")
    }()

    var metadata: Logger.Metadata = [:]

    #if DEBUG
    var logLevel = Logger.Level.debug
    #else
    var logLevel = Logger.Level.error
    #endif

    // swiftlint:disable:next function_parameter_count
    func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        // 🔰 按需调整实现
        #if DEBUG
        switch level {
        case .debug, .trace:
            print("\(timestamp()): 🔹 \(message)")
        case .info:
            print("\(timestamp()): \(message)")
        case .notice, .warning:
            print("\(timestamp()): ⚠️ \(message)")
        case .error:
            NSLog("❌ %@", message.description)
        case .critical:
            NSLog("❌ %@", message.description)
            ThrowExceptionToPause()
        }
        #else
        switch level {
        case .error:
            NSLog("%@", message.description)
        case .critical:
            NSLog("%@", message.description)
        default:
            break
        }
        #endif
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
        nowDateFormatter.string(from: Date())
    }

    private let nowDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter
    }()
}

#endif
