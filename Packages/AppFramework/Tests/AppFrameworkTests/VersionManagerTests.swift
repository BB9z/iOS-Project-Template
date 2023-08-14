/*
 VersionManagerTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import AppFramework
import XCTest

class VersionManagerTests: XCTestCase {
    
    var storage = MockKeyValueStorage()

    func testWithoutVersionMock() {
        let ver = VersionManager(storage: storage)
        XCTAssert(ver.version.count > 0)
    }

    func testVersionTrack() {
        storage.dict = [:]

        let firstVersion = "1.0"
        let secondVersion = "1.1"

        // Fresh
        let ver1 = VersionManager(storage: storage, version: firstVersion)
        XCTAssertTrue(ver1.isFreshInstall)
        XCTAssertEqual(ver1.version, firstVersion)
        XCTAssertNil(ver1.upgardeFrom)

        // Noraml
        let ver2 = VersionManager(storage: storage, version: firstVersion)
        XCTAssertFalse(ver2.isFreshInstall)
        XCTAssertEqual(ver2.version, firstVersion)
        XCTAssertNil(ver2.upgardeFrom)

        // Upgrade
        let ver3 = VersionManager(storage: storage, version: secondVersion)
        XCTAssertFalse(ver3.isFreshInstall)
        XCTAssertEqual(ver3.version, secondVersion)
        XCTAssertEqual(ver3.upgardeFrom, firstVersion)

        // Noraml
        let ver4 = VersionManager(storage: storage, version: secondVersion)
        XCTAssertFalse(ver4.isFreshInstall)
        XCTAssertEqual(ver4.version, secondVersion)
        XCTAssertEqual(ver4.upgardeFrom, nil)

        // print(storage.dict)
    }

    // TODO: 测试 luanch 标记未按预期调用的场景
    
    func testSafeMode() {
        storage.dict = [:]

        let version = "1.0"

        let ver1 = VersionManager(storage: storage, version: version)
        ver1.markAppLaunching()
        XCTAssertFalse(ver1.isInSafeMode)

        let ver2 = VersionManager(storage: storage, version: version)
        ver2.markAppLaunching()
        XCTAssertFalse(ver2.isInSafeMode)

        let ver3 = VersionManager(storage: storage, version: version)
        ver3.markAppLaunching()
        XCTAssertTrue(ver3.isInSafeMode)
        XCTAssertFalse(ver3.isLaunchFinshed)
        ver3.markAppLaunchedSuccessful()
        XCTAssertTrue(ver3.isLaunchFinshed)

        let ver4 = VersionManager(storage: storage, version: version)
        ver4.markAppLaunching()
        XCTAssertFalse(ver4.isInSafeMode)
    }
}
