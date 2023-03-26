/*
 搜索高亮支持
 */

import B9AssociatedObject

/**
 添加到 model 上支持搜索高亮

 基于 NSObject 的对象有自动生成，只需要声明协议即可
 */
protocol EntitySearchHighlight: AnyObject {
    /// 当前的搜索关键字
    var searchingKeyword: String? { get set }
}

private let association = AssociatedObject<String>()
extension EntitySearchHighlight where Self: NSObject {
    var searchingKeyword: String? {
        get { association[self] }
        set { association[self] = newValue }
    }
}

extension UILabel {
    /// 设置文本，高亮第一个搜索词
    func setText(_ text: String?, searchingKeyword: String?) {
        guard let aText = text,
            let keyword = searchingKeyword?.trimmed(),
            let range = aText.range(of: keyword, options: .caseInsensitive, range: nil, locale: nil) else {
            self.text = text
            return
        }
        let atts = NSMutableAttributedString(string: aText)
        let nsRange = NSRange(range, in: aText)
        let highlightColor = window?.tintColor ?? UIColor(named: "primary")!
        atts.setAttributes([.foregroundColor: highlightColor], range: nsRange)
        attributedText = atts
    }
}
