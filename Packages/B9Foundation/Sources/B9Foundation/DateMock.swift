/*
 DateMock
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

extension Date {
    /// Returns a date instance that represents the current date and time, at the moment of access.
    ///
    /// It can be overwritten during testing.
    /// ```
    /// @testable import B9Foundation
    /// Date.overwriteCurrent(...)
    /// ```
    public static var current: Date {
        injectedCurrent?() ?? Date()
    }

    private static var injectedCurrent: (() -> Date)?

    /// Overwrite `current` with the given closure, set `nil` to reset.
    internal static func overwriteCurrent(_ block: (() -> Date)?) {
        injectedCurrent = block
    }

    /// Overwrite `current` with the given date value
    internal static func overwriteCurrent(_ value: Date) {
        injectedCurrent = { value }
    }
}
