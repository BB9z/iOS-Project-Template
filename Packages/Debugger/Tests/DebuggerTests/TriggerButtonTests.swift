@testable import Debugger
import XCTest

final class DebuggerTriggerButtonTests: XCTestCase {

    func testInstall() {
        // 没有 host application 时 UIApplication 不能初始化
        XCTAssertTrue(UIApplication.shared.windows.isEmpty)

        // 无 key window 时安装无效果
        Debugger.installTriggerButton()
        XCTAssertNil(triggerButton)

        // 有 window 安装，按钮应存在
        let newWindow = UIWindow()
        Debugger.installTriggerButton(in: newWindow)
        XCTAssertNotNil(triggerButton)
    }

    func testDoubleInstall() {
        let aWindow = UIWindow()
        let bWindow = UIWindow()

        Debugger.installTriggerButton(in: aWindow)
        XCTAssertTrue(aWindow.subviews.contains(triggerButton!))
        weak var beforeButtonRef = triggerButton

        Debugger.installTriggerButton(in: bWindow)
        XCTAssertTrue(bWindow.subviews.contains(triggerButton!))
        weak var afterButtonRef = triggerButton

        // 相同的实例
        XCTAssertNotNil(beforeButtonRef)
        XCTAssertNotNil(afterButtonRef)
        XCTAssertTrue(beforeButtonRef === afterButtonRef)
    }

    func testUpdateObserver() {
        weak var buttonRef: TriggerButton?
        autoreleasepool {
            Debugger.isDebugEnabled = false

            // 未添加到 window 默认未隐藏
            let button = TriggerButton()
            XCTAssertFalse(button.isHidden)

            // 添加后应更新
            let window = UIWindow()
            window.addSubview(button)
            XCTAssertTrue(button.isHidden)

            // 激活后应重新显示
            Debugger.isDebugEnabled = true
            XCTAssertFalse(button.isHidden)
            buttonRef = button
        }
        XCTAssertNil(buttonRef, "应正确释放")
    }

    func testObserverThread() {
        let button = TriggerButton()
        let window = UIWindow()
        window.addSubview(button)

        let exp = XCTestExpectation()
        let queue = DispatchQueue(label: "test")
        queue.asyncAfter(deadline: .now() + 0.1) {
            Debugger.isDebugEnabled = true
        }
        queue.asyncAfter(deadline: .now() + 0.2) {
            Debugger.isDebugEnabled = false
            exp.fulfill()
        }
        wait(for: [exp], timeout: .infinity)
    }
}
