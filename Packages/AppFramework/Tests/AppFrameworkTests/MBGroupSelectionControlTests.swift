/*
 MBGroupSelectionControlTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(UIKit)
import AppFramework
import UIKit
import XCTest

// TODO: 组件增加选中修改方法
// TODO: 组件增加选中序列号方法
// TODO: 组件增加选中代理

/**
 用于测试子类行为

 根据不同状态会调整子控件的 alpha 值：初始 0，选中 0.8，取消选中 0.3
*/ 
fileprivate class AlphaGroupControl: MBGroupSelectionControl, MBGroupSelectionControlDelegate {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }

    override var controls: [UIControl] {
        didSet {
            controls.forEach { $0.alpha = 0 }
        }
    }

    // 改成不按大小排序，按控件顺序
    override var selectedTags: [Int] {
        selectedControls.map { $0.tag }
    }

    var lastUpdateAnimated: Bool?

    override func update(selectedControls: [UIControl], deselectedControls: [UIControl], animated: Bool) {
        // 故意不调用 super，不应影响行为
        selectedControls.forEach { $0.alpha = 0.8 }
        deselectedControls.forEach { $0.alpha = 0.3 }
        lastUpdateAnimated = animated
    }

    var couldSelect = true
    var couldDeselect = true
    var lastShouldSelectControl: UIControl?
    var lastShouldDeselectControl: UIControl?

    func groupSelectionControl(_ groupControl: MBGroupSelectionControl, shouldSelect control: UIControl) -> Bool {
        assert(groupControl == self)
        lastShouldSelectControl = control
        return couldSelect
    }
    func groupSelectionControl(_ groupControl: MBGroupSelectionControl, shouldDeselect control: UIControl) -> Bool {
        assert(groupControl == self)
        lastShouldDeselectControl = control
        return couldDeselect
    }

    func resetLast() {
        lastUpdateAnimated = nil
        lastShouldSelectControl = nil
        lastShouldDeselectControl = nil
    }
}

class MBGroupSelectionControlTests: XCTestCase {

    func testNormal() {
        let sut = MBGroupSelectionControl()
        let control1 = UIButton()
        control1.tag = 1
        let control2 = UIButton()
        control2.tag = 2
        let control3 = UIButton()
        control3.tag = 3
        sut.controls = [control1, control2, control3]
        sut.addTarget(self, action: #selector(didChangeSelection(sender:)), for: .valueChanged)

        XCTAssertEqual(sut.selectedControls, [])
        XCTAssertEqual(sut.selectedTags, [])

        tap(control1)
        XCTAssertEqual(sut.selectedControls, [control1])
        XCTAssertEqual(sut.selectedTags, [1])

        tap(control2)
        XCTAssertEqual(sut.selectedControls, [control2])
        XCTAssertEqual(sut.selectedTags, [2])

        sut.allowsMultipleSelection = true
        tap(control3)
        XCTAssertEqual(sut.selectedControls, [control2, control3])
        XCTAssertEqual(sut.selectedTags, [2, 3])

        tap(control2)
        XCTAssertEqual(sut.selectedControls, [control3])
        XCTAssertEqual(sut.selectedTags, [3])
    }

    func testAllowsMultipleSelectionChanges() {
        let sut = AlphaGroupControl()
        let control1 = UIButton()
        let control2 = UIButton()
        sut.controls = [control1, control2]

        XCTAssertFalse(sut.allowsMultipleSelection, "默认单选")
        sut.update(selection: [control1], animated: false)

        sut.allowsMultipleSelection = true
        XCTAssertEqual(sut.selectedControls, [control1])

        tap(control2)
        XCTAssertEqual(sut.selectedControls, [control1, control2])

        sut.allowsMultipleSelection = false
        XCTAssertEqual(sut.selectedControls, [control1], "多选变单选，保留第一个选中的控件的状态")
    }

    @objc func didChangeSelection(sender: MBGroupSelectionControl) {

    }
    
    func testDelegate() {
        let control = MBGroupSelectionControl()
        let control1 = UIControl()
        control1.tag = 1
        let control2 = UIControl()
        control2.tag = 2
        
        class TestDelegate: MBGroupSelectionControlDelegate {
            var shouldSelectCalled = false
            var shouldDeselectCalled = false
            
            func groupSelectionControl(_ control: MBGroupSelectionControl, shouldSelect element: UIControl) -> Bool {
                shouldSelectCalled = true
                return true
            }
            
            func groupSelectionControl(_ control: MBGroupSelectionControl, shouldDeselect element: UIControl) -> Bool {
                shouldDeselectCalled = true
                return true
            }
        }
        
        let delegate = TestDelegate()
        control.delegate = delegate
        
        control.update(selection: [control1], animated: false)
        XCTAssertTrue(delegate.shouldSelectCalled)
        
        control.update(selection: [], animated: false)
        XCTAssertTrue(delegate.shouldDeselectCalled)
    }
    
    func testValueChangedActionDelay() {
        let control = MBGroupSelectionControl()
        let control1 = UIControl()
        control1.tag = 1
        let control2 = UIControl()
        control2.tag = 2
        
        control.valueChangedActionDelay = 0.5
        
        let expectation = XCTestExpectation(description: "Value changed action sent")
        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        control.update(selection: [control1], animated: false)
        control.update(selection: [control1, control2], animated: false)
        
        wait(for: [expectation], timeout: 1)
    }
    
    @objc func valueChanged() {
        XCTFail("Value changed action should be delayed")
    }
}

extension XCTestCase {
    /// 模拟触发 UIControl 的 touchUpInside 事件
    func tap(_ control: UIControl) {
        for target in control.allTargets {
            let object: NSObject = target as NSObject
            let rawActions = control.actions(forTarget: target, forControlEvent: .touchUpInside)
            // debugPrint(target, rawActions)
            for action in rawActions ?? [] {
                let selector = Selector(action)
                object.perform(selector, with: control)
            }
        }
    }
}
#endif
