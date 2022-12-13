/*
 XCContext.swift
 BuildSystem

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 对 Xcode 相关环境变量的读取进行的封装
 */
@available(macOS 13, *)
internal class XCContext {
    static let shared = XCContext()

    private let environment: [String: String]

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.environment = environment
    }

    lazy var isDebugBuild = configuration.lowercased().contains("debug")

    var action: String? {
        environment["ACTION"]
    }

    lazy var configuration: String = {
        environment["CONFIGURATION"] ?? {
            Log.warning("$CONFIGURATION not set, treat as Debug")
            return "Debug"
        }()
    }()

    lazy var sourceRoot: String = {
        if let result = environment["SRCROOT"] {
            return result
        }
        Log.warning("$SRCROOT not set, try to locate relative to the current directory")
        let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        if path.pathComponents.suffix(3).prefix(2) == ["Build", "Products"] {
            return path.deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .path
        }
        return path.path
    }()

    var user: String? {
        environment["USER"]
    }

    /// 获取相对路径的完整 URL，相对于项目根目录
    func resolving(relativePath: String) -> URL {
        URL(fileURLWithPath: sourceRoot).appendingPathComponent(relativePath)
    }
}
