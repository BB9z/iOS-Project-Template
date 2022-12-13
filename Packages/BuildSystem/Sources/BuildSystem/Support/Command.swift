/*
 Command.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

public extension CommandLine {
    /// 执行/脚本文件所在的路径
    static var url: URL {
        URL(
            fileURLWithPath: CommandLine.arguments[0],
            relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        )
    }

    /// 执行 Shell 命令的结果
    enum ShellResult {
        /// 执行失败
        case success(output: String)
        /// 执行成功
        case failure(status: Int, output: String)

        var status: Int {
            switch self {
            case .success:
                return 0
            case .failure(let status, _):
                return status
            }
        }

        var output: String {
            switch self {
            case .success(let output):
                return output
            case .failure(_, let output):
                return output
            }
        }
    }

    /// 执行 shell 脚本
    ///
    /// - Parameter shell: 第一位是命令，从 $PATH 中找
    /// - Returns: 执行结果
    static func run(_ shell: [String]) -> ShellResult {
        let cmd = Process()
        let output = Pipe()
        cmd.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        cmd.arguments = shell
        cmd.standardOutput = output
        cmd.standardError = output
        do {
            try cmd.run()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            var output = String(data: data, encoding: .utf8) ?? ""
            if output.last == "\n" {
                // Delete the new line added at the end by the file handler
                _ = output.removeLast()
            }
            // 在 Xcode 中作为脚本跑，Process 的等待必须在 readDataToEndOfFile 后面，
            // 否则会死锁，但单独跑就没事
            cmd.waitUntilExit()
            if cmd.terminationStatus == 0 {
                return .success(output: output)
            } else {
                return .failure(status: Int(cmd.terminationStatus), output: output)
            }
        } catch {
            return .failure(status: -1, output: error.localizedDescription)
        }
    }
}
