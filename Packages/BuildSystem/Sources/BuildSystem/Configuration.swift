/*
 Configuration.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation
import RegexBuilder  // Xcode 14.1+

/**
 运行脚本的配置

 🔰 按需修改
 */
enum Configuration {
    /// 脚本运行爆出的警告过多则报错
    /// 设为 0 禁用
    static let limitWarningCount: Int = 10

    /// Info.plist 的相对路径
    static let infoPlistPath = "App/Info.plist"

    /// 开关：编译次数计数与更新
    static let isBuildCountEnabled = true

    /// 仅在打包（Archive）时更新版本号
    static let buildCountOnlyUpdateWhenArchive = true

    /// 开关：搜寻代码中特定注释并输出
    static let isHighlightCommentsEnabled = true

    /// 特定注释的正则
    static let highlightCommentsRegex = Regex {
        "//"
        ZeroOrMore(.whitespace)
        Capture {
            ChoiceOf {
                "todo"
                "fixme"
            }
        }
        ":"
        ZeroOrMore(.whitespace)
        Capture {
            OneOrMore(.any)
        }
        Anchor.endOfLine
    }.ignoresCase()
}
