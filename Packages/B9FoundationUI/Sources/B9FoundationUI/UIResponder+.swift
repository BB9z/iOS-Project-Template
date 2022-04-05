
import UIKit

public extension UIResponder {
    /**
     Returns the nearest view controller to the receiver in the responder chain.

     返回响应者链中最接近的 view controller
     */
    @objc var viewController: UIViewController? {
        next(type: UIViewController.self)
    }

    /**
     Traverse the responder chain to find the first object of the specified type in it.

     遍历响应者链，从中查找第一个给定类型的对象。

     - Returns: The nearest specified type responser to the receiver, returns nil if not found.
        最接近接受者的指定类型对象，找不到返回 nil
     */
    func next<T>(type: T.Type) -> T? {
        var responder = self
        while let next = responder.next {
            if let result = next as? T {
                return result
            }
            responder = next
        }
        return nil
    }
}
