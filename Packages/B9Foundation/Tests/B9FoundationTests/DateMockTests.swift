/*
 DateMockTests.swift
 B9Foundation

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import B9Foundation
import Foundation
import XCTest

// swiftlint:disable force_unwrapping

class DateMockTests: XCTestCase {
    func testCurrent() {
        let trueNow = Date.current
        var count: TimeInterval = 0
        Date.overwriteCurrent {
            count += 1
            return Date(timeIntervalSinceReferenceDate: count)
        }

        XCTAssertEqual(Date.current.description, "2001-01-01 00:00:01 +0000")
        XCTAssertEqual(Date.current.description, "2001-01-01 00:00:02 +0000")
        XCTAssertEqual(Date.current.description, "2001-01-01 00:00:03 +0000")

        Date.overwriteCurrent(Date(timeIntervalSince1970: 0))
        XCTAssertEqual(Date.current.description, "1970-01-01 00:00:00 +0000")

        Date.overwriteCurrent(nil)
        XCTAssertEqual(trueNow.timeIntervalSinceNow, 0, accuracy: 0.1)
        XCTAssertEqual(Date.current.timeIntervalSinceNow, 0, accuracy: 0.1)
    }

    func testIsTodayTomorrowOrYesterday() {
        let calendar = Calendar.current
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let trueTime = Date()
        let trueDayStart = calendar.startOfDay(for: trueTime)
        let trueDayBefore = trueDayStart.addingTimeInterval(-0.1)
        let trueDayNext = calendar.date(byAdding: DateComponents(day: 1), to: trueDayStart)!
        let trueDayEnd = trueDayNext.addingTimeInterval(-0.1)
        XCTAssertFalse(trueDayBefore.isToday)
        XCTAssertTrue(trueDayStart.isToday)
        XCTAssertTrue(trueTime.isToday)
        XCTAssertTrue(trueDayEnd.isToday)
        XCTAssertFalse(trueDayNext.isToday)

        XCTAssertFalse(trueDayBefore.isTomorrow)
        XCTAssertFalse(trueDayStart.isTomorrow)
        XCTAssertFalse(trueTime.isTomorrow)
        XCTAssertFalse(trueDayEnd.isTomorrow)
        XCTAssertTrue(trueDayNext.isTomorrow)

        XCTAssertTrue(trueDayBefore.isYesterday)
        XCTAssertFalse(trueDayStart.isYesterday)
        XCTAssertFalse(trueTime.isYesterday)
        XCTAssertFalse(trueDayEnd.isYesterday)
        XCTAssertFalse(trueDayNext.isYesterday)

        let fakeTime = format.date(from: "2020-02-20 01:00:00")!
        let fakeDayStart = calendar.startOfDay(for: fakeTime)
        let fakeDayBefore = fakeDayStart.addingTimeInterval(-0.1)
        let fakeDayNext = calendar.date(byAdding: DateComponents(day: 1), to: fakeDayStart)!
        let fakeDayEnd = fakeDayNext.addingTimeInterval(-0.1)

        XCTAssertFalse(fakeTime.isToday)
        Date.overwriteCurrent(fakeTime)
        XCTAssertFalse(fakeDayBefore.isToday)
        XCTAssertTrue(fakeDayStart.isToday)
        XCTAssertTrue(fakeTime.isToday)
        XCTAssertTrue(fakeDayEnd.isToday)
        XCTAssertFalse(fakeDayNext.isToday)

        XCTAssertFalse(fakeDayBefore.isTomorrow)
        XCTAssertFalse(fakeDayStart.isTomorrow)
        XCTAssertFalse(fakeTime.isTomorrow)
        XCTAssertFalse(fakeDayEnd.isTomorrow)
        XCTAssertTrue(fakeDayNext.isTomorrow)

        XCTAssertTrue(fakeDayBefore.isYesterday)
        XCTAssertFalse(fakeDayStart.isYesterday)
        XCTAssertFalse(fakeTime.isYesterday)
        XCTAssertFalse(fakeDayEnd.isYesterday)
        XCTAssertFalse(fakeDayNext.isYesterday)

        Date.overwriteCurrent(nil)
    }
}
