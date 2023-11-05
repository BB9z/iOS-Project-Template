/*
 AccountManagerTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import InterfaceApp
import XCTest

private class TestAccount: IAAccount, Equatable, CustomDebugStringConvertible {
    let id: String


    init(id: String) {
        self.id = id
    }

    var didLoginCalled = false
    var didLogoutCalled = false

    func didLogin() {
        dispatchPrecondition(condition: .onQueue(.main))
        didLoginCalled = true
    }
    func didLogout() {
        dispatchPrecondition(condition: .onQueue(.main))
        didLogoutCalled = true
    }

    var debugDescription: String {
        "TestAccount(\(id))"
    }

    static func == (lhs: TestAccount, rhs: TestAccount) -> Bool {
        lhs === rhs
    }
}

class AccountManagerTests: XCTestCase {
    static var originalAccount: IAAccount?

    let timeout: TimeInterval = 0.01

    override class func setUp() {
        super.setUp()
        originalAccount = AccountManager.current
        AccountManager.current = nil
    }

    override class func tearDown() {
        super.tearDown()
        AccountManager.current = originalAccount
    }

    func testObservationWithSameIDAndBackgroundQueue() {
        DispatchQueue.global().sync {
            XCTAssertNil(AccountManager.current)
            noBlockingWait(timeout)

            let account1 = TestAccount(id: "same")
            let account2 = TestAccount(id: "same")

            var values = [IAAccount?]()
            let observer = AccountManager.observeCurrentChange(initial: true) {
                values.append($0)
            }

            noBlockingWait(timeout)
            XCTAssertEqual(values as? [TestAccount?], [nil])

            AccountManager.current = account1
            noBlockingWait(timeout)
            XCTAssertEqual(values as? [TestAccount?], [nil, account1])

            AccountManager.current = account2
            noBlockingWait(timeout)
            XCTAssertEqual(values as? [TestAccount?], [nil, account1, account2])

            AccountManager.removeCurrentChangeObserver(observer)
            AccountManager.current = nil
        }
    }
    
    func testObservationWithSelfAsObserver() {
        XCTAssertNil(AccountManager.current)
        noBlockingWait(timeout)

        let account1 = TestAccount(id: "123")
        let account2 = TestAccount(id: "456")

        var values = [IAAccount?]()
        AccountManager.observeCurrentChange(self, initial: true) {
            values.append($0)
        }
        noBlockingWait(timeout)
        XCTAssertEqual(values as? [TestAccount?], [nil])

        AccountManager.current = account1
        noBlockingWait(timeout)
        XCTAssertEqual(values as? [TestAccount?], [nil, account1])

        AccountManager.current = account2
        noBlockingWait(timeout)
        XCTAssertEqual(values as? [TestAccount?], [nil, account1, account2])

        AccountManager.removeCurrentChangeObserver(self)
        AccountManager.current = nil
    }

    func testObservationWithSameInstance() {
        XCTAssertNil(AccountManager.current)
        noBlockingWait(timeout)

        let account = TestAccount(id: #function)

        var values = [IAAccount?]()
        let observer = AccountManager.observeCurrentChange(initial: false) {
            values.append($0)
        }

        noBlockingWait(timeout)
        XCTAssertEqual(values as? [TestAccount?], [])

        AccountManager.current = account
        noBlockingWait(timeout)
        XCTAssertEqual(values as? [TestAccount?], [account])

        AccountManager.current = account
        noBlockingWait(timeout)
        XCTAssertEqual(values as? [TestAccount?], [account])

        AccountManager.removeCurrentChangeObserver(observer)
        AccountManager.current = nil
    }

    func testAccountCurrentPropertyAndMethodCalled() {
        let account = TestAccount(id: #function)
        XCTAssertFalse(account.isCurrent)
        XCTAssertFalse(account.didLogoutCalled)

        AccountManager.current = account
        XCTAssertTrue(account.isCurrent)
        XCTAssertFalse(account.didLoginCalled)
        noBlockingWait(timeout)
        XCTAssertTrue(account.didLoginCalled)

        AccountManager.current = TestAccount(id: #function)
        XCTAssertFalse(account.isCurrent)
        XCTAssertFalse(account.didLogoutCalled)
        noBlockingWait(timeout)
        XCTAssertTrue(account.didLogoutCalled)

        AccountManager.current = account
        XCTAssertTrue(account.isCurrent)

        AccountManager.current = nil
        XCTAssertFalse(account.isCurrent)
    }
}
