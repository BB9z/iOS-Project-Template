/*
 MBModalPresentSegue

 Copyright © 2018-2021, 2023 BB9z.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

// @MBDependency:4
/**
 弹出新的视图，与 view controller 内建的弹出方式不同之处在于不会隐藏当前视图，新视图不是加在当前视图的 view 中的，而是尽可能加在根视图中，会覆盖导航条

 destinationViewController 需要符合 MBModalPresentDestination 协议
 */
class MBModalPresentSegue: UIStoryboardSegue {

    override func perform() {
        guard let parent = UIViewController.rootViewControllerWhichCanPresentModal() else {
            return
        }
        guard let vc = destination as? MBModalPresentDestination else {
            assertionFailure("\(destination) must confirms to MBModalPresentDestination.")
            return
        }
        vc.present(from: parent, animated: true, completion: nil)
    }
}

/**
 从弹出层 push 到其他视图需使用本 segue，否则可能会导致布局问题，已知的是返回后，隐藏导航栏视图布局不会上移
 */
class MBModalPresentPushSegue: UIStoryboardSegue {
    override func perform() {
        Current.navigationController?.pushViewController(destination, animated: true)
    }
}

/**
 MBModalPresentPushSegue 的 destination 只需符合该协议
 */
protocol MBModalPresentDestination: AnyObject {
    func present(from parentViewController: UIViewController?, animated: Bool, completion: (() -> Void)?)
}

// MARK: - Present ViewController

/**
 可以用 MBModalPresentPushSegue 弹出的一个实现
 */
class MBModalPresentViewController: UIViewController, MBModalPresentDestination {

    // MARK: 效果相关

    /**
     控制弹出的样式和布局位置

     actionSheet 从底部平移显示出来，展现后固定到底部，alert 从下方有个固定距离的浮现，展现后的位置和初始位置一致
     默认 actionSheet
     */
    var preferredStyle: UIAlertController.Style = .actionSheet

    /// 遮罩层，用于覆盖底部的其他页面
    @IBOutlet weak var maskView: UIView?

    /// 内容容器
    @IBOutlet weak var containerView: UIView?

    /// 子类重写以改变动效
    func setViewHidden(_ hidden: Bool, animated: Bool, completion: (() -> Void)?) {
        guard let mask = maskView, let menu = containerView else {
            return
        }

        let menuY = menu.bounds.origin.y
        let acStyle = (preferredStyle == .actionSheet)
        let superViewHeight = menu.superview?.bounds.height ?? 0
        UIView.animate(withDuration: 0.3, delay: 0, animated: animated, beforeAnimations: {
            mask.alpha = hidden ? 1 : 0
            if !acStyle {
                menu.alpha = hidden ? 1 : 0
            }
            if !hidden {
                if acStyle {
                    menu.frame.origin.y = superViewHeight
                } else {
                    menu.bounds.origin.y -= 40
                }
            }
        }, animations: {
            mask.alpha = hidden ? 0 : 1
            if acStyle {
                menu.frame.origin.y = hidden ? superViewHeight : superViewHeight - menu.frame.height
            } else {
                menu.bounds.origin.y = hidden ? menuY - 40 : menuY
                menu.alpha = hidden ? 0 : 1
            }
        }, completion: { _ in
            if hidden {
                if acStyle {
                    menu.frame.origin.y = superViewHeight - menu.frame.height
                } else {
                    menu.bounds.origin.y = menuY
                }
            }
            completion?()
        })
    }

    // MARK: 弹出控制

    /**
     从其他视图弹出
     */
    func present(from parentViewController: UIViewController?, animated: Bool, completion: (() -> Void)?) {
        if parentViewController is UINavigationController {
            print("⚠️ 不应从导航展现 MBModalPresentViewController，会导致导航 vc 堆栈判断错误")
        }
        guard let parentViewController = parentViewController ?? UIViewController.rootViewControllerWhichCanPresentModal() else {
            return
        }

        guard let dest = view else {
            return
        }
        dest.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentViewController.addChild(self)
        parentViewController.view.addSubview(dest, resizeOption: .fill)

        // 解决 iPad 上动画弹出时 frame 不正确
        dest.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            dest.isHidden = false
            self.setViewHidden(false, animated: true, completion: completion)
        }
    }

    /// MBModalPresent 的标准 dismiss 方法
    func dismissSelf(animated: Bool, completion: (() -> Void)?) {
        MBAPI.cancelOperations(withViewController: self)
        willDismiss?(self)
        setViewHidden(true, animated: true) { [weak self] in
            self?.removeFromParentViewControllerAndView()
            completion?()
        }
    }

    @IBAction func dismiss(_ sender: Any?) {
        if let control = sender as? UIControl {
            control.isEnabled = false
        }
        dismissSelf(animated: true, completion: nil)
    }

    /// 默认 segue 跳转时自动退出弹窗
    @IBInspectable var disableAutoDismissWhenSegueTriggered: Bool = false

    /// 即将退出弹窗时调用
    var willDismiss: ((MBModalPresentViewController) -> Void)?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UINavigationController {
            return
        }
        if !disableAutoDismissWhenSegueTriggered {
            dismissSelf(animated: true, completion: nil)
        }
        super.prepare(for: segue, sender: sender)
    }
}
