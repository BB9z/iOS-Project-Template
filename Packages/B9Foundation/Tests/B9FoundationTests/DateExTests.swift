/*
 DateExTests.swift
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import B9Foundation
import XCTest

class DateExTests: XCTestCase {
    func testIsToday() {
        let now = Date.current
        let dayStart = Calendar.current.startOfDay(for: now)
        let dayEnd = Calendar.current.date(byAdding: DateComponents(day: 1), to: dayStart)
        XCTAssertTrue(dayStart.isToday)
        XCTAssert(dayEnd?.isToday == false)
    }

    func testIsSameNil() {
        XCTAssertTrue(Date.isSame(granularity: .day, nil, nil))

        XCTAssertFalse(Date.isSame(granularity: .day, .distantPast, nil))
        XCTAssertFalse(Date.isSame(granularity: .day, nil, .distantFuture))
    }

    func testIsSameDimension() {
        let date1 = Date(timeIntervalSince1970: 0)
        let date2 = Date(timeIntervalSince1970: 3000) // Add less than hour

        XCTAssertTrue(Date.isSame(granularity: .year, date1, date2))
        XCTAssertTrue(Date.isSame(granularity: .month, date1, date2))
        XCTAssertTrue(Date.isSame(granularity: .day, date1, date2))
        XCTAssertTrue(Date.isSame(granularity: .hour, date1, date2))
        XCTAssertFalse(Date.isSame(granularity: .minute, date1, date2))
        XCTAssertFalse(Date.isSame(granularity: .second, date1, date2))
    }
}
