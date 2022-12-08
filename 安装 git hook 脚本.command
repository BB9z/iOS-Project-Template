#!/usr/bin/env swift

/// 安装项目文件整理脚本到 git hooks
/// Copyright © 2020 BB9z.
/// https://github.com/BB9z/iOS-Project-Template

import Cocoa

enum Script {
    /// 当前脚本目录
    static var currentDirectory: URL {
        if let scriptPath = CommandLine.arguments.first,
           !scriptPath.isEmpty {
            return URL(fileURLWithPath: scriptPath).deletingLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    /// 修改文件权限
    /// - Parameters:
    ///   - fileURL: 文件路径
    ///   - permissions: 8进制的权限代码，如 755 应写作 0o755 或 493（转为10进制后的值）
    static func chmod(_ fileURL: URL, permissions: Int) throws {
        precondition(fileURL.isFileURL, "\(fileURL) 不是文件路径")
        try FileManager.default.setAttributes([.posixPermissions: permissions], ofItemAtPath: fileURL.path)
    }

    /// 报错并终止脚本运行
    static func fatalError(_ message: String? = nil) -> Never {
        if let message = message {
            print(message)
        }
        exit(EXIT_FAILURE)
    }
}

//FileManager.default.changeCurrentDirectoryPath("/Users/BB9z/dev/lib/iOS Project Template")
print(Script.currentDirectory.path)

let hookDirectoryURL = Script.currentDirectory.appendingPathComponent(".git/hooks", isDirectory: true)
guard FileManager.default.fileExists(atPath: hookDirectoryURL.path) else {
    Script.fatalError("❌ \(hookDirectoryURL.path) 不存在")
}

let preCommitFileURL = hookDirectoryURL.appendingPathComponent("pre-commit", isDirectory: false)
if !FileManager.default.fileExists(atPath: preCommitFileURL.path) {
    print("🧭 pre-commit 文件不存在，创建")
    let scriptContent = """
    #!/bin/sh

    set -euo pipefail

    ./ci_scripts/sort_projects.sh

    """
    do {
        try scriptContent.write(to: preCommitFileURL, atomically: false, encoding: .utf8)
        try Script.chmod(preCommitFileURL, permissions: 0o755)
        print("🎉 hook 脚本设置成功")
        exit(EXIT_SUCCESS)
    } catch {
        Script.fatalError("❌ 创建 pre-commit 文件失败: \(error.localizedDescription)")
    }
}

print("🧭 pre-commit 已存在，检查文件内容")
guard let attributes = try? FileManager.default.attributesOfItem(atPath: preCommitFileURL.path),
      let fileSize = attributes[FileAttributeKey.size] as? UInt64 else {
    Script.fatalError("❌ 读取 pre-commit 属性失败")
}
if fileSize > 1000000 {
    print("⚠️ 取消处理：pre-commit 过大，文件异常？")
    exit(EXIT_FAILURE)
}
// 预防文件过大后，简单处理，内容作为字符串载入内存
guard var fileContent = try? String(contentsOf: preCommitFileURL, encoding: .utf8) else {
    Script.fatalError("❌ pre-commit 读取失败")
}
var fileLines = fileContent.components(separatedBy: .newlines)
for line in fileLines.reversed() {
    let text = line.trimmingCharacters(in: .whitespaces)
    if text.contains("./ci_scripts/sort_projects.sh"),
       !text.hasPrefix("#") {
        print("🎉 排序脚本已安装在 pre-commit 中")
        exit(EXIT_SUCCESS)
    }
}

print("🧭 附加排序脚本到文件末尾")
fileContent.append("\n./ci_scripts/sort_projects.sh\n")
do {
    try fileContent.write(to: preCommitFileURL, atomically: false, encoding: .utf8)
    try Script.chmod(preCommitFileURL, permissions: 0o755)
} catch {
    Script.fatalError("❌ pre-commit 修改失败: \(error.localizedDescription)")
}

print("🎉 hook 脚本设置成功")
