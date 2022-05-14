//
//  API.swift
//  App
//

import B9Condition
import Debugger

/**
 API 接口请求层
 */
public class API: MBAPI {
    /// 业务错误
    @objc static let errorDomain = "APIErrorDomain"

    override public func onInit() {
        super.onInit()

        #if DEBUG
        if Debugger.isDebugEnabled {
            // 允许外部 SSL 嗅探
            let policy = AFSecurityPolicy.default()
            policy.allowInvalidCertificates = true
            policy.validatesDomainName = false
            securityPolicy = policy
        }
        #endif

        // 接口总体设置
        setupAPIDefine(withPlistPath: Bundle.main.path(forResource: "APIDefine", ofType: "plist")!)

        defineManager.defaultRequestSerializer = AFJSONRequestSerializer()
        defineManager.defaultResponseSerializer = APIResponseSerializer()

        // 针对演示用接口做的调整，正式项目请移除这部分代码
        debugAdjustTestAPI()

        modelTransformer = RFAPIJSONModelTransformer()
    }

    override public func afterInit() {
        super.afterInit()
        reachabilityManager.startMonitoring()
        reachabilityManager.setReachabilityStatusChange { status in
            // 模拟器可能只在启动后更新一次
            switch status {
            case .reachableViaWiFi:
                AppCondition().set(on: [.online, .wifi])
            case .reachableViaWWAN:
                AppCondition().set(off: [.wifi])
                AppCondition().set(on: [.online])
            default:
                AppCondition().set(off: [.online, .wifi])
            }
        }
    }

    /// 错误统一处理
    override public func generalHandlerForError(_ error: Error, define: RFAPIDefine, task: RFAPITask, failure: RFAPIRequestFailureCallback? = nil) -> Bool {
        let nsError = Self.transformURLError(error as NSError)
        task.error = nsError

        if define.path?.hasPrefix("http") == true {
            // define 里写的绝对路径，意味着不是我们主要的业务逻辑
            if let cb = failure {
                cb(task, nsError)
            } else {
                networkActivityIndicatorManager?.alertError(nsError, title: nil, fallbackMessage: "请求失败")
            }
        }

        if nsError.domain == NSURLErrorDomain {
            // 特殊情况，清除缓存
            if nsError.code == NSURLErrorCannotParseResponse {
                // 移除不能解析请求的缓存
                // 移除单个请求的貌似没效果
                URLCache.shared.removeAllCachedResponses()
            }
        } // END: 网络层错误处理

        if nsError.domain == API.errorDomain {
            // 🔰 根据业务做统一处理，比如 token 失效登出
            switch nsError.code {
//            case token_invald:
//                if define.needsAuthorization {
//                    if AppUser() != nil {
//                        Account.current = nil
//                        AppHUD().showErrorStatus("登录已过期，请重新登录")
//                    }
//                    return false
//                }

            default:
                break
            }
        } // END: 业务错误处理

        // - 最终处理，报告错误
        if let cb = failure {
            cb(task, nsError)
        } else {
            networkActivityIndicatorManager?.alertError(nsError, title: nil, fallbackMessage: "请求失败")
        }
        return false    // 需要为 false，终止默认的错误处理
    }

    /// 重新包装错误
    private class func transformURLError(_ error: NSError) -> NSError {
        if error.domain == API.errorDomain {
            switch error.code {
            case 502:
                return NSError(domain: error.domain, code: error.code, localizedDescription: "服务器维护中，请稍后再试")
            default:
                break
            }
        }
        guard error.domain == NSURLErrorDomain else {
            return error
        }
        if let key = URLErrorTransfomMap[error.code] {
            return NSError(domain: error.domain, code: error.code, localizedDescription: localizedString(forKey: key, value: error.localizedDescription))
        }
        return error
    }
    private static let URLErrorTransfomMap = [
        NSURLErrorCannotConnectToHost: "NSURLErrorCannotConnectToHost",
        NSURLErrorCannotFindHost: "NSURLErrorCannotFindHost",
        NSURLErrorDataNotAllowed: "NSURLErrorDataNotAllowed",
        NSURLErrorDNSLookupFailed: "NSURLErrorDNSLookupFailed",
        NSURLErrorNetworkConnectionLost: "NSURLErrorNetworkConnectionLost",
        NSURLErrorNotConnectedToInternet: "NSURLErrorNotConnectedToInternet",
        NSURLErrorSecureConnectionFailed: "NSURLErrorSecureConnectionFailed",
        NSURLErrorTimedOut: "NSURLErrorTimedOut"
    ]

    override public func isSuccessResponse(_ responseObjectRef: UnsafeMutablePointer<AnyObject?>, error: NSErrorPointer) -> Bool {
        // 🔰 判断是否是成功响应
        return true
    }

    private func debugAdjustTestAPI() {
        guard defineManager.defaultDefine?.baseURL?.host == "bb9z.github.io" else {
            debugPrint("⚠️ 请移除演示代码 \(#function)")
            return
        }
        // 演示接口只支持 GET 方法，且需要附加 JSON 后缀
        defineManager.defines.forEach { define in
            if var path = define.path {
                // 非相对路径，意味着是外部接口，跳过
                if path.hasPrefix("http") { return }

                if define.responseExpectType == .objects {
                    // 列表请求，改造分页参数
                    path = (path as NSString).appendingPathComponent("{page}")
                }

                define.path = (path as NSString).appendingPathExtension("json")
            }
            define.method = "GET"
        }
        // 允许解析网页 404
        if let serializer = defineManager.defaultResponseSerializer as? AFHTTPResponseSerializer {
            var set = serializer.acceptableContentTypes ?? Set<String>()
            set.insert("text/html")
            serializer.acceptableContentTypes = set
        }
    }
}

/**
 返回一个空的 block，用于静默默认的错误弹窗
 */
public func APISlientFailureHandler(_ logError: Bool) -> (Any?, Error?) -> Void {
    if logError {
        return { _, e -> Void in
            debugPrint(e as Any)
        }
    } else {
        return { _, _ -> Void in
        }
    }
}
