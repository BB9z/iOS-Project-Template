import XCTest
@testable import B9MulticastDelegate


protocol TestSwiftProtocol {
    func kindString() -> String
}

struct TestKindA: TestSwiftProtocol {
    func kindString() -> String {
        return "Kind: A"
    }
}

class TestKindB: TestSwiftProtocol {
    func kindString() -> String {
        return "Kind: B"
    }
}

class TestKindC {
    func throwError() throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
}

class TestObject: CustomStringConvertible {
    init(description: String) {
        self.description = description
    }
    var description: String
}

final class B9MulticastDelegateTests: XCTestCase {

    func testAddAndRemove() {
        let a = TestKindA()
        let b1 = TestKindB()
        let b2 = TestKindB()

        let d = MulticastDelegate<TestSwiftProtocol>()
        d.add(nil)
        XCTAssert(d.debugContent == [])
        d.add(a)
        XCTAssert(d.debugContent == [], "Add non-object takes no effect.")
        print(d)

        d.add(b1)
        XCTAssert(d.debugContent == [b1])
        d.add(b1)
        XCTAssert(d.debugContent == [b1], "Adding multiple times has no effect.")
        print(d)

        d.add(b2)
        XCTAssert(d.debugContent == [b1, b2])
        print(d)

        d.remove(b1)
        XCTAssert(d.debugContent == [b2])

        d.remove(b1)
        XCTAssert(d.debugContent == [b2])

        d.remove(nil)
        XCTAssert(d.debugContent == [b2])

        d.remove(b2)
        XCTAssert(d.debugContent == [])
    }

    func testSwiftObjContains() {
        var result: Bool
        let b1 = TestKindB()
        let b2 = TestKindB()
        let d = MulticastDelegate<TestKindB>()
        d.add(b1)
        XCTAssertTrue(d.contains(object: b1))
        XCTAssertFalse(d.contains(object: b2))
        result = d.contains { o -> Bool in
            return o === b1
        }
        XCTAssertTrue(result)
        d.remove(b1)
        XCTAssertFalse(d.contains(object: b1))
    }

    func testNSObjectContains() {
        var result: Bool
        let otherObj = XCTestCase()
        let d2 = MulticastDelegate<XCTActivity>()
        d2.add(self)
        XCTAssertTrue(d2.contains(object: self))
        XCTAssertFalse(d2.contains(object: otherObj))
        result = d2.contains { o -> Bool in
            return o === self
        }
        XCTAssertTrue(result)
        d2.remove(self)
        XCTAssertFalse(d2.contains(object: self))
    }

    func testWeakRef() {
        let d = MulticastDelegate<XCTestCase>()
        do {
            let obj = XCTestCase()
            d.add(obj)
            XCTAssert(d.debugContent == [obj])
        }
        XCTAssert(d.debugContent == [], "The object should now be released.")
    }

    func testInvokeErrorHandling() {
        let d = MulticastDelegate<TestKindC>()
        let c1 = TestKindC()
        let c2 = TestKindC()
        d.add(c1)
        d.add(c2)

        var errorCount = 0
        // Catch inside
        d.invoke { c in
            do {
                try c.throwError()
            } catch {
                print(error)
                errorCount += 1
            }
        }
        XCTAssertEqual(errorCount, 2)

        errorCount = 0
        // Catch outside
        do {
            try d.invoke { c in
                try c.throwError()
            }
        } catch {
            print(error)
            errorCount += 1
        }
        XCTAssertEqual(errorCount, 1)
    }

    func testSequenceThreadSafe() {
        let d = MulticastDelegate<CustomStringConvertible>()
        let queueRead = DispatchQueue(label: "Read")
        let queueWrite1 = DispatchQueue(label: "Write1")
        let queueWrite2 = DispatchQueue(label: "Write2")
        let readEnd = XCTestExpectation()
        let writeEnd1 = XCTestExpectation()
        let writeEnd2 = XCTestExpectation()

        let objectCount = 2000
        let objs = (0...objectCount).map { TestObject(description: String($0)) }
        let objsProviderLock = NSLock()
        var numberOfObjectProvided = 0
        func object(of index: Int) -> TestObject {
            objsProviderLock.lock()
            defer { objsProviderLock.unlock() }
            numberOfObjectProvided += 1
            print("\(numberOfObjectProvided) + \(index)")
            return objs[index]
        }

        queueWrite1.async {
            for i in 0..<(objectCount/2) {
                d.add(object(of: i))
            }
            writeEnd1.fulfill()
        }
        queueWrite2.async {
            for i in (objectCount/2)..<objectCount {
                d.add(object(of: i))
            }
            writeEnd2.fulfill()
        }
        queueRead.async {
            for i in 0...20 {
                usleep(100_000)  // 100 ms
                print("loop \(i) start")
                var counter = 0
                d.forEach { obj in
                    counter += 1
                }
                print("loop \(i) end, counter = \(counter)")
            }
            readEnd.fulfill()
        }
        wait(for: [readEnd, writeEnd1, writeEnd2], timeout: 10)
        assert(d.debugContent.count == objectCount)
        print("end")
    }
}

// MARK: -
extension MulticastDelegate {
    var debugContent: [AnyObject] {
        return compactMap { $0 as AnyObject }
    }
}

func == (lhs: [AnyObject], rhs: [AnyObject]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for i in 0 ..< lhs.count {
        if lhs[i] !== rhs[i] {
            return false
        }
    }
    return true
}

