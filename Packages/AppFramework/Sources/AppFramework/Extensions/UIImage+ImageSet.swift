/*!
 UIImage+ImageSet
 AppFramework

 Copyright © 2018, 2023 BB9z.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(UIKit)
import UIKit

public extension UIImage {

    /**
     根据标识符取一套图中的相应图片

     有些地方的图是从一套图中根据不同的状态用对应的图，传统做法是写一个 switch 取不同的图片，
     这样的缺点是修改不便，加一个图可能要改多处，容易遗漏。

     可以——直接把标识作为图片名的一部分，约定图片命名为：SETNAME_IDENTIFIER

     集合名加 zs 前缀一是便于识别这是一套图，二是可以保证在搜索时结果准确。

     - Parameters:
     - setName: 集合名，需要以 zs_ 开头
     - identifier: 图片标识符，会转为 "_identifier" 拼在集合名后作为整体的图片名，一般传数字、字符串或 enum
     - bundle: 包含图片的包，默认加载主应用包的
     */
    convenience init?(setName: String, identifier: CustomStringConvertible, in bundle: Bundle = .main) {
        guard setName.hasPrefix("zs_") else {
            MBAssert(false, "集合名请加 zs 前缀")
            return nil
        }
        let fullName = "\(setName)_\(identifier.description)"
        var success = false
        defer {
            MBAssert(success, "找不到名为 \(fullName) 的图片")
        }
        self.init(named: fullName, in: bundle, compatibleWith: nil)
        success = true
    }
}

#endif // End: UIKit
