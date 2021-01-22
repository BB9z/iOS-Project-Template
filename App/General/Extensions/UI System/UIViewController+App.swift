/*
 应用级别的便捷方法: View Controller 扩展
 */
extension UIViewController {

    /// 用系统弹窗提示一段信息
    func alert(title: String?, message: String?, buttonTitle: String = "知道了") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: nil))
        rfPresent(alert, animated: true, completion: nil)
    }

    /// 用系统弹窗提示权限方面的问题，用户可选择跳转到应用设置
    func permissionPrompt(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "去设置", style: .default, handler: { _ in
            UIApplication.openSettings()
        }))
        rfPresent(alert, animated: true, completion: nil)
    }
}
