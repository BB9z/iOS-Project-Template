/*!
 MBFormFieldVerifyControl

 Copyright © 2018, 2020, 2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import UIKit

// @MBDependency:2
/**
 关联一组输入框和按钮，如果都验证通过使按钮 enable，否则 disable
 */
class MBFormFieldVerifyControl: NSObject {

    /// 需要监听的输入框
    @IBOutlet var textFields: [MBTextField] = [] {
        didSet {
            if oldValue == textFields { return }
            oldValue.forEach { $0.removeTarget(self, action: #selector(onEditingChanged), for: .editingChanged) }
            textFields.forEach { $0.addTarget(self, action: #selector(onEditingChanged), for: .editingChanged) }
            updateValidation()
        }
    }

    /// 验证跳过隐藏的输入框，默认关闭
    /// 通过 isVisible 扩展检查，应该能覆盖大部分情形
    @IBInspectable var validationSkipsHiddenFields: Bool = false

    /// 更新验证，在输入框隐藏切换时需调用
    func updateValidation() {
        updateVaild()
    }

    /// 是否通过验证
    var isValid: Bool { lastVaild ?? false }


    @objc private func onEditingChanged(_ sender: UITextField) {
        updateVaild()
    }

    private func updateVaild() {
        var v = true
        var hasViableField = false
        for field in textFields {
            if validationSkipsHiddenFields {
                if !field.isVisible { continue }
                hasViableField = true
            }
            if !field.isFieldVaild {
                v = false
                break
            }
        }
        // 从 nib 初始化时所有输入框都不可见，不能当验证通过更新
        if validationSkipsHiddenFields && !hasViableField { return }
        lastVaild = v
        (submitButton as? UIControl)?.isEnabled = v
        updateSumitButtonLink()
    }
    private var lastVaild: Bool?

    // MARK: - Buttons

    /// 正常的提交按钮
    /// UIControl 或 bar button item
    @IBOutlet weak var submitButton: AnyObject? {
        didSet {
            (submitButton as? UIControl)?.isEnabled = isValid
            updateSumitButtonLink()
        }
    }

    /**
     验证不通过时点击的按钮

     如果设置，当有输入框的 nextField 指向 submitButton 时，会更新该指向
     */
    @IBOutlet weak var invalidSubmitButton: AnyObject? {
        didSet {
            updateSumitButtonLink()
        }
    }

    private func updateSumitButtonLink() {
        guard let invalidControl = invalidSubmitButton else { return }
        let v = isValid
        textFields.forEach {
            guard let next = $0.nextField else { return }
            if next === submitButton || next === invalidControl {
                $0.nextField = v ? submitButton : invalidControl
            }
        }
    }
}
