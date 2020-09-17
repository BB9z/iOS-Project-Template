/*
 DissolveTransitioning
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

// @MBDependency:2 示例性质
/**
 alpha 渐变转场
 
 使用
 
 ```
 override func awakeFromNib() {
     super.awakeFromNib()
     rfTransitioningStyle = NSStringFromClass(DissolveTransitioning.self)
 }
 ```
 
 */
@objc class DissolveTransitioning: RFAnimationTransitioning {
    override func onInit() {
        super.onInit()
        duration = 0.35
    }
    override func animateTransition(_ transitionContext: UIViewControllerContextTransitioning!, fromVC: UIViewController!, toVC: UIViewController!, from fromView: UIView!, to toView: UIView!) {
        let containerView = transitionContext.containerView
        let fromFrame = transitionContext.initialFrame(for: fromVC)
        let toFrame = transitionContext.finalFrame(for: toVC)

        toView.frame = toFrame.contains(fromFrame) ? toFrame : fromFrame
        if reverse {
            containerView.insertSubview(toView, belowSubview: fromView)
        } else {
            containerView.insertSubview(toView, aboveSubview: fromView)
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animated: true, beforeAnimations: {
            if !reverse {
                toView.alpha = 0
            }
        }, animations: {
            if self.reverse {
                fromView.alpha = 0
            } else {
                toView.alpha = 1
            }
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
