import XCTest
@testable import B9Action

class OCTarget: NSObject {
    @objc func fill(expectation: XCTestExpectation) {
        expectation.fulfill()
    }
}

class Counter {
    private(set) var count = 0
    @objc func add() {
        count += 1
    }
}

final class B9ActionTests: XCTestCase {

    func testBecomeInvalidAfterReferenceReleased() {
        var action: Action!

        do {
            let object = NSObject()
            action = Action({
                XCTAssert(false, "Should not be executed")
            }, reference: object)
            XCTAssertTrue(action.isValid)
        }
        XCTAssertFalse(action.isValid, "Should be invalid after reference released")
        action.perform(with: nil)
    }

    func testAlwaysValidIfNoSetReference() {
        let expectation = XCTestExpectation(description: "")
        let target = OCTarget()
        let action = Action(target: target, selector: #selector(OCTarget.fill(expectation:)))
        XCTAssertTrue(action.isValid)
        action.perform(with: expectation)
        wait(for: [expectation], timeout: 0)
    }

    func testDescription() {
        let object = NSObject()
        let action = Action({ }, reference: object)
        print(action.debugDescription)
    }

    func testBothSet() {
        let counter = Counter()
        let action = Action(target: counter, selector: #selector(Counter.add))
        action.block = {
            counter.add()
        }
        action.perform(with: nil)
        XCTAssert(counter.count == 2)
    }

    func testDelayActionBasic() {
        let expectation = XCTestExpectation(description: "")
        let counter = Counter()
        let action = DelayAction(Action {
            counter.add()
            expectation.fulfill()
        })
        action.set()
        action.set()
        action.set()
        XCTAssert(counter.count == 0, "Should perform after a delay")
        wait(for: [expectation], timeout: 0.1)
        XCTAssert(counter.count == 1, "Should only execute once")
    }

    func testDelayReschedule() {
        let expectation = XCTestExpectation(description: "")
        let counter = Counter()
        let action = DelayAction(Action {
            counter.add()
            expectation.fulfill()
        }, delay: 0.2)

        action.set()
        XCTAssert(counter.count == 0, "Should perform after a delay")

        async(delay: 0.1) {
            XCTAssert(counter.count == 0, "Should not performed at this time")
            action.set(reschedule: true)
        }
        async(delay: 0.2) {
            XCTAssert(counter.count == 0, "Should not performed at this time")
            action.set(reschedule: true)
        }
        async(delay: 0.3) {
            XCTAssert(counter.count == 0, "Should not performed at this time")
            action.set(reschedule: true)
        }
        wait(for: [expectation], timeout: 0.6)
        XCTAssert(counter.count == 1, "Should only execute once")
    }

    func testDelayCancel() {
        let expectation = XCTestExpectation(description: "")
        let action = DelayAction(Action {
            XCTAssert(false, "Should not be executed")
        }, delay: 0.1)
        action.set()
        async(delay: 0) {
            action.cancel()
        }
        async(delay: 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }


    func testDelayRelease() {
        let expectation = XCTestExpectation(description: "")
        do {
            let manager1 = Manager()
            _ = manager1.needsDoIt
            let manager2 = Manager()
            manager2.needsDoIt.set()
        }
        async(delay: 0.9) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMuiltThreadBattle() {
        let queueAction = DispatchQueue(label: "Action")
        let queueSet1 = DispatchQueue(label: "Set1")
        let queueSet2 = DispatchQueue(label: "Set2")
        let queueCancel = DispatchQueue(label: "Cancel")

        let set1End = XCTestExpectation()
        let set2End = XCTestExpectation()
        let cancelEnd = XCTestExpectation()
        var actionConuter = 0

        let action = DelayAction(Action {
            actionConuter += 1
            print("Action \(actionConuter)")
        }, delay: 0, queue: queueAction)

        queueSet1.async {
            for i in 0...5000 {
                action.set()
                print("Set \(i) in queue 1")
            }
            set1End.fulfill()
        }
        queueSet2.async {
            for i in 0...5000 {
                action.set()
                print("Set \(i) in queue 2")
            }
            set2End.fulfill()
        }
        queueCancel.async {
            for i in 0...100 {
                usleep(1000) // 1 ms
                action.cancel()
                print("Cancel \(i)")
            }
            cancelEnd.fulfill()
        }

        wait(for: [set1End, set2End, cancelEnd], timeout: 10)

        let countAfterLoop = actionConuter
        action.set()
        let finalCheck = XCTestExpectation()
        async(delay: 0.1) {
            finalCheck.fulfill()
        }
        wait(for: [finalCheck], timeout: 0.2)
        XCTAssert(actionConuter == countAfterLoop + 1, "Should work noramlly after loop")
    }
}

class Manager {
    lazy var needsDoIt = DelayAction(Action(doSomething))

    func doSomething() {
        NSLog("do it")
        needsDoIt.action.block = nil
    }

    deinit {
        NSLog("manager deinit")
    }
}

private func async(on queue: DispatchQueue = .main, delay: TimeInterval = -1, _ action: @escaping (() -> Void)) {
    if delay >= 0 {
        queue.asyncAfter(deadline: .now() + delay, execute: action)
    } else {
        queue.async(execute: action)
    }
}
