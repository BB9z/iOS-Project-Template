/*
 BuildSystem
 Script

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

/**
 自定义的构建过程

 🔰 按需修改。目前提供的功能是高亮特殊注释，构建数量计数并更新
 */
func main() {
    let context = XCContext()

    let startTime = CFAbsoluteTimeGetCurrent()
    defer {
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        let durationMessage = "执行耗时：\(String(format: "%.2f", duration))s"
        if duration > 0.2 {
            Log.warning(durationMessage)
        } else {
            Log.info(durationMessage)
        }
    }
    Log.info("Current Directory: \(context.sourceRoot)")
    do {
        try BuildCount.run(context)
        try HighlightComments.run(context)
    } catch {
        Log.error(error.localizedDescription)
    }
}

main()
