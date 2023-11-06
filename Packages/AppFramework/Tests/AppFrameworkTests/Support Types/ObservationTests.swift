/*
 ObservationTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import AppFramework
import XCTest

class AFObserverSetTests: XCTestCase {
    let timeout: TimeInterval = 0.01

    func testNormal() {
        let exp1 = expectation(description: "1st")
        let exp2 = expectation(description: "2nd")
        let exp3 = expectation(description: "3rd").inverted()
        var exps = [ exp1, exp2, exp3 ]
        var values = [String]()

        let observerSet = _AFObserverSet<String>()
        let observation = observerSet.add {
            values.append($0)
            exps.removeFirst().fulfill()
        }
        
        observerSet.perform(context: "first")
        XCTAssertEqual(values, [])
        wait(for: [exp1], timeout: timeout)
        XCTAssertEqual(values, ["first"])

        observerSet.perform(context: "second")
        wait(for: [exp2], timeout: timeout)
        XCTAssertEqual(values, ["first", "second"])

        observation.invalidate()
        observerSet.perform(context: "third")
        wait(for: [exp3], timeout: timeout)
        XCTAssertEqual(values, ["first", "second"])
    }

    func testInvalidWithRefrenceRelease() {
        let exp1 = expectation(description: "1st")
        let exp2 = expectation(description: "2nd").inverted()
        var exps = [ exp1, exp2 ]
        var values = [String]()

        let observerSet = _AFObserverSet<String>()
        var observation: MBObservation!
        autoreleasepool {
            let reference = NSObject()
            observation = observerSet.add(observer: reference) {
                values.append($0)
                exps.removeFirst().fulfill()
            }

            observerSet.perform(context: "first")
            wait(for: [exp1], timeout: timeout)
            XCTAssertEqual(values, ["first"])
        }


        observerSet.perform(context: "second")
        XCTAssertEqual(observerSet.observerCountForTesting(), 1)

        wait(for: [exp2], timeout: timeout)
        XCTAssertEqual(values, ["first"])
        XCTAssertNotNil(observation)
        XCTAssertEqual(observerSet.observerCountForTesting(), 0)
    }

    func testInvalidWithObservationRelease() {
        let exp1 = expectation(description: "1st")
        let exp2 = expectation(description: "2nd").inverted()
        var exps = [ exp1, exp2 ]
        var values = [String?]()

        let observerSet = _AFObserverSet<String?>()
        autoreleasepool {
            let observation = observerSet.add {
                values.append($0)
                exps.removeFirst().fulfill()
            }

            observerSet.perform(context: "first")
            wait(for: [exp1], timeout: timeout)
            XCTAssertEqual(values, ["first"])
            XCTAssertNotNil(observation)
        }

        observerSet.perform(context: "second")
        XCTAssertEqual(observerSet.observerCountForTesting(), 1)

        wait(for: [exp2], timeout: timeout)
        XCTAssertEqual(values, ["first"])
        XCTAssertEqual(observerSet.observerCountForTesting(), 0)
    }

    func testRemoveObserver() {
        let exp1 = expectation(description: "1st")
        exp1.expectedFulfillmentCount = 3
        let exp2 = expectation(description: "2nd")
        let expNoMore = expectation(description: "no more").inverted()
        var exps = [ exp1, exp1, exp1, exp2, expNoMore ]
        var values = [Int]()

        let observerSet = _AFObserverSet<Int>()
        let callback = { (ctx: Int) in
            values.append(ctx)
            exps.removeFirst().fulfill()
        }
        let reference = NSObject()
        let normalObservation = observerSet.add(callback: callback)
        let refrenceObservation = observerSet.add(observer: reference, callback: callback)
        let removeObservation = observerSet.add(callback: callback)
        XCTAssertEqual(observerSet.observerCountForTesting(), 0)
        XCTAssert(normalObservation !== refrenceObservation)

        observerSet.perform(context: 1)
        wait(for: [exp1], timeout: timeout)
        XCTAssertEqual(values, [1, 1, 1])
        XCTAssertEqual(observerSet.observerCountForTesting(), 3)

        observerSet.remove(reference)
        observerSet.remove(removeObservation)
        observerSet.perform(context: 2)

        wait(for: [exp2, expNoMore], timeout: timeout)
        XCTAssertEqual(values, [1, 1, 1, 2])
        XCTAssertEqual(observerSet.observerCountForTesting(), 1)
    }

    func testInitialCallOptinalType() {
        let observerSet = _AFObserverSet<String?>()

        var values1 = [String?]()
        let observation1 = observerSet.add(initial: true) {
            values1.append($0)
        }

        noBlockingWait(timeout)
        XCTAssertEqual(values1, [nil])

        observerSet.perform(context: "first")
        noBlockingWait(timeout)
        XCTAssertEqual(values1, [nil, "first"])

        var values2 = [String?]()
        let exp2 = expectation(description: "2nd")
        let observation2 = observerSet.add(initial: true) {
            values2.append($0)
            exp2.fulfill()
        }

        wait(for: [exp2], timeout: timeout)
        XCTAssertEqual(values2, ["first"])

        XCTAssert(observation1 !== observation2, "only for keep instance")
    }

    func testInitialCallNoOptinalType() {
        let observerSet = _AFObserverSet<String>()

        var values1 = [String]()
        let observation1 = observerSet.add(initial: true) {
            values1.append($0)
        }

        noBlockingWait(timeout)
        XCTAssertEqual(values1, [])

        observerSet.perform(context: "first")
        noBlockingWait(timeout)
        XCTAssertEqual(values1, ["first"])

        var values2 = [String?]()
        let exp2 = expectation(description: "2nd")
        let observation2 = observerSet.add(initial: true) {
            values2.append($0)
            exp2.fulfill()
        }

        wait(for: [exp2], timeout: timeout)
        XCTAssertEqual(values2, ["first"])

        XCTAssert(observation1 !== observation2, "only for keep instance")
    }

    func testDuplicatePerformNoCompare() {
        let observerSet = _AFObserverSet<Int>()

        var values = [Int]()
        observerSet.add(observer: self) {
            values.append($0)
        }

        observerSet.perform(context: 1)
        observerSet.perform(context: 2)
        observerSet.perform(context: 2)
        observerSet.perform(context: 1)
        noBlockingWait(timeout)
        XCTAssertEqual(values, [1, 2, 2, 1])
    }

    func testDuplicatePerformWithCompare() {
        let observerSet = _AFObserverSet<Int> { lhs, rhs in
            lhs == rhs
        }

        var values = [Int]()
        observerSet.add(observer: self) {
            values.append($0)
        }

        observerSet.perform(context: 1)
        observerSet.perform(context: 2)
        observerSet.perform(context: 2)
        observerSet.perform(context: 1)
        noBlockingWait(timeout)
        XCTAssertEqual(values, [1, 2, 1])
    }

    func testInvalidateShouldReleaseResources() {
        let observerSet = _AFObserverSet<Int>()

        weak var objRef: TestObject?
        var observation: MBObservation!

        autoreleasepool {
            let obj = TestObject(name: "")
            observation = observerSet.add { _ in
                print(obj)
            }
            objRef = obj
        }
        XCTAssertNotNil(objRef)
        observation.invalidate()

        noBlockingWait(timeout)
        XCTAssertNil(objRef)
    }

    func testConcurrentQueue() {
        // 如果不用 barrier async 的话，大概率会出现内存错误
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        let observerSet = _AFObserverSet<TestObject>(queue: queue)

        observerSet.add(observer: self) {
            dispatchPrecondition(condition: .onQueue(queue))
            debugPrint($0, $0.name)
        }

        for i in 0...10000 {
            DispatchQueue.global().async {
                let value = TestObject(name: "v\(i)")
                observerSet.perform(context: value)
            }
        }

        noBlockingWait(0.02)
    }
}

private class TestObject: Equatable {
    var name: String

    init(name: String) {
        self.name = name
    }

    static func == (lhs: TestObject, rhs: TestObject) -> Bool {
        lhs === rhs
    }
}
