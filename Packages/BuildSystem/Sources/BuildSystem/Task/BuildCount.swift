/*
 BuildCount.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 编译次数计数与更新

 每次 build 时会更新一个记录文件，区分每个人、每个分支。
 默认打包时会更新 Info.plist 中的版本号（Build version）。

 比较：

 - 如果用 agvtool，需要写在 CI/CD 里，不能在 Build Phases 中通过脚本更新，
   因为 agvtool 会修改项目文件，导致编译中途被取消
 */
@available(macOS 13, *)
class BuildCount {
    static func run(_ context: XCContext) throws {
        guard Configuration.isBuildCountEnabled else { return }
        try BuildCount().run(context: context)
    }

    /// 编译次数记录文件的相对路径
    let recordFilePath = "ci_scripts/BuildCountRecord.plist"

    func run(context: XCContext) throws {
        let recordURL = context.resolving(relativePath: recordFilePath)
        var records = try BuildRecords(file: recordURL)
        guard let version = records.version() else {
            throw GError.message("编译次数记录文件没有版本")
        }
        guard version == 1 else {
            throw GError.message("编译次数记录文件是不支持的版本")
        }
        guard let username = context.user else {
            throw GError.message("获取不到环境变量中的用户名")
        }
        let branch = branchName()
        let count = records.increase(user: username, branch: branch)
        try records.write(to: recordURL)
        Log.info("更新编译次数记录：\(username)@\(branch) = \(count).")

        if context.isDebugBuild {
            Log.info("Debug Build，跳过版本号设置")
            return
        }
        if Configuration.buildCountOnlyUpdateWhenArchive {
            guard context.action == "install" else {
                Log.info("不是在打包，跳过版本号设置")
                return
            }
        }
        let infoPlist = context.resolving(relativePath: Configuration.infoPlistPath)
        updateVersion(records.totalCount(), infoPlist: infoPlist)
    }

    private func updateVersion(_ newVersion: Int, infoPlist: URL) {
        Log.warning("应用版本更新为: \(newVersion).")
        guard let infos = NSDictionary(contentsOf: infoPlist) else {
            Log.error("不能读取 Info.plist，路径可能需要更新，使用的路径: \(infoPlist.path).")
            return
        }
        infos.setValue(newVersion, forKey: "CFBundleVersion")
        do {
            try infos.write(to: infoPlist)
        } catch {
            Log.error("Info.plist 写入失败: \(error.localizedDescription)")
        }
    }

    private func branchName() -> String {
        let result = CommandLine.run(["git", "branch", "--show-current"])
        if case .failure(_, let output) = result {
            Log.warning("Unable get branch name: \(output)")
            return "default"
        }
        return result.output
    }
}

struct BuildRecords {
    private var raw: [String: Any]

    init(file: URL) throws {
        guard FileManager.default.isReadableFile(atPath: file.path) else {
            raw = Self.defaultRaw()
            return
        }
        guard let input = InputStream(url: file) else {
            throw GError.message("Unable create InputStream at \(file).")
        }
        input.open()
        defer { input.close() }
        do {
            raw = try PropertyListSerialization.propertyList(with: input, format: nil) as? [String: Any] ?? Self.defaultRaw()
        } catch {
            throw GError.message("Unable decode plist: \(error.localizedDescription)")
        }
    }

    func version() -> Int? {
        raw["Version"] as? Int
    }

    mutating func increase(user: String, branch: String) -> Int {
        var userItems = raw["UserBuildRecords"] as? [String: [String: Int]] ?? [:]
        var userItem = userItems[user, default: [:]]
        let branchCount = userItem[branch, default: 0]
        userItem[branch] = branchCount + 1
        userItems[user] = userItem
        raw["UserBuildRecords"] = userItems
        return branchCount + 1
    }

    func totalCount() -> Int {
        let userItems = raw["UserBuildRecords"] as? [String: [String: Int]] ?? [:]
        var count = 0
        for userItem in userItems.values {
            for bCount in userItem.values {
                count += bCount
            }
        }
        return count
    }

    func write(to file: URL) throws {
        guard let output = OutputStream(url: file, append: false) else {
            throw GError.message("Unable create OutputStream at \(file).")
        }
        output.open()
        defer { output.close() }
        var error: NSError?
        PropertyListSerialization.writePropertyList(raw, to: output, format: .xml, options: 0, error: &error)
        if let error = error {
            throw GError.message("Unable write plist: \(error.localizedDescription)")
        }
    }

    static func defaultRaw() -> [String: Any] {
        [
            "UserBuildRecords": [],
            "Version": 1,
        ]
    }
}
