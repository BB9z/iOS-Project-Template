/**
 应用级别的 text field 定制
 */

/**
 定义样式名

 一般在 Interface Builder 中通过 styleName 设置
 */
enum TextFieldStyle: String {
    case std
    case frame
}

enum TextFieldContentType: String {
    case mobile     // 手机号
    case code       // 验证码
    case password   // 密码，不验证长度，只验证非空
    case password2  // 密码验证，严格验证
    case userName   // 用户名
    case email      // 电子邮箱
    case name       // 姓名
    case required   // 非空，为空时用 placeholder 提示
}

class TextField: MBTextField {
    override func setupAppearance() {
        guard let style = styleName else {
            return
        }
        switch TextFieldStyle(rawValue: style) {
        case .std:
            break

        case .frame:
            var inset = UIEdgeInsets.zero
            if let aView = leftAccessoryView {
                let ivFrame = convert(aView.bounds, to: self)
                inset.left = ivFrame.maxX + 14
            }
            textEdgeInsets = inset

            backgroundImage = #imageLiteral(resourceName: "text_field_bg_normal")
            backgroundHighlightedImage = #imageLiteral(resourceName: "text_field_bg_focused")
            disabledBackground = #imageLiteral(resourceName: "text_field_bg_disabled")

        case .none:
            assert(false, "TextField: unrecognized style \(style)")
        }
    }

    override var formContentType: String? {
        didSet {
            guard let type = TextFieldContentType(rawValue: formContentType ?? "") else {
                return
            }
            if textContentType == nil {
                textContentType = textContentType(for: type)
            }
            switch type {
            case .mobile:
                keyboardType = .phonePad
            case .code:
                keyboardType = .numberPad
            case .userName:
                keyboardType = .namePhonePad
            case .email:
                keyboardType = .emailAddress
            case .name:
                keyboardType = .default
            default:
                break
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func textContentType(for type: TextFieldContentType) -> UITextContentType? {
        switch type {
        case .mobile:
            return .telephoneNumber
        case .password:
           if #available(iOS 12.0, *) {
               if (nextField as? TextField)?.formContentType == TextFieldContentType.password2.rawValue {
                   return .newPassword
               }
           } else {
               return .password
           }
        case .password2:
            if #available(iOS 12.0, *) {
                return .newPassword
            } else {
                return .password
            }
        case .code:
            if #available(iOS 12.0, *) {
                return .oneTimeCode
            }
        case .userName:
            return .username
        case .email:
            return .emailAddress
        case .name:
            return .name
        case .required:
            break
        }
        return nil
    }

    override var isFieldVaild: Bool {
        let vtext = _vaildFieldText().0
        return vtext?.isNotEmpty == true
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func _vaildFieldText() -> (String?, String?) {
        guard let type = TextFieldContentType(rawValue: formContentType ?? "") else {
            return (text, nil)
        }
        switch type {
        case .mobile:
            guard let str = text?.trimmed() else {
                return (nil, emptyPromoteText ?? "请输入手机号")
            }
            guard str.isValidPhoneNumber else {
                return (nil, "手机号格式错误")
            }
            return (str, nil)
        case .code:
            guard let str = text?.trimmed() else {
                return (nil, emptyPromoteText ?? "请输入验证码")
            }
            return (str, nil)
        case .password:
            guard let str = text, str.isNotEmpty else {
                return (nil, emptyPromoteText ?? "请输入密码")
            }
            if let nextInput = nextField as? MBTextField,
                nextInput.formContentType == TextFieldContentType.password2.rawValue {
                // 下个输入框是密码验证
                if nextInput.text?.isNotEmpty == true
                    && nextInput.text != str {
                    return (nil, "两次密码输入不一致")
                }
            }
            return (str, nil)
        case .password2:
            guard let str = text, str.isNotEmpty else {
                return (nil, emptyPromoteText ?? "请输入确认密码")
            }
            guard str.count >= 8 else {
                return (nil, "密码长度至少8位")
            }
            guard str.count <= 30 else {
                return (nil, "密码长度不能超过30位")
            }
            return (str, nil)
        case .userName:
            guard let str = text, str.isNotEmpty else {
                return (nil, emptyPromoteText ?? "请输入用户名")
            }
            return (str, nil)
        case .email:
            guard let str = text?.trimmed() else {
                return (nil, emptyPromoteText ?? "请输入邮箱")
            }
            guard str.isValidEmail else {
                return (nil, "邮箱格式错误")
            }
            return (str, nil)
        case .name:
            guard let str = text, str.isNotEmpty else {
                return (nil, emptyPromoteText ?? "请输入姓名")
            }
            return (str, nil)
        case .required:
            guard let str = text?.trimmed(), str.isNotEmpty else {
                return (nil, emptyPromoteText ?? placeholder)
            }
            return (str, nil)
        } // END: switch
    }
    /// 输入为空时验证弹窗的提醒文本
    @IBInspectable var emptyPromoteText: String?

    /// 自动验证、提示并返回合法值
    ///
    /// - Parameters:
    ///   - noticeWhenInvalid: 内容非法时弹出报错提示
    ///   - becomeFirstResponderWhenInvalid: 内容非法时获取键盘焦点
    /// - Returns: 合法值
    func vaildFieldText(noticeWhenInvalid: Bool = true, becomeFirstResponderWhenInvalid: Bool = true) -> String? {
        let (vaildText, errorMessage) = _vaildFieldText()
        if let e = errorMessage {
            if noticeWhenInvalid {
                AppHUD().showErrorStatus(e)
            }
            if becomeFirstResponderWhenInvalid {
                becomeFirstResponder()
            }
        }
        return vaildText
    }

    override var iconImageView: UIImageView? {
        didSet {
            if let iconView = iconImageView {
                let ivFrame = iconView.convert(iconView.bounds, to: self)
                var inset = textEdgeInsets
                inset.left = ivFrame.maxX + 14
                textEdgeInsets = inset
            }
        }
    }

    @IBOutlet var leftAccessoryView: UIView? {
        didSet {
            leftView = leftAccessoryView
            leftViewMode = .always
            if let aView = leftAccessoryView {
                let ivFrame = convert(aView.bounds, to: self)
                var inset = textEdgeInsets
                inset.left = ivFrame.maxX + 14
                textEdgeInsets = inset
            }
        }
    }
}
