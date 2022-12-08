/*
 DetailFetchControl.swift

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#if canImport(Alamofire)
import Alamofire
#endif
import B9Condition

/**
 详情获取控制器

 作为 vc 属性，vc 释放跟着释放

 🔰 新控件暂不完善，按需修改
 */
class DetailFetchControl<T> {

    deinit {
        task?.cancel()
        AppCondition().remove(observer: onlineObserver)
    }

    var item: T!

    /**
     可选设置，设置后执行额外逻辑：

     数据充足时，网络加载不再显示加载进度；
     数据充足时，网络加载失败不执行失败回调
     */
    var hasEnoughDataToDisplay: ((T) -> Bool)?

    /// start 时会立即调用一次，之后当数据更新时调用
    var updater: ((T) -> Void)?
    /// 获取失败处理
    var fetchError: ((RFAPITask?, Error) -> Void)?

    /// 服务器模型转换，通常在后台线程执行
    var responseProcess: ((Any?, T) -> T)?

    /// 数据不充足且离线时展示
    var offlineTips = "未连接网络，联网后才能查看详情内容"

    private var onlineObserver: AnyObject?
    private weak var task: RFAPITask?
    private var api = ""
    private var parameters = [String: Any]()
    private var retryLeft = 1

    /// 开始获取数据
    func start(api: String, parameters: [String: Any]) {
        guard let item = item else {
            fatalError("start 前 item 必须设置好")
        }
        updater?(item)
        self.api = api
        self.parameters = parameters
        if AppCondition().meets([.online]) {
            doRequest()
            return
        }
        if let hasCB = hasEnoughDataToDisplay, !hasCB(item) {
            AppHUD().showInfoStatus(offlineTips)
        }
        // 离线
        onlineObserver = AppCondition().observe([.online], action: Action { [weak self] in
            guard let sf = self else { return }
            AppCondition().remove(observer: sf.onlineObserver)
            sf.doRequest()
        })
    }

    private func doRequest() {
        guard let item = item else { fatalError() }
        task = API.requestName(api) { c in
            c.parameters = parameters
            if let hasCB = hasEnoughDataToDisplay, !hasCB(item) {
                // 数据不足明确加载状态
                c.loadMessage = ""
            }
            c.failure { [weak self] task, error in
                guard let sf = self else { return }
                let code = (error as NSError).code
                if 400..<500 ~= code {
                    // 4XX 客户端错误得报
                    sf.fetchError?(task, error)
                    return
                }
                // 数据充足不报错
                if let hasCB = sf.hasEnoughDataToDisplay, hasCB(item) { return }
                if sf.retryLeft > 0,
                   sf.canRetry(task: task, error: error) {
                    sf.retryLeft -= 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.doRequest()
                    }
                    return
                }
                sf.fetchError?(task, error)
            }
            if let process = responseProcess {
                c.responseObjectTransformer = { process($1, item) }
            }
            c.success { [weak self] _, rsp in
                guard let sf = self else { return }
                guard let rspItem = rsp as? T else { fatalError() }
                sf.updater?(rspItem)
            }
        }
    }

    #if canImport(Alamofire)
    lazy var retryPolicy = RetryPolicy()
    func canRetry(task: RFAPITask?, error: Error) -> Bool {
        if let code = (task?.response as? HTTPURLResponse)?.statusCode {
            if retryPolicy.retryableHTTPStatusCodes.contains(code) { return true }
        }
        if let errorCode = (error as? URLError)?.code {
            if retryPolicy.retryableURLErrorCodes.contains(errorCode) { return true }
        }
        return false
    }
    #else
    private func canRetry(task: RFAPITask?, error: Error) -> Bool {
        true
    }
    #endif
}
