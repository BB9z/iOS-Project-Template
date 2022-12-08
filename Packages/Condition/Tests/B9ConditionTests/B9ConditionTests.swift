@testable import B9Condition
import XCTest

// swiftlint:disable identifier_name

enum EnumFlag {
case a, b, c, d
}

struct OptionFlag: OptionSet {
    let rawValue: Int

    static let a = OptionFlag(rawValue: 1 << 0)
    static let b = OptionFlag(rawValue: 1 << 1)
    static let c = OptionFlag(rawValue: 1 << 2)
    static let d = OptionFlag(rawValue: 1 << 3)
}

final class B9ConditionTests: XCTestCase {

    func testBasicSetAndMeets() {
        let enumCondition = Condition<Set<EnumFlag>>()
        XCTAssertFalse(enumCondition.meets([.a]))
        enumCondition.set(on: [.a])
        XCTAssertTrue(enumCondition.meets([.a]))
        enumCondition.set(on: [.b, .c])
        XCTAssertTrue(enumCondition.meets([.a, .b, .c]))
        XCTAssertFalse(enumCondition.meets([.a, .b, .c, .d]))
        enumCondition.set(off: [.a, .b])
        XCTAssertTrue(enumCondition.meets([.c]))
        XCTAssertFalse(enumCondition.meets([.a]))

        let optionCondition = Condition<OptionFlag>()
        XCTAssertFalse(optionCondition.meets([.a]))
        optionCondition.set(on: .a)
        XCTAssertTrue(optionCondition.meets([.a]))
        optionCondition.set(on: [.b, .c])
        XCTAssertTrue(optionCondition.meets([.a, .b, .c]))
        XCTAssertFalse(optionCondition.meets([.a, .b, .c, .d]))
        optionCondition.set(off: [.a, .b])
        XCTAssertTrue(optionCondition.meets(.c))
        XCTAssertFalse(optionCondition.meets(.a))
    }

    func testHasCalledWhenMeet() {
        let condition = Condition<Set<EnumFlag>>()
        let observerQueue = DispatchQueue(label: "Observer", qos: .userInteractive)
        var counter = 0
        condition.observe([.a], action: Action {
            counter += 1
            if counter == 1 {
                print("observer 1st")
            } else if counter == 2 {
                print("observer 2nd")
            } else {
                fatalError("Should not happen")
            }
        }, queue: observerQueue, autoRemove: false)
        after(0.1) {
            print("1. set on a")
            condition.set(on: [.a])
        }
        after(0.2) {
            print("2. set on b")
            condition.set(on: [.b])
        }
        after(0.21) {
            print("2. set off b")
            condition.set(off: [.b])
        }
        after(0.3) {
            print("3. set off a")
            condition.set(off: [.a])
        }
        after(0.4) {
            print("4. set on a")
            condition.set(on: [.a])
        }
        let testEnd = XCTestExpectation()
        after(0.5) {
            print("\(#function) end")
            testEnd.fulfill()
        }
        wait(for: [testEnd], timeout: 1)
    }

    func testWaitBeforeMeet() {
        let condition = Condition<OptionFlag>()
        let testEnd = XCTestExpectation()
        condition.wait(.a, action: Action {
            testEnd.fulfill()
        })
        after(0) {
            condition.set(on: .a)
        }
        XCTAssertEqual(condition.observers.count, 1)
        wait(for: [testEnd], timeout: 1)
        XCTAssertEqual(condition.observers.count, 0)
    }

    func testWaitAfterMeet() {
        let condition = Condition<OptionFlag>()
        let testEnd = XCTestExpectation()
        condition.set(on: .a)
        condition.wait(.a, action: Action {
            testEnd.fulfill()
        })
        wait(for: [testEnd], timeout: 1)
        XCTAssertEqual(condition.observers.count, 0)
    }

