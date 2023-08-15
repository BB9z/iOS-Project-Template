/*!
 Collection+AF.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

public extension Sequence where Iterator.Element: Hashable {
    /// 返回去重的序列
    func uniqued() -> [Iterator.Element] {
        var seen = [Iterator.Element: Bool]()
        return filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
