/*
 MBAPI
 MBAppKit

 Copyright © 2018-2021, 2023 BB9z.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

/**
 MBAPI 在 RFAPI 的基础上，

 - 基于 view controller 的请求管理

 使用

 应用应该创建 MBAPI 的子类，推荐在 onInit 中进行如下设置：

 1. 载入 API defines
 2. 设置 defineManager 的 defaultRequestSerializer 和 defaultResponseSerializer
 3. 设置 networkActivityIndicatorManager

 根据具体业务写相应的 defaultResponseSerializer 子类和 networkActivityIndicatorManager 子类。
 */
class MBAPI: RFAPI {

    /**
     共享实例，默认为空不自动创建

     项目代码应该在使用下面便捷方法前设置该共享实例
     */
    @objc static var global: MBAPI?

    /**
     从一个 plist 文件中载入接口定义

     Plist 例子：
     ```
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
         <key>DEFAULT</key>
         <dict>
             <key>Base</key>
             <string>http://example.com</string>
             <key>Path Prefix</key>
             <string>api/index?c=</string>
             <key>Method</key>
             <string>GET</string>
             <key>Authorization</key>
             <true/>
             <key>Cache Policy</key>
             <integer>0</integer>
             <key>Offline Policy</key>
             <integer>0</integer>
             <key>Expire</key>
             <string>60</string>
         </dict>
         <key>User Login</key>
         <dict>
             <key>Path</key>
             <string>user/login</string>
             <key>Authorization</key>
             <false/>
             <key>Response Class</key>
             <string>UserInformation</string>
             <key>Response Type</key>
             <integer>2</integer>
         </dict>
         <key>@ 支持分组</key>
         <dict>
             <key>User Reset Password</key>
             <dict>
                 <key>Path</key>
                 <string>user/reset</string>
                 <key>Authorization</key>
                 <false/>
             </dict>
             <key>User Change Password</key>
             <dict>
                 <key>Path</key>
                 <string>user/password</string>
             </dict>
         </dict>
     </dict>
     </plist>
     ```

     如果接口比较多，可以使用分组字典，key 的名必须以 @ 开头
     */
    func setupAPIDefine(plistPath path: String) {
        guard let rules = NSDictionary(contentsOfFile: path) as? [String: [String: Any]] else {
            assertionFailure("Cannot get api define rules at path: \(path)")
            return
        }
        defineManager.setDefinesWithRulesInfo(rules)
    }

    // MARK: - 请求管理

    /**
     标准请求
     */
    @objc class func requestName(_ APIName: String, context: (RFAPIRequestConext) -> Void) -> RFAPITask? {
        guard let instance = self.global else {
            assertionFailure("⚠️ MBAPI global instance has not been set.")
            return nil
        }
        return instance.request(name: APIName, context: context)
    }

    /**
     旧版兼容请求，默认错误处理方式

     - parameter APIName:         接口名，同时会作为请求的 identifier
     - parameter viewController: 请求所属视图，会取到它的 class 名作为请求的 groupIdentifier
     */
    class func request(withName APIName: String, parameters: [String: Any]? = nil, viewController: UIViewController? = nil, loadingMessage message: String? = nil, modal: Bool = false, success: RFAPIRequestSuccessCallback? = nil, completion: RFAPIRequestFinishedCallback? = nil) -> RFAPITask? {
        return self.requestName(APIName) { context in
            context.parameters = parameters
            context.groupIdentifier = viewController?.apiGroupIdentifier
            context.loadMessage = message
            context.loadMessageShownModal = modal
            context.successCallback = success
            context.finishedCallback = completion
        }
    }

    /**
     全参数请求，自定义错误处理

     - parameter failure: 为 nil 发生错误时自动弹出错误信息
     */
    class func request(withName APIName: String, parameters: [String: Any]? = nil, viewController: UIViewController? = nil, forceLoad: Bool = false, loadingMessage message: String? = nil, modal: Bool = false, success: RFAPIRequestSuccessCallback? = nil, failure: RFAPIRequestFailureCallback? = nil, completion: RFAPIRequestFinishedCallback? = nil) -> RFAPITask? {
        return self.requestName(APIName) { context in
            context.parameters = parameters
            context.loadMessage = message
            context.loadMessageShownModal = modal
            context.identifier = APIName
            context.groupIdentifier = viewController?.apiGroupIdentifier
            context.successCallback = success
            context.failureCallback = failure
            context.finishedCallback = completion
        }
    }

    /**
     请求回调合一

     不要忘记处理错误
     */
    class func request(withName APIName: String, parameters: [String: Any]? = nil, viewController: UIViewController? = nil, loadingMessage message: String? = nil, modal: Bool = false, completion: ((Bool, Any?, Error?) -> Void)? = nil) -> RFAPITask? {
        return self.requestName(APIName) { context in
            context.parameters = parameters
            context.loadMessage = message
            context.loadMessageShownModal = modal
            context.identifier = APIName
            context.groupIdentifier = viewController?.apiGroupIdentifier
            if let completion = completion {
                context.finishedCallback = { task, success in
                    completion(success, task?.responseObject, task?.error)
                }
            }
        }
    }

    /**
     发送一个后台请求

     失败不会报错
     */
    class func backgroundRequest(withName APIName: String, parameters: [String: Any]? = nil, completion: ((Bool, Any?, Error?) -> Void)? = nil) {
        _ = requestName(APIName) { context in
            context.parameters = parameters
            context.identifier = APIName
            if let completion = completion {
                context.completionCallback = { task, responseObject, error in
                    let success = error == nil && responseObject != nil
                    completion(success, responseObject, error)
                }
            }
        }
    }

