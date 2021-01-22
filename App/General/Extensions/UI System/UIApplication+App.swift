/*
 应用级别的便捷方法: UIApplication 扩展
 */
extension UIApplication {

    /// 打开应用设置
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
