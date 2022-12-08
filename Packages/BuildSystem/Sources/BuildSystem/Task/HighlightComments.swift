/*
 HighlightComments.swift
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 搜寻代码中特定注释并输出

 比较：

 * Shell 脚本，确实不如 `find ... | egrep ...` 灵活高效，但不熟悉 shell 的话不好改；
 * SwiftLint 中也提供了 todo 提示，支持的格式比脚本里的还多，但只支持 swift 文件；
 * 但这里咱可以想怎么改，就怎么改……
 */
@available(macOS 13, *)
class HighlightComments {
    static func run(_ context: XCContext) throws {
        guard Configuration.isHighlightCommentsEnabled else { return }
        let findResult = CommandLine.run([
            "find",
            context.sourceRoot,
            // Exclude paths
            "(",
            "-not", "-path", "\(context.sourceRoot)/Frameworks/*",
            "-not", "-path", "\(context.sourceRoot)/Packages/BuildSystem/*",
            "-not", "-path", "\(context.sourceRoot)/Packages/Pulse/*",
            "-not", "-path", "\(context.sourceRoot)/Pods/*",
            ")",
            // Find all files of types
            "(",
            "-name", "*.swift",
            "-or", "-name", "*.h",
            "-or", "-name", "*.m",
            "-or", "-name", "*.mm",
            ")"
        ])
        if case .failure = findResult {
            Log.error(findResult.output)
            return
        }
        let files = findResult.output
            .split(separator: "\n")
            .map(String.init)
        try HighlightComments(files: files).run()
    }

    let files: [String]
    var regex = Configuration.highlightCommentsRegex

    init(files: [String]) {
        self.files = files
    }

    func run() throws {
        for file in files {
            let content = try String(contentsOfFile: file)
            let result = findMatch(in: content, file: file)
            for item in result {
                Log.xcWarning(message: item.text, file: item.file, line: item.line, col: item.col)
            }
        }
    }

    internal func findMatch(in content: String, file: String) -> [TextAndPosition] {
        var result = [TextAndPosition]()
        var lineIdx = 0
        let regex = self.regex
        content.enumerateLines { line, _ in
            lineIdx += 1
            guard let match = try? regex.firstMatch(in: line) else {
                return
            }
            let col = line.distance(from: line.startIndex, to: match.range.lowerBound) + 1
            let message = "\(match.1.uppercased()): \(match.2)"
            result.append(.init(file: file, line: lineIdx, col: col, text: message))
        }
        return result
    }
}

struct TextAndPosition: Equatable {
    let file: String
    let line: Int
    let col: Int
    let text: String
}
