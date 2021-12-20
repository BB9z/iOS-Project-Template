//
//  APIResponseSerializer.swift
//  App
//

/**
 应用接口解析器

 🔰 请按需修改
 这个解析器只适用于JSON接口，图像获取、文件下载等场景不适用

 关于错误处理
 --------

 这里处理了大部分错误，包括：
 - HTTP 状态码非 200-299
 - HTTP Content-Type 非 JSON
 - 返回内容为空
 - 不能按 JSON 解析、数据结构不对
 - 返回是约定的报错方式

 返回的数据对象符不符合相应的 model 需要再做相应判断

 返回的错误对象，属于应用业务的，domain 应为 `API.errorDomain`，其它属于网络部分的是 `NSURLErrorDomain`。除了正常的 localizedDescription 外，localizedRecoverySuggestion 和 localizedFailureReason 也会有输出
 */
class APIResponseSerializer: AFHTTPResponseSerializer {

    override init() {
        super.init()
        acceptableContentTypes = ["application/json", "text/json"]
    }

    @available(*, unavailable, message: "No implementation")
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func responseObject(for response: URLResponse?, data: Data?, error ePointer: NSErrorPointer) -> Any? {
        if let httpResponse = response as? HTTPURLResponse {
            // 检查 HTTP 状态码
            let statusCode = httpResponse.statusCode
            let isSuccessStatus = 200..<300 ~= statusCode
            guard isSuccessStatus else {
                if let error = tryDecodeErrorStruct(from: data) {
                    ePointer?.pointee = error
                    return nil
                }
                let description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                setError(ePointer, debugMessage: "请求状态异常：\(description) (\(statusCode))", domain: API.errorDomain, code: statusCode, description: description, reason: defaultErrorField, suggestion: defaultErrorField, url: response?.url)
                return nil
            }

            // 检查 Content-Type
            if let rspType = httpResponse.mimeType,
                let allowTypes = acceptableContentTypes,
                !allowTypes.isEmpty {
                guard allowTypes.contains(rspType) else {
                    // content-type 不是 JSON
                    setError(ePointer, debugMessage: "服务器返回的 Content-Type 是 \(rspType)，非标准的 application/json\n建议后台修改响应的 Content-Type 或客户端调节可解析的 Content-Type", domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, description: "服务器返回的类型与预期不符合", reason: defaultErrorField, suggestion: defaultErrorField, url: response?.url)
                    return nil
                }
            }
        } // END: as HTTPURLResponse

        // 数据非空
        guard let data = data, !data.isEmpty else {
            setError(ePointer, debugMessage: "空内容不被视为正常返回\n请联系后台人员确认状况", domain: NSURLErrorDomain, code: NSURLErrorZeroByteResource, description: "服务器返回空的内容", reason: defaultErrorField, suggestion: defaultErrorField, url: response?.url)
            return nil
        }

        // 尝试 JSON 解析
        let responseJSON: Any
        do {
            responseJSON = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        } catch {
            setError(ePointer, debugMessage: "解析器返回的错误信息：\(error.localizedDescription)\n建议先验证返回是否是合法的JSON，并联系后台人员", domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, description: "网络解析错误，如果你在使用公共 Wi-Fi，请打开系统浏览器获取网络访问权限", reason: defaultErrorField, suggestion: defaultErrorField, url: response?.url)
            return nil
        }

        // 🔰 下面请按具体接口约定修改
        // Demo 里的结构是字典，数据从 data 字段里取
        guard let responseObject = responseJSON as? [String: Any] else {
            setError(ePointer, debugMessage: "响应非字典", domain: NSURLErrorDomain, code: NSURLErrorCannotParseResponse, description: "返回数据结构异常", reason: defaultErrorField, suggestion: defaultErrorField, url: response?.url)
            return nil
        }

        if let error = tryGetErrorStruct(from: responseObject) {
            ePointer?.pointee = error
            return nil
        }
        return responseObject["data"]
    }

    /// 尝试解析错误信息，成功获取到返回非空错误对象
    private func tryDecodeErrorStruct(from data: Data?) -> NSError? {
        guard let data = data, !data.isEmpty,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let obj = json as? [String: Any] else {
            return nil
        }
        return tryGetErrorStruct(from: obj)
    }
    /// 字典结构如果包含错误信息则返回非空
    private func tryGetErrorStruct(from obj: [String: Any]) -> NSError? {
        // 🔰 这里请按具体接口约定修改
        if let code = obj["code"] as? Int, code > 0 {
            let message = obj["error"] as? String
            return NSError(domain: API.errorDomain, code: code, localizedDescription: message)
        }
        return nil
    }

    private let defaultErrorField = ""
    /// 工具方法，错误对象
    private func setError(_ error: NSErrorPointer, debugMessage: @autoclosure () -> String, domain: String, code: Int, description: String, reason: String?, suggestion: String?, url: URL?) {
        // swiftlint:disable:previous function_parameter_count
        #if DEBUG
        NSLog(debugMessage())
        #endif
        var info = [String: Any]()
        info[NSLocalizedDescriptionKey] = description
        info[NSLocalizedFailureReasonErrorKey] = reason == defaultErrorField ? "可能服务器正在升级或者维护，也可能是应用bug" : reason
        info[NSLocalizedRecoverySuggestionErrorKey] = suggestion == defaultErrorField ? "建议稍后重试，如果持续报告这个错误请检查应用是否有新版本" : suggestion
        info[NSURLErrorFailingURLErrorKey] = url
        error?.pointee = NSError(domain: domain, code: code, userInfo: info)
    }
}
