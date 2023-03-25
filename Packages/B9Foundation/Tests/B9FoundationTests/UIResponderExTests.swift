/*
 UIResponderExTests.swift
 B9Foundation

 Copyright © 2022-2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@testable import B9Foundation
import XCTest

final class UIResponderTests: XCTestCase {

    func testNextType() {
        let vc = UIViewController()
        vc.view = UIScrollView()
        let childView = UIButton()
        vc.view.addSubview(childView)
        let childChildView = UIView()
        childView.addSubview(childChildView)

        // Check view controller
        XCTAssertNil(vc.next(type: UIViewController.self))
        XCTAssertEqual(vc, vc.view.next(type: UIViewController.self))
        XCTAssertEqual(vc, childView.next(type: UIViewController.self))

        // Check view
        XCTAssertNil(vc.view.next(type: UIView.self))
        XCTAssertEqual(vc.view, childView.next(type: UIView.self))
        XCTAssertEqual(childView, childChildView.next(type: UIView.self))

        // Check ScrollView
        XCTAssertEqual(vc.view, childView.next(type: UIScrollView.self))
        XCTAssertEqual(vc.view, childChildView.next(type: UIScrollView.self))

        // Check button
        XCTAssertNil(childView.next(type: UIButton.self))
        XCTAssertEqual(childView, childChildView.next(type: UIButton.self))
    }
}
