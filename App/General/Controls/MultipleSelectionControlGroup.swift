/*
 MultipleSelectionControlGroup.swift

 Copyright © 2021 BB9z
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/**
 MBControlGroup 的 Swift 简化版
 */
class MultipleSelectionControlGroup: UIControl {
    @IBInspectable var minimumSelectCount: Int = 1
    @IBInspectable var maximumSelectCount: Int = 0
    /// 延迟选中变化事件的发送，避免连续选择发送多个无意义变更
    @IBInspectable var valueChangedActionDelay: Double = 0

    @IBOutlet var controls: [UIControl] = [UIControl]() {
        didSet {
            controls.forEach(setupAction(control:))
        }
    }

    @IBOutlet weak var stackLayoutView: UIStackView?

    override func awakeFromNib() {
        super.awakeFromNib()
        if controls.isEmpty {
            let viewsToFind = stackLayoutView?.arrangedSubviews ?? subviews
            controls = viewsToFind.compactMap { $0 as? UIControl }
        }
    }

    private func setupAction(control: UIControl) {
        let action = #selector(onSubControlTapped(sender:))
        let actionString = NSStringFromSelector(action)
        if nil != control.actions(forTarget: self, forControlEvent: .touchUpInside)?.first(where: { $0 == actionString }) {
            return
        }
        control.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc func onSubControlTapped(sender: UIControl) {
        if sender.isSelected && selectedControls.count <= minimumSelectCount {
            return
        }
        if maximumSelectCount == 1 {
            // 单选模式
            controls.forEach { ctr in
                if ctr.isSelected, ctr != sender { ctr.isSelected.toggle() }
            }
            // continue
        } else if maximumSelectCount > 1 {
            if !sender.isSelected && selectedControls.count >= maximumSelectCount {
                return
            }
        }
        sender.isSelected.toggle()
        if valueChangedActionDelay > 0 {
            needsSendValueChangedAction = true
        } else {
            sendActions(for: .valueChanged)
        }
    }

    private var needsSendValueChangedAction = false {
        didSet {
            if needsSendValueChangedAction {
                let work = DispatchWorkItem { [weak self] in
                    self?.doSendValueChangedAction()
                }
                sendValueChangedActionWork = work
            }
        }
    }
    private var sendValueChangedActionWork: DispatchWorkItem? {
        didSet {
            if let old = oldValue {
                old.cancel()
            }
            if let new = sendValueChangedActionWork {
                DispatchQueue.main.asyncAfter(deadline: .now() + valueChangedActionDelay, execute: new)
            }
        }
    }
    private func doSendValueChangedAction() {
        if !needsSendValueChangedAction { return }
        needsSendValueChangedAction = false
        sendActions(for: .valueChanged)
    }

    var selectedControls: [UIControl] {
        controls.filter { $0.isSelected }
    }
    /// 选中控件的 tag 集合，已去重并排序
    var selectedTags: [Int] {
        selectedControls.map { $0.tag }.uniqued().sorted()
    }
}
