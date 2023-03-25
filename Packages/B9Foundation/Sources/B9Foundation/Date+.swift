/*
 Date+
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Foundation

public extension Date {
    /// Determine if the date is today according to the calendar.
    var isToday: Bool {
        Date.isSame(granularity: .day, self, .current)
    }

    /// Determine if the date is within tomorrow according to the calendar.
    var isTomorrow: Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .current)
        return Date.isSame(granularity: .day, self, tomorrow)
    }

    /// Determine if the date is within yesterday according to the calendar.
    var isYesterday: Bool {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .current)
        return Date.isSame(granularity: .day, self, yesterday)
    }

    /**
     Determine if two optional dates are equal in a specific calendar unit based on the current calendar.

     The comparison is made from largest to smallest calendar unit.
     Only when the specified calendar unit and above are all the same, it is considered the same.
     Therefore, there is no scenario of passing multiple granularities.

     eg: 2000-01-01 and 2000-05-01 are not equal in `.day`, including the granularities of hours, minutes, and seconds.

     - Parameters:
       - granularity: The dimension to be compared.

     - Returns: Returns `true` if both are `nil`.
     */
    static func isSame(granularity: Calendar.Component, _ date1: Date?, _ date2: Date?) -> Bool {
        if date1 == nil && date2 == nil {
            return true
        }
        guard let date1 = date1, let date2 = date2 else {
            return false
        }
        return Calendar.current.compare(date1, to: date2, toGranularity: granularity) == .orderedSame
    }
}