    func testWaitDelayAfterMeet() {
        let condition = Condition<OptionFlag>()
        let testEnd = XCTestExpectation()
        condition.set(on: .a)
        after(0.1) {
            condition.wait(.a, action: Action {
                testEnd.fulfill()
            })
        }
        wait(for: [testEnd], timeout: 1)
        XCTAssertEqual(condition.observers.count, 0)
    }

    func testWaitTimeout() {
        let condition = Condition<OptionFlag>()
        condition.wait(.a, action: Action {
            fatalError("Never")
        }, timeout: 0.1)
        let testEnd = XCTestExpectation()
        after(0.2) {
            testEnd.fulfill()
        }
        wait(for: [testEnd], timeout: 1)
        XCTAssertEqual(condition.observers.count, 0)
    }

    func testAddAndRemoveObserver() {
        let condition = Condition<OptionFlag>()
        var isCalled = false
        weak var observer = condition.observe(.a, action: Action {
            guard !isCalled else {
                fatalError()
            }
            isCalled = true
        })
        func refill() {
            condition.set(off: .a)
            after(0) {
                condition.set(on: .a)
            }
        }

        condition.set(on: .a)
        XCTAssertFalse(isCalled, "Should called after delay")
        after(0) {
            XCTAssertTrue(isCalled)

            // Reset
            isCalled = false
            refill()
        }
        after(0.1) {
            XCTAssertTrue(isCalled, "Should called after reset")

            XCTAssertNotNil(observer, "Observer is retained by condition")
            condition.remove(observer: observer)
            XCTAssertNil(observer, "After remove, observer should autoreleased")

            // Remove nil has no effect
            condition.remove(observer: nil)

            // Then should not called
            refill()
        }

        let testEnd = XCTestExpectation()
        after(0.2) {
            testEnd.fulfill()
        }
        wait(for: [testEnd], timeout: 1)
    }

    func testLowPriorityObservingMayNeverCalled() {
        let observerQueue = DispatchQueue(label: "LowPriority", qos: .background)
        var observerCalledCounter = 0
        let condition = Condition<OptionFlag>()
        condition.observe(.a, action: Action({
            // 不太好造一个完全能避免执行的场景，调用几率小于一定程度即可
            observerCalledCounter += 1
            debugPrint("LowPriority called")
        }, reference: nil), queue: observerQueue)
        for _ in 0..<100 {
            OperationQueue.main.addOperation {
                condition.set(on: .a)
                self.after(0) {
                    condition.set(off: .a)
                }
            }
        }
        let testEnd = XCTestExpectation()
        OperationQueue.main.addOperation {
            testEnd.fulfill()
        }
        wait(for: [testEnd], timeout: 10)
        debugPrint("Called", observerCalledCounter)
        XCTAssert(observerCalledCounter < 20)
    }

    func testDebugDescription() {
        let condition = Condition<Set<EnumFlag>>()
        condition.set(on: [.a, .b, .c])
        condition.wait([.a], action: Action {}, timeout: 1)
        condition.observe([.b, .d], action: Action {})
        debugPrint(condition)
    }

    func testReleaseWithoutTimeout() {
        strongReference = Condition<OptionFlag>()
        strongReference.wait(.a, action: Action({
            fatalError("Should not executed")
        }, reference: nil), timeout: 0)
        strongReference.set(on: [.a])
        strongReference = nil
        let testEnd = XCTestExpectation()
        after(0.1) {
            testEnd.fulfill()
        }
        wait(for: [testEnd], timeout: 2)
    }

    func testReleaseWithTimeout() {
        strongReference = Condition<OptionFlag>()
        strongReference.wait(.a, action: Action({
            fatalError("Should not executed")
        }, reference: nil), timeout: 1)
        after(0.1) {
            self.strongReference.set(on: [.a])
            self.strongReference = nil
        }
        let testEnd = XCTestExpectation()
        after(0.2) {
            testEnd.fulfill()
        }
        wait(for: [testEnd], timeout: 2)
    }

    var strongReference: Condition<OptionFlag>!

    private func after(_ second: TimeInterval, do work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + second, execute: work)
    }
}
