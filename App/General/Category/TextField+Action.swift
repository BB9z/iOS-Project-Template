/**
 UITextField 操作扩展
 
 一般 text field 两边根据需求不同可能会附加一些按钮，比如自定义外观的 x，密码切换的按钮，建议的做法是：
 
 使用 MBTextField 的 contentAccessoryView 或 UITextField 本身的 leftView、rightView 添加额外的按钮，这些按钮可以直接连接下面的操作。
 */
extension UITextField {
    /// 清空输入框
    @IBAction func clearText(_ sender: Any?) {
        text = nil
        sendActions(for: .editingChanged)
    }
    
    /// 切换密码显示
    @IBAction func togglePasswordDisplay(_ sender: Any?) {
        isSecureTextEntry = !isSecureTextEntry
        if let c = sender as? UIControl {
            c.isSelected = !isSecureTextEntry
        }
        
        // 修正模式切换改变后，光标的位置
        if (isFirstResponder) {
            let text = self.text
            let orgRange = selectedTextRange
            resignFirstResponder()
            becomeFirstResponder()
            self.text = text
            selectedTextRange = orgRange;
        }
    }
}