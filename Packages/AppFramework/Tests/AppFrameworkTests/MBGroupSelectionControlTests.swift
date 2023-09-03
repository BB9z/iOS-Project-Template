/*
 MBGroupSelectionControlTests.swift
 AppFramework

 Copyright © 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import XCTest

// TODO: 组件增加选中修改方法
// TODO: 组件增加选中序列号方法
// TODO: 组件增加选中代理
// TODO: stackLayoutView 双向绑定

class MBGroupSelectionControlTests: XCTestCase {

    func testMinimumSelectCount() {
        let control = MBGroupSelectionControl()
        control.controls = [UIButton(), UIButton(), UIButton()]
        control.minimumSelectCount = 2

        // Selecting less than minimumSelectCount should not work
        control.controls[0].isSelected = true
        control.controls[1].isSelected = false
        control.controls[2].isSelected = false
        XCTAssertEqual(control.selectedControls.count, 1)

        // Selecting exactly minimumSelectCount should work
        control.controls[0].isSelected = true
        control.controls[1].isSelected = true
        control.controls[2].isSelected = false
        XCTAssertEqual(control.selectedControls.count, 2)

        // Selecting more than minimumSelectCount should work
        control.controls[0].isSelected = true
        control.controls[1].isSelected = true
        control.controls[2].isSelected = true
        XCTAssertEqual(control.selectedControls.count, 3)
    }

    func testMaximumSelectCount() {
        let control = MBGroupSelectionControl()
        control.controls = [UIButton(), UIButton(), UIButton()]
        control.maximumSelectCount = 2

        // Selecting more than maximumSelectCount should not work
        control.controls[0].isSelected = true
        control.controls[1].isSelected = true
        control.controls[2].isSelected = true
        XCTAssertEqual(control.selectedControls.count, 2)

        // Deselecting to maximumSelectCount should work
        control.controls[0].isSelected = true
        control.controls[1].isSelected = true
        control.controls[2].isSelected = false
        XCTAssertEqual(control.selectedControls.count, 2)

        // Selecting less than maximumSelectCount should work
        control.controls[0].isSelected = true
        control.controls[1].isSelected = false
        control.controls[2].isSelected = false
        XCTAssertEqual(control.selectedControls.count, 1)
    }

    func testSingleSelect() {
        let control = MBGroupSelectionControl()
        control.controls = [UIButton(), UIButton(), UIButton()]
        control.maximumSelectCount = 1

        // Selecting one button should deselect the others
        control.controls[0].isSelected = true
        XCTAssertEqual(control.selectedControls.count, 1)
        XCTAssertEqual(control.selectedControls[0], control.controls[0])

        control.controls[1].isSelected = true
        XCTAssertEqual(control.selectedControls.count, 1)
        XCTAssertEqual(control.selectedControls[0], control.controls[1])

        control.controls[2].isSelected = true
        XCTAssertEqual(control.selectedControls.count, 1)
        XCTAssertEqual(control.selectedControls[0], control.controls[2])
    }

    func testSelectedTags() {
        let control = MBGroupSelectionControl()
        control.controls = [UIButton(), UIButton(), UIButton()]

        control.controls[0].tag = 1
        control.controls[1].tag = 2
        control.controls[2].tag = 3

        control.controls[0].isSelected = true
        control.controls[2].isSelected = true

        XCTAssertEqual(control.selectedTags, [1, 3])
    }
}
