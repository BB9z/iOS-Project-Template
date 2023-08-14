/*
 AccountManagerTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
@testable import AppFramework
import InterfaceApp
import XCTest

private class TestAccount: IAAccount {
    let id: String


    init(id: String) {
        self.id = id
    }

    func didLogin() {}
    func didLogout() {}
}


class AccountManagerTests: XCTestCase {

    func testAddCurrentUserChangeObserver() {
        let observer = TestObserver()
        AccountManager.addCurrentUserChangeObserver(observer, initial: true) { account in
            XCTAssertNotNil(account)
        }
        AccountManager.current = TestAccount(id: "1")
        XCTAssertTrue(observer.called)
    }

    func testRemoveCurrentUserChangeObserver() {
        let observer = TestObserver()
        AccountManager.addCurrentUserChangeObserver(observer, initial: true) { account in
            XCTAssertNotNil(account)
        }
        AccountManager.removeCurrentUserChangeObserver(observer)
        AccountManager.current = TestAccount(id: "1")
        XCTAssertFalse(observer.called)
    }

    func testUpdateCurrent() {
        let oldValue = TestAccount(id: "1")
        let newValue = TestAccount(id: "2")
        let observer = TestObserver()
        AccountManager.addCurrentUserChangeObserver(observer, initial: true) { account in
            XCTAssertNotNil(account)
        }
        AccountManager.current = oldValue
        XCTAssertTrue(observer.called)
        observer.called = false
        AccountManager.current = oldValue
        XCTAssertFalse(observer.called)
        observer.called = false
        AccountManager.current = newValue
        XCTAssertTrue(observer.called)
    }

    func testIsCurrent() {
        let account = TestAccount(id: "1")
        AccountManager.current = account
        XCTAssertTrue(account.isCurrent)
        AccountManager.current = nil
        XCTAssertFalse(account.isCurrent)
    }
}

private class TestObserver {
    var called = false
    func callback(_ account: IAAccount?) {
        called = true
    }
}
