/*!
 MBNavigationController
 MBAppKit

 Copyright © 2018-2020, 2022 RFUI.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
import B9AssociatedObject
import UIKit

/**
 根导航控制器
 */
class MBNavigationController: RFNavigationController {

    /// 隐藏导航阴影
    ///
    /// view 已加载后设置无效，iOS 10 以下会修改 bar 的 background image
    @IBInspectable var prefersNoBarShadow: Bool = false

    /// 隐藏导航返回按钮的文字
    ///
    /// 在 didShowViewController 中设置当前 vc 的返回按钮
    @IBInspectable var prefersBackBarButtonTitleHidden: Bool = false

    /// 当 vc 加入到导航堆栈后执行，定制 navigationItem 样式
    ///
    /// 默认实现应用返回按钮标题是否隐藏的设置
    func customNavigationItem(for viewController: UIViewController) {
        if prefersBackBarButtonTitleHidden && viewController.navigationItem.backBarButtonItem == nil {
            if #available(iOS 14.0, *) {
                viewController.navigationItem.backButtonDisplayMode = .minimal
            } else {
                viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }

    /// 导航弹框操作队列
    private(set) var operationQueue: [MBNavigationOperation] = []

    /// 尝试立即处理导航队列
    func setNeedsPerformNavigationOperation() {
        guard !operationQueue.isEmpty, shouldPerfromQunedQperation else {
            return
        }

        if let perfromedOp = perfromedNavigationOperation() {
            operationQueue.removeAll { $0 === perfromedOp }
        }
    }

    /// 可以执行低优先级的导航操作
    var shouldPerfromQunedQperation: Bool {
        if transitionCoordinator != nil {
            return false
        }
        if presentedViewController != nil {
            return false
        }
//        if UIResponder.firstResponder != nil {
//            return false
//        }
        if topViewController is UIViewControllerIsFlowScence {
            return false
        }
        return true
    }

    func perfromedNavigationOperation() -> MBNavigationOperation? {
        var performedOp: MBNavigationOperation?
        var needsRemovedOps: [MBNavigationOperation] = []
        for op in operationQueue {
            if let topVCClasses = op.topViewControllers, !topVCClasses.contains(where: { $0 == topViewController?.classForCoder }) {
                continue
            }
            if op.perform(self) {
                performedOp = op
                break
            } else {
                needsRemovedOps.append(op)
            }
        }
        if !needsRemovedOps.isEmpty {
            // TODO: Restore
//            operationQueue.removeAll { needsRemovedOps.contains($0) }
        }
        return performedOp
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if prefersNoBarShadow {
            hideShadow()
        }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if AccountManager.current == nil && viewController.MBUserLoginRequired {
            loginSuspendedViewController = viewController
            _MBNavigationController_tryLogin()
            return
        }
        super.pushViewController(viewController, animated: animated)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if let lastVC = viewControllers.last, AccountManager.current == nil && lastVC.MBUserLoginRequired {
            loginSuspendedViewController = lastVC
            var vcs = viewControllers
            vcs.removeLast()
            super.setViewControllers(vcs, animated: animated)
            _MBNavigationController_tryLogin()
            return
        }
        super.setViewControllers(viewControllers, animated: animated)
    }

    override func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)
        customNavigationItem(for: viewController)
        if let loginSuspendedViewController = loginSuspendedViewController, AccountManager.current != nil {
            if _MBNavigationController_loginSuspendedVCKeeper === topViewController {
                pushViewController(loginSuspendedViewController, animated: true)
            }
            self.loginSuspendedViewController = nil
            _MBNavigationController_loginSuspendedVCKeeper = nil
        }
        changeNavigationStack { [weak self] _ in
            self?.setNeedsPerformNavigationOperation()
        }
    }

    private func hideShadow() {
        navigationBar.shadowImage = UIImage()
    }

    private var _MBNavigationController_loginSuspendedVCKeeper: UIViewController?
    private var _MBNavigationController_lastViewControllers: [UIViewController] = []

    private func _MBNavigationController_tryLogin() {
        if AccountManager.current != nil {
            return
        }
        _MBNavigationController_loginSuspendedVCKeeper = topViewController
        presentLoginScene()
        if _MBNavigationController_loginSuspendedVCKeeper === topViewController {
            _MBNavigationController_loginSuspendedVCKeeper = nil
            loginSuspendedViewController = nil
        }
    }

    /**
     修改导航堆栈时，如果将要显示的 vc 声明需要登入且用户未登入，
     会把这个 vc 保存起来，供登入成功后还原跳转

     如果业务上不需要还原跳转，可在登入时手动置空该属性；
     登入后 pop 回发起登入的页面才会执行还原，如果有跳转到其他页面不进行操作

     完整的示例参考：
     https://github.com/BB9z/iOS-Project-Template/tree/demo/Demos/GuestMode
     */
    var loginSuspendedViewController: UIViewController? = nil

    /**
     根据业务需求展示登入页面

     需要子类重写，默认什么也不做
     */
    func presentLoginScene() {
        // for overwrite
    }
}

