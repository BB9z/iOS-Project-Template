/*!
 MBTextField
 MBAppKit

 Copyright © 2018, 2021, 2023 BB9z.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

import AppFramework
import B9Foundation
import UIKit

/**
 TextField 封装

 特性：

 - placeholder 样式调整
 - 调整了 TextField 的默认高度
 - 通过 textEdgeInsets 属性，可以修改文字与边框的距离
 - 获得焦点后自动设置高亮背景
 - 编辑内容自动同步到 vc 的 item
 - 用户按换行可以自动切换到下一个输入框或执行按钮操作，只需设置 nextField 属性，键盘的 returnKeyType 如果是默认值则还会自动修改
 - 可以限制用户输入长度，超出限制长度表现为不可增加字符

 注意：

 - 原生的 borderStyle 属性会在初始化之后被重新设定为 UITextBorderStyleNone 以便定义外观

 */
class MBTextField: UITextField, RFInitializing {
    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
        DispatchQueue.main.async { [weak self] in
            self?.afterInit()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        onInit()
        DispatchQueue.main.async { [weak self] in
            self?.afterInit()
        }
    }

    func onInit() {
        super.delegate = trueDelegate
    }

    func afterInit() {
        // 修改 place holder 文字样式
        if let placeholder = placeholder {
            self.placeholder = placeholder
        }

        if returnKeyType == .default && nextField != nil {
            _setupReturnKeyType()
        }

        addTarget(self, action: #selector(updateUIForTextChanged), for: .editingChanged)
        _setupAppearance()

        if backgroundHighlightedImage != nil {
            MBTextField_updateBackgroundForHighlighted(isFirstResponder)
        }
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        _setupAppearance()

        if let formItemKey = formItemKey {
            if let vc = next(type: UIViewController.self) as? AnyHasItem,
               let item: AnyObject = vc.item(){
                if newWindow != nil {
                    if let v = item.value(forKey: formItemKey) {
                        text = v as? String
                    }
                } else {
                    item.setValue(text, forKey: formItemKey)
                }
            }
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && autoBecomeFirstResponder {
            _ = becomeFirstResponder()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // 焦点自动设置
        if backgroundHighlightedImage != nil {
            if backgroundImage == nil {
                backgroundImage = background
            }
            borderStyle = .none
        }
        _setupAppearance()
    }

    // MARK: - 外观

    /**
     样式名，以便让同一个按钮类支持多个样式

     一般在 setupAppearance 根据 styleName 做相应配置
     */
    @IBInspectable var styleName: String?
    @IBInspectable var skipAppearanceSetup: Bool = false
    private(set) var appearanceSetupDone = false

    func setupAppearance() {
        // for overwrite
    }

    /// 文字与边框的边距
    var textEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)

    /// 非空时，text filed 获取/失去键盘焦点时会在 backgroundHighlightedImage 和 backgroundImage 之间切换
    var backgroundHighlightedImage: UIImage?

    /// 默认背景图，从 nib 载入时如果 backgroundHighlightedImage 非空，会自动拷贝 background 的属性
    var backgroundImage: UIImage? {
        didSet {
            if let backgroundHighlightedImage = backgroundHighlightedImage, let backgroundImage = backgroundImage {
                background = isFirstResponder ? backgroundHighlightedImage : backgroundImage
            }
        }
    }

    /**
     文字变更时调用

     用户通过键盘改变文字时会自动调用，程序通过 setText: 需要手动调用以便更新 UI
     */
    @objc func updateUIForTextChanged() {
        _onTextFieldChanged(self)
    }

    // MARK: - 附加 view

    /// 内容非空时设置状态为 highlighted
    @IBOutlet weak var iconImageView: UIImageView?

    /// 文字非空时显示的 view，布局交给外部，text field 不进行管理
    @IBOutlet weak var contentAccessoryView: UIView?

    // MARK: - 表单

    /// 在添加到 window 时自动获取键盘
    @IBInspectable var autoBecomeFirstResponder: Bool = false

    /// 供子类重载，内容类型，可用于验证和配置
    @IBInspectable var formContentType: String?

    /**
     若非空，在 textFieldDidEndEditing: 时尝试用 KVO 修改其 view controller 中 item 对应属性

     @warning 如果点按按钮时没有显示取消焦点，此时 textFieldDidEndEditing 尚未出发因而数据是不全的
     */
    @IBInspectable var formItemKey: String?

    /// 按键盘上的 return 需跳转到的控件
    @IBOutlet weak var nextField: AnyObject?

    // MARK: - 验证

    /// 供子类重载，判断输入是否正确，默认 YES
    var isFieldVaild: Bool {
        return true
    }

    /// 限制最大输入长度
    @IBInspectable var maxLength: UInt = 0

    // MARK: - 修改 place holder 文字样式

    var placeholderTextAttributes: [NSAttributedString.Key: Any]?

    override var placeholder: String? {
        didSet {
            if let placeholderTextAttributes = placeholderTextAttributes {
                attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: placeholderTextAttributes)
            } else {
                super.placeholder = placeholder
            }
        }
    }

    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            if let attributedPlaceholder = attributedPlaceholder {
                super.attributedPlaceholder = attributedPlaceholder
            }
        }
    }

    // 修改默认文字框最低高度
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = max(size.height, 36)
        return size
    }

    // MARK: - 文字距边框设定

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textEdgeInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    // MARK: - 获取焦点自动高亮

    override func becomeFirstResponder() -> Bool {
        let can = super.becomeFirstResponder()
        if can {
            MBTextField_updateBackgroundForHighlighted(true)
        }
        return can
    }

    override func resignFirstResponder() -> Bool {
        let can = super.resignFirstResponder()
        if can {
            MBTextField_updateBackgroundForHighlighted(false)
        }
        return can
    }

    private func MBTextField_updateBackgroundForHighlighted(_ highlighted: Bool) {
        guard let backgroundHighlightedImage = backgroundHighlightedImage else { return }
        background = highlighted ? backgroundHighlightedImage : backgroundImage
    }

    // MARK: - Delegate

    override var delegate: UITextFieldDelegate? {
        get { return trueDelegate.delegate }
        set {
            if newValue !== trueDelegate.delegate {
                trueDelegate.delegate = newValue
                super.delegate = trueDelegate
            }
        }
    }

    private lazy var trueDelegate: UITextFiledDelegateChain = {
        let delegate = UITextFiledDelegateChain()
        delegate.shouldReturn = { [weak self] textField, delegate in
            return self?._shouldReturn(textField, delegate) ?? true
        }
        delegate.didEndEditing = { [weak self] textField, delegate in
            self?._didEndEditing(textField, delegate)
        }
        delegate.shouldChangeCharacters = { [weak self] textField, range, replacementString, delegate in
            return self?._shouldChangeCharacters(textField, range, replacementString, delegate) ?? true
        }
        return delegate
    }()
}