    // MARK: -

    /**
     取消属于 viewController 的请求，用 view controller 的 APIGroupIdentifier 匹配请求
     */
    @objc class func cancelOperations(withViewController viewController: Any?) {
        guard let viewController = viewController as? UIViewController else { return }
        self.global?.cancelOperations(withGroupIdentifier: viewController.apiGroupIdentifier)
    }

    // MARK: 请求间隔

    /**
     背景：

     有的界面需要每次进入都刷新，如果刷新的请求还在进行或刚刚刷新且不是数据失效必须重刷，
     那么就没必要再此刷新了。为了实现这个效果，vc 需要记录时间，判定与上次成功获取的时间间隔，
     加上检查是否正在进行，至少要存两个属性，逻辑完善的话至少 10 行左右。

     RequestInterval 机制就是为了简化、复用上述机制。内部用 APIGroupIdentifier 跟踪请求的 groud id

     使用：

     - vc 先调用 enableRequestIntervalForViewController:APIName: 注册
     - 一般在 viewWillAppear: 中调用 shouldRequestForViewController:minimalInterval: 检查是否应该发送请求
     - 请求成功时调用 setRequestIntervalForViewController:APIName: 更新记录
     - 需要强制刷新时可能需要调用 clearRequestIntervalForViewController:

     */

    /// 为给定 vc 启用 RequestInterval 机制，name 用于内部跟踪，以便区分哪个请求需要记录起始
    func enableRequestInterval(for viewController: UIViewController, APIName name: String) {
        var records = requestIntervalRecord
        var vcRecords = self.requestIntervalRecordForVC(viewController)
        vcRecords[name] = .distantPast
        records[viewController.apiGroupIdentifier] = vcRecords
        requestIntervalRecord = records
    }

    /**
     记录给定 vc 给定接口最后一次成功获取的时间

     需要 vc 认为请求成功之后调用
     */
    func setRequestInterval(for viewController: UIViewController, APIName name: String) {
        var records = requestIntervalRecord
        var vcRecords = requestIntervalRecordForVC(viewController)
        vcRecords[name] = Date()
        records[viewController.apiGroupIdentifier] = vcRecords
        requestIntervalRecord = records
    }

    /**
     是否应当进行刷新操作，一般在 vc 显示时调用

     若 vc 记录了多个接口，只有当这些接口最近全没请求过，才会返回 YES

     @bug 请求实际完成到通知 vc 完成再调用 setRequestInterval 的这段时间里，不能阻挡新请求的发送
     */
    func shouldRequest(for viewController: UIViewController, minimalInterval interval: TimeInterval) -> Bool {
        let vcRecords = self.requestIntervalRecordForVC(viewController)
        let now = Date()
        for d in vcRecords.values {
            if fabs(d.timeIntervalSince(now)) < interval {
                return false
            }
        }
        let names = vcRecords.keys
        for op in operations(withGroupIdentifier: viewController.apiGroupIdentifier) {
            if names.contains(op.identifier) {
                return false
            }
        }
        return true
    }

    /**
     是否应当进行刷新操作，一般在 vc 显示时调用

     @bug 请求实际完成到通知 vc 完成再调用 setRequestInterval 的这段时间里，不能阻挡新请求的发送

     @param APIName 检查特定接口，传空等同于调用 shouldRequestForViewController:minimalInterval:
     */
    func shouldRequest(for viewController: UIViewController, APIName: String?, minimalInterval interval: TimeInterval) -> Bool {
        let r = requestIntervalRecordForVC(viewController)
        let now = Date()
        if let name = APIName, let d = r[name] {
            if fabs(d.timeIntervalSince(now)) < interval {
                return false
            }
        }
        return true
    }

    /// 重置给定 vc 的时间间隔记录
    func clearRequestInterval(for viewController: UIViewController) {
        var records = requestIntervalRecord
        records.removeValue(forKey: viewController.apiGroupIdentifier)
        requestIntervalRecord = records
    }

    func requestIntervalRecordForVC(_ vc: UIViewController) -> [String: Date] {
        requestIntervalRecord[vc.apiGroupIdentifier] ?? [:]
    }

    private lazy var requestIntervalRecord = [String: [String: Date]]()
}

extension UIViewController {

    /**
     通常 API 发送的请求会传入一个 view controller 参数，用来把请求和 view controller 关联起来。
     这样，当页面销毁时，跟这个页面关联的未完成的请求可以被取消。

     关联的方式就是 APIGroupIdentifier 属性，默认由 view controller 实例的内存地址生成。

     当 view controller 嵌套时，子控制器应该返回父控制器的 APIGroupIdentifier，
     以便整个页面销毁时，子控制器中的请求也可以被取消。
     */
    @objc var apiGroupIdentifier: String {
        get {
            if let identifier = objc_getAssociatedObject(self, &UIViewController.APIGroupIdentifierKey) as? String {
                return identifier
            } else {
                let identifier = "vc:\(Unmanaged.passUnretained(self).toOpaque())"
                objc_setAssociatedObject(self, &UIViewController.APIGroupIdentifierKey, identifier, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                return identifier
            }
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.APIGroupIdentifierKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    private static var APIGroupIdentifierKey: UInt8 = 0

    /// view controller 手动管理子 view controller 的 APIGroupIdentifier
    var manageAPIGroupIdentifierManually: Bool {
        return false
    }
}
