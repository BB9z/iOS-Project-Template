import XCTest
@testable import B9FoundationUI

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
        XCTAssertEqual(nil, vc.view.next(type: UIView.self))
        XCTAssertEqual(vc.view, childView.next(type: UIView.self))
        XCTAssertEqual(childView, childChildView.next(type: UIView.self))

        // Check ScrollView
        XCTAssertEqual(vc.view, childView.next(type: UIScrollView.self))
        XCTAssertEqual(vc.view, childChildView.next(type: UIScrollView.self))

        // Check button
        XCTAssertEqual(nil, childView.next(type: UIButton.self))
        XCTAssertEqual(childView, childChildView.next(type: UIButton.self))
    }
}
