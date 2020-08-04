//
//  UIViewController+AccountSwitching.swift
//  GuestMode
//

import ObjectiveC

/// 登入用户变化时辅助 vc 刷新
/// 这在支持游客模式的应用中有必要，一是游客和登入后看到的内容可能不一样，二是存在用户切换
protocol ViewControllerUserIdentifying {
    /// 是否需要刷新，建议在 viewWillAppear 或 viewDidAppear 检查
    var isNeedsReloadAsUserChanged: Bool { get }

    /// 刷新成功调用
    func updateLastUserID()
}

/// 默认实现
extension UIViewController: ViewControllerUserIdentifying {
    private static var _LastUserIDKey: UInt8 = 0
    // 需要是 optional 的，这样第一次进入页面可以走同样的逻辑
    private var lastUserID: MBID? {
        get {
            let num = objc_getAssociatedObject(self, &UIViewController._LastUserIDKey) as? NSNumber
            return num?.int64Value
        }
        set {
            if let v = newValue {
                objc_setAssociatedObject(self, &UIViewController._LastUserIDKey, NSNumber(value: v), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &UIViewController._LastUserIDKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var isNeedsReloadAsUserChanged: Bool {
        AppUserID() != lastUserID
    }
    func updateLastUserID() {
        lastUserID = AppUserID()
    }
}
