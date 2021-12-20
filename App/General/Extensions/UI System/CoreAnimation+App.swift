/*
 应用级别的便捷方法: CoreAnimation 扩展
 */

extension CATransaction {
    /// 无 CA 动画执行一些操作（防止隐式动画）
    class func withoutAnimation(_ actions: () -> Void) {
        begin()
        setDisableActions(true)
        actions()
        commit()
    }
}

extension CAAnimation: CAAnimationDelegate {

    fileprivate class Delegate: NSObject, CAAnimationDelegate {
        var complateBlock: ((Bool) -> Void)?

        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            if let cb = complateBlock {
                cb(flag)
            }
        }
    }

    /// 设置动画完成回调
    var complateBlock: ((Bool) -> Void)? {
        get {
            (delegate as? Delegate)?.complateBlock
        }
        set {
            let obj: Delegate = (delegate as? Delegate) ?? {
                let this = Delegate()
                delegate = this
                return this
            }()
            obj.complateBlock = newValue
        }
    }
}