extension MBTextField {
    private func _setupAppearance() {
        if appearanceSetupDone { return }
        appearanceSetupDone = true
        if !skipAppearanceSetup {
            setupAppearance()
        }
        updateUIForTextChanged()
    }

    @IBInspectable var _textEdgeInsets: CGRect {
        get {
            return NSValue(uiEdgeInsets: textEdgeInsets).cgRectValue
        }
        set {
            textEdgeInsets = NSValue(cgRect: newValue).uiEdgeInsetsValue
        }
    }

    private func _didEndEditing(_ textField: UITextField, _ delegate: UITextFieldDelegate?) {
        if let textField = textField as? MBTextField, let formItemKey = textField.formItemKey {
            if let vc = textField.next(type: UIViewController.self) as? AnyHasItem,
               let item: AnyObject = vc.item() {
                item.setValue(textField.text, forKey: formItemKey)
            }
        }
        delegate?.textFieldDidEndEditing?(textField)
    }

    private func _setupReturnKeyType() {
        if nextField is UITextField || nextField is UITextView {
            returnKeyType = .next
        } else if nextField is UIBarButtonItem {
            returnKeyType = .done
        } else {
            returnKeyType = .send
        }
    }

    private func _shouldReturn(_ textField: UITextField, _ delegate: UITextFieldDelegate?) -> Bool {
        if let delegate = delegate, delegate.textFieldShouldReturn?(textField) == false {
            return false
        }

        if let textField = textField as? MBTextField, let nextField = textField.nextField {
            if let next = nextField as? UIControl, next.isEnabled {
                _ = textField.resignFirstResponder()
                next.sendActions(for: .touchUpInside)
            }

            if let next = nextField as? UIBarButtonItem, next.isEnabled {
                _ = textField.resignFirstResponder()
                if let action = next.action {
                    UIApplication.shared.sendAction(action, to: next.target, from: next, for: nil)
                }
            }

            if let next = nextField as? UIResponder, next.canBecomeFirstResponder {
                next.becomeFirstResponder()
            }
        }

        return true
    }

    private func _onTextFieldChanged(_ textField: UITextField) {
        if let iconImageView = iconImageView {
            var on = textField.text?.isEmpty == false
            if !isFieldVaild {
                on = false
            }
            iconImageView.isHighlighted = on
        }

        contentAccessoryView?.isHidden = textField.text?.isEmpty == true

        guard maxLength > 0 else { return }

        // Skip multistage text input
        guard textField.markedTextRange == nil else { return }

        if let text = textField.text, text.count > maxLength {
            let endIndex = text.index(text.startIndex, offsetBy: Int(maxLength))
            textField.text = String(text[..<endIndex])
        }
    }

    private func _shouldChangeCharacters(_ textField: UITextField, _ range: NSRange, _ replacementString: String, _ delegate: UITextFieldDelegate?) -> Bool {
        if maxLength > 0 {
            // Needs limit length, skip multistage text input
            if range.length == 0 && textField.markedTextRange == nil {
                if replacementString.count + (textField.text?.count ?? 0) > maxLength {
                    return false
                }
            }
        }

        return delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: replacementString) ?? true
    }
}