// MARK: - 堆栈管理

/**
 用于标记视图属于一个流程，
 处于流程中时，通过导航的弹窗和部分跳转将不会执行
 */
protocol UIViewControllerIsFlowScence: UIViewController {}

extension MBNavigationController {

    /**
     有 view controller 被添加到导航堆栈中调用

     默认实现会设置这些 view controller 的返回按钮
     */
    func didAddViewControllers(_ vcs: [UIViewController]) {
        vcs.forEach(customNavigationItem)
    }

    /**
     有 view controller 从导航堆栈中移除时调用

     默认实现会把这些 view controller 相关联的 API 请求取消
     */
    func didRemoveViewControllers(_ vcs: [UIViewController]) {
        vcs.forEach(MBAPI.cancelOperations)
    }

    /**
     便于在 IB 中调用 popViewControllerAnimated()
     */
    @IBAction func navigationPop(_ sender: Any?) {
        popViewController(animated: true)
    }

    /**
     导航堆栈正在修改时再尝试变更堆栈，操作可能会失败。用这个方法会在转场动画结束后再执行变更操作

     注意这个方法不防 block 中有连续操作，嵌套执行 changeNavigationStack: 也会失败。
     */
    func changeNavigationStack(_ block: @escaping (MBNavigationController) -> Void) {
        let co = transitionCoordinator
        if co == nil {
            block(self)
        } else {
            co?.animate(alongsideTransition: nil) { _ in
                block(self)
            }
        }
    }

    /**
     从栈顶依次弹出符合给定协议声明的视图，直到一个不是的
     */
    func popViewControllersOfScence(_ aProtocol: Protocol, animated: Bool) {
        var vc: UIViewController?
        for obj in viewControllers.reversed() where !obj.conforms(to: aProtocol) {
            vc = obj
            break
        }
        if let vc = vc {
            popToViewController(vc, animated: animated)
        }
    }

    /**
     把导航堆栈顶部符合给定协议声明的视图用新 viewController 替换掉

     典型场景是完成流程后需要用结果页把之前一系列页面替换掉
     */
    func replaceViewControllersOfScence(_ aProtocol: Protocol, with viewController: UIViewController, animated: Bool) {
        var vcs = viewControllers
        while vcs.last?.conforms(to: aProtocol) == true {
            vcs.removeLast()
        }
        vcs.append(viewController)
        setViewControllers(vcs, animated: animated)
    }
}

// MARK: - 基于每个页面的登入控制

extension UIViewController {
    /// 标记这个 vc 需要登录才能查看
    @IBInspectable var MBUserLoginRequired: Bool {
        get { vcLoginRequiredAssociation[self] ?? false }
        set { vcLoginRequiredAssociation[self] = newValue}
    }
}
private let vcLoginRequiredAssociation = AssociatedObject<Bool>()

private let loginSuspendedAssociation = AssociatedObject<UIViewController>()


/**
 导航 push 需要登入查看的页面时已自动处理。
 当一个操作需要登入时，可以先调用这个方法手动检查，并在需要时显示登入界面

 - Returns: 已登入返回 false，未登入返回 true
 */
func MBOperationLoginRequired() -> Bool {
    if AccountManager.current != nil {
        return false
    }
    // TODO: 共享实例
//    AppNavigationController()._MBNavigationController_tryLogin()
    return true
}

// TODO: validate 机制是否需要恢复
/// 导航执行队列
protocol MBNavigationOperation: AnyObject {
    var animating: Bool { get }

    /// 用于限制导航操作只可在特定页面弹出
    var topViewControllers: [AnyClass]? { get }

    /// @return 操作是否被实际执行了
    func perform(_ controller: MBNavigationController) -> Bool
}

extension MBNavigationOperation {
    var animating: Bool { true }

    func validateConfiguration() -> Bool { true }
}

class MBPopNavigationOperation: MBNavigationOperation {
    var animating = false
    var topViewControllers: [AnyClass]?

    func perform(_ controller: MBNavigationController) -> Bool {
        controller.popViewController(animated: animating)
        return true
    }
}

/// 弹出一个 UIAlertController
class MBAlertNavigationOperation: MBNavigationOperation {
    var animating = false
    var topViewControllers: [AnyClass]?
    var alertController: UIAlertController?

    func validateConfiguration() -> Bool {
        return alertController != nil
    }

    func perform(_ controller: MBNavigationController) -> Bool {
        controller.present(alertController!, animated: animating, completion: nil)
        return true
    }
}
