/*
 HasItemTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import AppFramework
import XCTest

#if canImport(UIKit)
import UIKit

class TestViewController: UIViewController, HasItem {
    var item: String!
}

class TestView: UIView, HasItem {
    var item: String!
}

final class HasItemPrepareSegueTests: XCTestCase {

    func testSenderNoItem() {
        let sourceVC = TestViewController()
        sourceVC.item = "vcItem"
        let destinationVC = TestViewController()
        let segue = UIStoryboardSegue(identifier: nil, source: sourceVC, destination: destinationVC)

        // 设置 view 层级
        let childView = UIView()
        sourceVC.view.addSubview(childView)

        destinationVC.item = nil
        sourceVC.generalPrepare(segue: segue, sender: childView)
        XCTAssertEqual("vcItem", destinationVC.item)
    }

    func testSenderHasItem() {
        let sourceVC = TestViewController()
        sourceVC.item = "vcItem"
        let destinationVC = TestViewController()
        let segue = UIStoryboardSegue(identifier: nil, source: sourceVC, destination: destinationVC)

        // 设置 view 层级
        let sender = TestView()
        sender.item = "sender"
        sourceVC.view.addSubview(sender)

        // 直接从 sender 拿
        destinationVC.item = nil
        sourceVC.generalPrepare(segue: segue, sender: sender)
        XCTAssertEqual("sender", destinationVC.item)
    }

    func testSearchThroughViewsCanFind() {
        let sourceVC = UIViewController()
        let destinationVC = TestViewController()
        let segue = UIStoryboardSegue(identifier: nil, source: sourceVC, destination: destinationVC)

        let testView = TestView()
        testView.item = "testView"
        sourceVC.view = testView

        let sender = UIView()
        testView.addSubview(sender)

        sourceVC.generalPrepare(segue: segue, sender: sender)
        XCTAssertEqual("testView", destinationVC.item)
    }

    func testSearchThroughViewsNotFound() {
        let sourceVC = UIViewController()
        let destinationVC = TestViewController()
        let segue = UIStoryboardSegue(identifier: nil, source: sourceVC, destination: destinationVC)

        let childView = UIView()
        sourceVC.view.addSubview(childView)

        let sender = UIView()
        childView.addSubview(sender)

        sourceVC.generalPrepare(segue: segue, sender: sender)
        XCTAssertNil(destinationVC.item)
    }

    // MARK: - 特殊情况

    func testDestinationNoItem() {
        let sourceVC = TestViewController()
        let destinationVC = UIViewController()
        let segue = UIStoryboardSegue(identifier: nil, source: sourceVC, destination: destinationVC)

        sourceVC.item = nil
        sourceVC.generalPrepare(segue: segue, sender: nil)
        // 不应有传值，也就不会传空崩溃
    }

    func testSenderItemIsNil() {
        let sender = TestView()
        sender.item = nil
        // Except fatalError
        // sourceVC.generalPrepare(segue: segue, sender: sender)
    }

    func testSearchThroughViewsButSenderNotInVc() {
        let sourceVC = UIViewController()
        let destinationVC = TestViewController()
        let segue = UIStoryboardSegue(identifier: nil, source: sourceVC, destination: destinationVC)

        let childView = UIView()
        let sender = UIView()
        childView.addSubview(sender)

        sourceVC.generalPrepare(segue: segue, sender: sender)
        XCTAssertNil(destinationVC.item)

        // Undefined behavior: sender 属于另外的页面，属于业务 bug
        let anotherView = TestView()
        anotherView.item = "another"
        anotherView.addSubview(childView)
        sourceVC.generalPrepare(segue: segue, sender: sender)
        XCTAssertEqual("another", destinationVC.item)
    }
}
#endif // Can import UIKit
