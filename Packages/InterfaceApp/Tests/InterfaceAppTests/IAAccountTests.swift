/*
 IAAccountTests.swift
 InterfaceApp

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import InterfaceApp
import XCTest

class MockAccount: IAAccount {
    let id: String
    var didLoginCalled = false
    var didLogoutCalled = false

    init(id: String) {
        self.id = id
    }

    func didLogin() {
        didLoginCalled = true
    }

    func didLogout() {
        didLogoutCalled = true
    }
}

class IAAccountTests: XCTestCase {
    func testAccountEquality() {
        let account1 = MockAccount(id: "123")
        let account2 = MockAccount(id: "123")
        let account3 = MockAccount(id: "456")

        XCTAssertEqual(account1.id, account2.id)
        XCTAssertNotEqual(account1.id, account3.id)
    }

    func testAccountLoginLogout() {
        let account = MockAccount(id: "123")

        XCTAssertFalse(account.didLoginCalled)
        XCTAssertFalse(account.didLogoutCalled)

        account.didLogin()
        XCTAssertTrue(account.didLoginCalled)

        account.didLogout()
        XCTAssertTrue(account.didLogoutCalled)
    }
}
