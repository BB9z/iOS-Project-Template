//
//  StoryboardCreation.swift
//  App
//

/// storyboard 定义
enum StoryboardID: String {
    case main = "Main"
    case picker = "Picker"
    case login = "Login"
    case topic = "Topic"
}

/**
 通过 storyboard 创建 view controller 实例

 使用：
 ```

 ```

 */
protocol StoryboardCreation: UIViewController {
    /// 从 storyboard 种创建实例
    static func newFromStoryboard() -> Self

    /// 指定 view controller 所在 storyboard
    static var storyboardID: StoryboardID { get }

    /// 指定 view controller 在 storyboard 中的标识符
    static var identifierInStroyboard: String { get }
}

extension StoryboardCreation {
    static func newFromStoryboard() -> Self {
        let board = UIStoryboard(name: storyboardID.rawValue, bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: identifierInStroyboard)
        // 这里不能用 as? 进行转换，否则带泛型的类会失败
        return vc as! Self  // swiftlint:disable:this force_cast
    }

    static var identifierInStroyboard: String {
        // String(self) 并不够，当 vc 带泛型声明时需要去掉泛型部分的字符
        MBSwift.typeName(self)
    }
}

/// OC 环境支持
extension UIViewController {

    /**
     从指定 storyboard 中创建实例

     - Parameters:
        - storyboardName: 文件名
        - identifier: view controller 在 storyboard 中的标识符，可传空用类名
     */
    @objc class func new(storyboardName: String, identifier: String? = nil) -> Self {
        let board = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: identifier ?? MBSwift.typeName(self))
        // 这里不能用 as? 进行转换，否则带泛型的类会失败
        return vc as! Self  // swiftlint:disable:this force_cast
    }
}
