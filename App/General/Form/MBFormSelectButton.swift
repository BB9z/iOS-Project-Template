/*
 MBFormSelectButton

 Copyright © 2018-2020, 2023 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import UIKit

/**
 有选中值的按钮，按钮文本根据选中值变化

 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
class MBFormSelectButton<ObjectType: Hashable>: MBButton {

    var selectedVaule: ObjectType? {
        didSet {
            if selectedVaule != oldValue {
                let title = displayString(with: selectedVaule)
                setTitle(title, for: .normal)
                isSelected = selectedVaule != nil
            }
        }
    }

    /// 占位符文本，默认使用 nib 中定义的 normal 文本
    @IBInspectable var placeHolder: String? {
        didSet {
            if !isSelected {
                setTitle(placeHolder, for: .normal)
            }
        }
    }

    /// 修改该属性决定如何展示数值，优先于 valueDisplayMap
    /// 未设置则显示 value 的 description
    var valueDisplayString: ((ObjectType?) -> String?)?

    /// 修改该属性决定如何展示数值
    /// 未设置则显示 value 的 description
    var valueDisplayMap: [ObjectType: String]?

    /// 决定 value 如何显示，供子类重写
    func displayString(with value: ObjectType?) -> String? {
        guard let value = value else { return placeHolder }
        if let valueDisplayString = valueDisplayString {
            return valueDisplayString(value)
        }
        if let valueDisplayMap = valueDisplayMap {
            return valueDisplayMap[value]
        }
        return "\(value)"
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = max(size.height, 36)
        return size
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if placeHolder == nil {
            placeHolder = title(for: .normal)
        }
    }
}
