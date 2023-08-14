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

}
