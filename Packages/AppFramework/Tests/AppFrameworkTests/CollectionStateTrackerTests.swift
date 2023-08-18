/*
 CollectionStateTrackerTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import AppFramework
import XCTest

final class CollectionStateTrackerTests: XCTestCase {
    func testActiveSingleElement() {
        let tracker = CollectionStateTracker<Int>(elements: [1, 2, 3, 4, 5, 5, 5])
        XCTAssertEqual(tracker.elements, [1, 2, 3, 4, 5])

        var result = tracker.active(3)
        assertResult(result, [3], [])
        assertActived(tracker, at: 2)

        // Noop
        result = tracker.active(3)
        assertResult(result, [], [])
        assertActived(tracker, at: 2)

        // No exist
        result = tracker.active(999)
        assertResult(result, [], [])
        assertActived(tracker, at: 2)

        // Begin
        result = tracker.active(1)
        assertResult(result, [1], [])
        assertActived(tracker, at: 0, 2)

        // End
        result = tracker.active(5)
        assertResult(result, [5], [])
        assertActived(tracker, at: 0, 2, 4)

        // Middle
        result = tracker.active(2)
        assertResult(result, [2], [])
        assertActived(tracker, at: 0, 1, 2, 4)
    }

    func testDeactiveSingleElement() {
        let tracker = CollectionStateTracker<Int>(elements: [1, 2, 3, 4, 5])
        _ = tracker.active([1, 3, 4, 5])

        // At begin
        var result = tracker.deactive(3)
        assertResult(result, [], [3])
        assertActived(tracker, at: 0, 3, 4)

        // At mid
        result = tracker.deactive(1)
        assertResult(result, [], [1])
        assertActived(tracker, at: 3, 4)

        // At end
        result = tracker.deactive(5)
        assertResult(result, [], [5])
        assertActived(tracker, at: 3)

        // Noop
        result = tracker.deactive(5)
        assertResult(result, [], [])
        assertActived(tracker, at: 3)

        // Not exist
        result = tracker.deactive(999)
        assertResult(result, [], [])
        assertActived(tracker, at: 3)
    }

    func testMultipleElements() {
        let tracker = CollectionStateTracker<Int>(elements: [1, 2, 3, 4, 5])

        assertResult(tracker.active([1, 4]), [1, 4], [])
        assertActived(tracker, at: 0, 3)

        // 有效、无效混合
        assertResult(tracker.deactive([2, 4]), [], [4])
        assertActived(tracker, at: 0)

        assertResult(tracker.active([5, 6]), [5], [])
        assertActived(tracker, at: 0, 4)

        // 多个相同操作应等同一个
        assertResult(tracker.deactive([1, 1]), [], [1])
        assertActived(tracker, at: 4)
        
        assertResult(tracker.active([3, 3]), [3], [])
        assertActived(tracker, at: 2, 4)

        // 乱序
        assertResult(tracker.active([4, 2, 1]), [1, 2, 4], [])
        assertActived(tracker, at: 0, 1, 2, 3, 4)

        assertResult(tracker.deactive([5, 3, 1]), [], [1, 3, 5])
        assertActived(tracker, at: 1, 3)

        // 无变化
        assertResult(tracker.active([2, 4]), [], [])
        assertActived(tracker, at: 1, 3)

        assertResult(tracker.deactive([3, 5]), [], [])
        assertActived(tracker, at: 1, 3)

        // 清空
        assertResult(tracker.deactive([2, 4, 999]), [], [2, 4])
        XCTAssertEqual(Array(tracker.activedIndexs), [])
        XCTAssertEqual(tracker.activedElements, [])
    }

    func testSetActiveMethod() {
        let tracker = CollectionStateTracker<String>(elements: ["a", "b", "c"])

        assertResult(tracker.set(activedElements: ["a", "b"]), ["a", "b"], [])
        assertResult(tracker.set(activedElements: ["b", "c"]), ["c"], ["a"])
    }

    func testUpdateElements() {
        let tracker = CollectionStateTracker<String>()

        // Not keep
        assertResult(tracker.update(elements: ["a", "b"], keepActive: false), [], [])
        assertResult(tracker.active("a"), ["a"], [])
        assertResult(tracker.update(elements: ["a", "b"], keepActive: false), [], ["a"])
        assertResult(tracker.active("b"), ["b"], [])
        assertResult(tracker.update(elements: ["a", "c"], keepActive: false), [], ["b"])

        // Keep
        assertResult(tracker.update(elements: ["a", "b"], keepActive: true), [], [])
        assertResult(tracker.active(["a", "b"]), ["a", "b"], [])
        assertResult(tracker.update(elements: ["a", "b"], keepActive: true), [], [])
        assertResult(tracker.update(elements: ["b"], keepActive: true), [], ["a"])
        assertResult(tracker.update(elements: ["b", "c"], keepActive: true), [], [])
    }

    private func assertResult<T>(
        _ result: CollectionStateTracker<T>.Result,
        _ actived: [T],
        _ deactived: [T],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(result.actived, actived, file: file, line: line)
        XCTAssertEqual(result.deactived, deactived, file: file, line: line)
    }

    private func assertActived<T>(
        _ tracker: CollectionStateTracker<T>,
        at activedIndexs: Int...,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let idxSet = IndexSet(activedIndexs)
        XCTAssertEqual(tracker.activedIndexs, idxSet, file: file, line: line)
        let actived = idxSet.map { tracker.elements[$0] }
        XCTAssertEqual(tracker.activedElements, actived, file: file, line: line)
    }
}
