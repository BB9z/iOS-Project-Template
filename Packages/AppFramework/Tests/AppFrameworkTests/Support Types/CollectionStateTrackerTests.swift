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
        var result = tracker.deactivate(3)
        assertResult(result, [], [3])
        assertActived(tracker, at: 0, 3, 4)

        // At mid
        result = tracker.deactivate(1)
        assertResult(result, [], [1])
        assertActived(tracker, at: 3, 4)

        // At end
        result = tracker.deactivate(5)
        assertResult(result, [], [5])
        assertActived(tracker, at: 3)

        // Noop
        result = tracker.deactivate(5)
        assertResult(result, [], [])
        assertActived(tracker, at: 3)

        // Not exist
        result = tracker.deactivate(999)
        assertResult(result, [], [])
        assertActived(tracker, at: 3)
    }

    func testMultipleElements() {
        let tracker = CollectionStateTracker<Int>(elements: [1, 2, 3, 4, 5])

        assertResult(tracker.active([1, 4]), [1, 4], [])
        assertActived(tracker, at: 0, 3)

        // 有效、无效混合
        assertResult(tracker.deactivate([2, 4]), [], [4])
        assertActived(tracker, at: 0)

        assertResult(tracker.active([5, 6]), [5], [])
        assertActived(tracker, at: 0, 4)

        // 多个相同操作应等同一个
        assertResult(tracker.deactivate([1, 1]), [], [1])
        assertActived(tracker, at: 4)
        
        assertResult(tracker.active([3, 3]), [3], [])
        assertActived(tracker, at: 2, 4)

        // 乱序
        assertResult(tracker.active([4, 2, 1]), [1, 2, 4], [])
        assertActived(tracker, at: 0, 1, 2, 3, 4)

        assertResult(tracker.deactivate([5, 3, 1]), [], [1, 3, 5])
        assertActived(tracker, at: 1, 3)

        // 无变化
        assertResult(tracker.active([2, 4]), [], [])
        assertActived(tracker, at: 1, 3)

        assertResult(tracker.deactivate([3, 5]), [], [])
        assertActived(tracker, at: 1, 3)

        // 清空
        assertResult(tracker.deactivate([2, 4, 999]), [], [2, 4])
        XCTAssertEqual(Array(tracker.activedIndexs), [])
        XCTAssertEqual(tracker.activedElements, [])
    }

    func testActivedSetAndGetMethod() {
        let tracker = CollectionStateTracker<String>(elements: ["a", "b", "c"])

        assertResult(tracker.set(activedElements: ["a", "b"]), ["a", "b"], [])
        assertResult(tracker.set(activedElements: ["b", "c"]), ["c"], ["a"])

        XCTAssertFalse(tracker.isActived("not in"))
        XCTAssertFalse(tracker.isActived("a"))
        XCTAssertTrue(tracker.isActived("b"))
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

    func testSequence() {
        let elm1 = NSArray(object: "1")
        let elm2 = NSMutableArray(object: "2")
        let sut = CollectionStateTracker<NSArray>()
        _ = sut.update(elements: [elm1, elm2], keepActive: false)

        XCTAssertEqual(sut.count, 2)
        XCTAssertEqual(sut.underestimatedCount, 2)
        var idx = 0
        for element in sut {
            switch idx {
            case 0:
                XCTAssert(element === elm1)
            case 1:
                XCTAssert(element === elm2)
            default:
                fatalError()
            }
            idx += 1
        }
        XCTAssertEqual(idx, 2)

        _ = sut.update(elements: [[]], keepActive: false)
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut.underestimatedCount, 1)
    }
}

private extension CollectionStateTrackerTests {
    func assertResult<T>(
        _ result: CollectionStateTracker<T>.Result,
        _ activated: [T],
        _ deactivated: [T],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(result.activated, activated, file: file, line: line)
        XCTAssertEqual(result.deactivated, deactivated, file: file, line: line)
    }

    func assertActived<T>(
        _ tracker: CollectionStateTracker<T>,
        at activedIndexs: Int...,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let idxSet = IndexSet(activedIndexs)
        XCTAssertEqual(tracker.activedIndexs, idxSet, file: file, line: line)
        let activated = idxSet.map { tracker.elements[$0] }
        XCTAssertEqual(tracker.activedElements, activated, file: file, line: line)
    }
}
