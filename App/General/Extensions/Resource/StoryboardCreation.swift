//
//  StoryboardCreation.swift
//  App
//

/// storyboard 定义
/// Define storyboards
enum StoryboardID: String {
    case main = "Main"
    case picker = "Picker"
    case login = "Login"
    case topic = "Topic"
}

/**
 通过 storyboard 创建 view controller 实例
 Create view controllers from storyboard

 使用：
 ```
 // Define
 class SomeViewController: UIViewController, StoryboardCreation {
     static var storyboardID: StoryboardID { .main }
     // In storyboard, set the view controller's Identify > Storyboard ID to "SomeViewController".
     // Or provide a customized identifierInStoryboard
 }

 // Create an instance
 let ... = SomeViewController.newFromStoryboard()
 ```
 */
protocol StoryboardCreation: UIViewController {
    /// 从 storyboard 中创建实例
    /// Create an instance from storyboard
    static func newFromStoryboard() -> Self

    /// 指定 view controller 所在 storyboard
    /// Specify the storyboard where the view controller is located
    static var storyboardID: StoryboardID { get }

    /// 指定 view controller 在 storyboard 中的标识符
    /// Specify the identify of the view controller in storyboard (In Interface Builder: Identify > Storyboard ID)
    static var identifierInStoryboard: String { get }
}

extension StoryboardCreation {
    static func newFromStoryboard() -> Self {
        let board = UIStoryboard(name: storyboardID.rawValue, bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: identifierInStoryboard)
        // 这里不能用 as? 进行转换，否则带泛型的类会失败
        return vc as! Self  // swiftlint:disable:this force_cast
    }

    static var identifierInStoryboard: String {
        // String(describing:) 并不够，当 vc 带泛型声明时需要去掉泛型部分的字符
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
