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

    let selectedAlpha = CGFloat(0.8)
    let deselectedAlpha = CGFloat(0.3)
    var lastUpdateAnimated: Bool?

    override func update(selectedControls: [UIControl], deselectedControls: [UIControl], animated: Bool) {
        // 故意不调用 super，不应影响行为
        selectedControls.forEach { $0.alpha = selectedAlpha }
        deselectedControls.forEach { $0.alpha = deselectedAlpha }
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

/// delegate 方法调用验证
fileprivate class TestDelegate: MBGroupSelectionControlDelegate {
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

class MBGroupSelectionControlTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        SimulateApp.setupForNoHost()
    }

    func testSelectionAndVerifyTags() {
        let sut = MBGroupSelectionControl()
        let control1 = UIButton().tag(1)
        let control2 = UIButton().tag(2)
        let control3 = UIButton().tag(3)
        sut.controls = [control1, control2, control3]

        XCTAssertEqual(sut.selectedControls, [])
        XCTAssertEqual(sut.selectedTags, [])
        XCTAssertNil(sut.selectedIndex)

        tap(control1)
        XCTAssertEqual(sut.selectedControls, [control1])
        XCTAssertEqual(sut.selectedTags, [1])
        XCTAssertEqual(sut.selectedIndex, 0)

        tap(control2)
        XCTAssertEqual(sut.selectedControls, [control2])
        XCTAssertEqual(sut.selectedTags, [2])
        XCTAssertEqual(sut.selectedIndex, 1)

        sut.allowsMultipleSelection = true
        tap(control3)
        XCTAssertEqual(sut.selectedControls, [control2, control3])
        XCTAssertEqual(sut.selectedTags, [2, 3])
        XCTAssertEqual(sut.selectedIndex, 1)

        tap(control2)
        XCTAssertEqual(sut.selectedControls, [control3])
        XCTAssertEqual(sut.selectedTags, [3])
        XCTAssertEqual(sut.selectedIndex, 2)
    }

    func testSelectedTagsOrder() {
        let control1 = UIButton().tag(1)
        let control2 = UIButton().tag(2)
        let control3 = UIButton().tag(3)

        let orginalControl = MBGroupSelectionControl()
        orginalControl.controls = [control3, control2, control1]
        orginalControl.allowsMultipleSelection = true

        let alphaControl = AlphaGroupControl()
        alphaControl.controls = [control3, control2, control1]
        alphaControl.allowsMultipleSelection = true

        orginalControl.update(selection: [control1, control2, control3], animated: false)
        alphaControl.update(selection: [control1, control2, control3], animated: false)

        XCTAssertEqual(orginalControl.selectedTags, [1, 2, 3], "默认按 tag 大小排序")
        XCTAssertEqual(alphaControl.selectedTags, [3, 2, 1])
    }

    func testIndexSet() {
        var assertCalled = false
        MBAssertSetHandler { _, _, _ in assertCalled = true }
        defer { MBAssertSetHandler(nil) }

        let sut = AlphaGroupControl()
        let control1 = UIButton()
        let control2 = UIButton()
        sut.controls = [control1, control2]

        sut.resetLast()
        sut.selectedIndex = nil
        XCTAssertNil(sut.lastUpdateAnimated, "选中没变无操作")

        sut.resetLast()
        sut.selectedIndex = 0
        XCTAssertEqual(sut.lastUpdateAnimated, false)
        XCTAssertEqual(sut.selectedControls, [control1])

        sut.resetLast()
        sut.selectedIndex = 1
        XCTAssertEqual(sut.selectedControls, [control2])

        sut.resetLast()
        XCTAssertFalse(assertCalled)
        sut.selectedIndex = 2
        XCTAssertTrue(assertCalled)
        XCTAssertEqual(sut.selectedIndex, 1)
        XCTAssertEqual(sut.selectedControls, [control2])
    }

    func testIndexSetWithMultipleSelection() {
        let sut = AlphaGroupControl()
        let control1 = UIButton()
        let control2 = UIButton()
        sut.controls = [control1, control2]
        sut.allowsMultipleSelection = true

        sut.selectedIndex = 1
        tap(control1)
        XCTAssertEqual(sut.selectedControls, [control1, control2])
        XCTAssertEqual(sut.selectedIndex, 0)

        sut.selectedIndex = 0
        XCTAssertEqual(sut.selectedControls, [control1])

        sut.update(selection: [control1, control2], animated: true)
        sut.selectedIndex = sut.selectedIndex
        XCTAssertEqual(sut.selectedControls, [control1])
    }

    func testControlsSetter() {
        let sut = MBGroupSelectionControl()
        let control1 = UIButton()
        let control2 = UIButton()
        sut.controls = [control1, control2]
        let actions1st = control1.actions(forTarget: sut, forControlEvent: .touchUpInside)

        sut.controls = [control1, control2]
        let actions2nd = control1.actions(forTarget: sut, forControlEvent: .touchUpInside)

        XCTAssertEqual(actions1st, actions2nd, "相同设置没变化")

        sut.controls = [control2]
        let actions3rd = control1.actions(forTarget: sut, forControlEvent: .touchUpInside)
        XCTAssertNil(actions3rd)
    }

    func testUpdateOverwrite() {
        let sut = AlphaGroupControl()
        let control1 = UIButton()
        let control2 = UIButton()
        sut.controls = [control1, control2]

        XCTAssertEqual(control1.alpha, 0)
        XCTAssertEqual(control2.alpha, 0)
        
        sut.update(selection: [control1], animated: true)
        XCTAssertEqual(sut.lastUpdateAnimated, true)
        XCTAssertEqual(control1.alpha, sut.selectedAlpha, accuracy: 1e-6)
        XCTAssertEqual(control2.alpha, 0)

        sut.update(selection: [control2], animated: false)
        XCTAssertEqual(sut.lastUpdateAnimated, false)
        XCTAssertEqual(control1.alpha, sut.deselectedAlpha, accuracy: 1e-6)
        XCTAssertEqual(control2.alpha, sut.selectedAlpha, accuracy: 1e-6)
    }

    func testAllowsMultipleSelectionChanges() {
        let sut = AlphaGroupControl()
        let control1 = UIButton()
        let control2 = UIButton()
        sut.controls = [control1, control2]

        XCTAssertFalse(sut.allowsMultipleSelection, "默认单选")
        sut.update(selection: [control1], animated: false)

        sut.allowsMultipleSelection = true
        XCTAssertEqual(sut.selectedControls, [control1], "单选变多选，保持选中状态")

        tap(control2)
        XCTAssertEqual(sut.selectedControls, [control1, control2])

        sut.allowsMultipleSelection = false
        XCTAssertEqual(sut.selectedControls, [control1], "多选变单选，保留第一个选中的控件的状态")

        XCTAssertEqual(sut.lastUpdateAnimated, false)
        sut.update(selection: [control2], animated: true)
        XCTAssertEqual(sut.lastUpdateAnimated, true)
        sut.update(selection: [control2], animated: false)
        XCTAssertEqual(sut.lastUpdateAnimated, true, "相同的选择无执行")

        sut.allowsMultipleSelection = false
        XCTAssertEqual(sut.lastUpdateAnimated, true, "相同的 allowsMultipleSelection，不触发控件更新")
    }

    func testDelegateWhenSingleSelection() {
        let sut = MBGroupSelectionControl()
        let control1 = UIControl()
        let control2 = UIControl()
        sut.controls = [control1, control2]

        let delegate = TestDelegate()
        sut.delegate = delegate

        tap(control1)
        XCTAssertTrue(delegate.shouldSelectCalled)

        tap(control1)
        XCTAssertFalse(delegate.shouldDeselectCalled, "单选状态下，二次选中不反选")

        // 重置状态
        delegate.shouldSelectCalled = false
        delegate.shouldDeselectCalled = false

        sut.update(selection: [control2], animated: false)
        XCTAssertFalse(delegate.shouldSelectCalled, "手动修改选中不调用代理方法")
        XCTAssertFalse(delegate.shouldDeselectCalled)
    }

    func testDelegateWhenMultipleSelection() {
        let sut = MBGroupSelectionControl()
        sut.allowsMultipleSelection = true
        let control1 = UIControl()
        let control2 = UIControl()
        sut.controls = [control1, control2]

        let delegate = TestDelegate()
        sut.delegate = delegate

        tap(control1)
        XCTAssertTrue(delegate.shouldSelectCalled)

        tap(control1)
        XCTAssertTrue(delegate.shouldDeselectCalled, "多选状态下，二次选中反选")

        // 重置状态
        delegate.shouldSelectCalled = false
        delegate.shouldDeselectCalled = false

        sut.update(selection: [control2], animated: false)
        XCTAssertFalse(delegate.shouldSelectCalled, "手动修改选中不调用代理方法")
        XCTAssertFalse(delegate.shouldDeselectCalled)
    }

    func testValueChangedActionDelay() {
        let sut = AlphaGroupControl()
        let control1 = UIControl()
        let control2 = UIControl()
        sut.controls = [control1, control2]
        sut.addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        let exp1st = XCTestExpectation(description: "未设 delay 应立即触发")
        valueChangedExpectation = exp1st
        tap(control1)
        XCTAssertEqual(sut.lastShouldSelectControl, control1)
        wait(for: [exp1st], timeout: 0)

        sut.valueChangedActionDelay = 0.01
        sut.resetLast()
        let exp2nd = XCTestExpectation(description: "Value changed action sent")
        valueChangedExpectation = exp2nd
        tap(control2)
        XCTAssertEqual(sut.lastShouldSelectControl, control2, "代理是立即请求的")
        XCTAssertNil(sut.lastShouldDeselectControl, "单选模式反选代理不调用")
        wait(for: [exp2nd], timeout: 0.01)
    }

    private var valueChangedExpectation: XCTestExpectation?
    @objc func valueChanged() {
        valueChangedExpectation?.fulfill()
    }

    func testIBBind() {
        let sut = MBGroupSelectionControl()
        let stack = UIStackView(arrangedSubviews: [
            UIControl(),
            UIView(),
        ])
        sut.setValue(stack, forKey: "_IBBindStackArrangedAsControls")

        XCTAssertEqual(sut.controls.count, 1)
        XCTAssertNil(sut.value(forKey: "_IBBindStackArrangedAsControls"))
    }
}

#endif
