/*
应用级别的便捷方法
*/

/// 输入框是 TextField 下的增强
extension MBFormFieldVerifyControl {

    /// 给 invalidSubmitButton 添加点击事件，不通过时自动提示
    @IBInspectable var addInvalidAction: Bool {
        get {
            fatalError("addInvalidAction getter unavailable.")
        }
        set {
            guard newValue else { return }
            // 延时，等相关属性全部从 nib 中载入
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let sf = self else { return }
                guard let button = sf.invalidSubmitButton else {
                    NSLog("❌ MBFormFieldVerifyControl: invalidSubmitButton not set.")
                    return
                }
                if let control = button as? UIControl {
                    control.addTarget(sf, action: #selector(sf.onInvalidSubmit(_:)), for: .touchUpInside)
                } else if let item = button as? UIBarButtonItem {
                    item.target = sf
                    item.action = #selector(sf.onInvalidSubmit(_:))
                } else {
                    fatalError("Unexcept type.")
                }
            }
        }
    }

    @IBAction private func onInvalidSubmit(_ sender: Any) {
        noticeIfInvalid(becomeFirstResponder: true)
    }

    /// 获取验证结果，不通过时可提示并切换焦点
    func noticeIfInvalid(becomeFirstResponder: Bool = true) {
        if isValid { return }
        guard let fields = textFields as? [TextField] else { return }
        for aField in fields {
            if validationSkipsHiddenFields && !aField.isVisible { continue }
            guard aField.vaildFieldText(noticeWhenInvalid: true, becomeFirstResponderWhenInvalid: true) != nil else {
                return
            }
        }
    }
}
