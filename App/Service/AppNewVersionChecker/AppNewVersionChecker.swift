/*
 AppNewVersionChecker.swift

 Copyright © 2021-2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

// swiftlint:disable nesting inclusive_language

/**
 应用更新检查器

 检查数据源目前支持 fir.im

 🔰 新控件暂不完善，按需修改
 */
class AppNewVersionChecker {

    /**
     创建 fir.im 的更新检查器

     - Parameter firShort: 下载链接后缀，如下载链接是 https://下载域名/abcd ，则这里填 abcd

        使用这种方式支持任意账户的公开应用，若用官方的 API 还需另配 token
     */
    init(firShort: String) {
        checkSource = .firim
        appID = firShort
        loadLastInfo()
    }

    // MARK: - 配置

    enum CheckSource: String, Codable {
        case appStore
        case firim
    }

    /// 版本检测源
    let checkSource: CheckSource

    let appID: String

    // MARK: - 状态

    /// 根据现有检测结果判断是否有新版
    var hasNewVersion: Bool {
        guard let result = info else {
            return false
        }
        return result.isNew
    }

    /// 版本信息
    struct VersionInfo: Codable {
        var version: String
        var build: String?
        var releaseNote: String?
        var source: CheckSource
        var ignoreThisVersion = false
        var skipNoticeBefore: Date?
        /// 成功获取的时间
        var refreshTime: Date

        /// 是否是新版本
        var isNew: Bool {
            let appVersion = MBApp.status().version
            let verisonResult = version.compare(appVersion, options: [.numeric])
            if verisonResult == .orderedDescending {
                return true
            } else if verisonResult == .orderedSame {
                // 短版本一致，比 build 版本
                if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
                   let resultBuild = build {
                    return resultBuild.compare(appBuild, options: [.numeric]) == .orderedDescending
                }
            }
            return false
        }

        var shouldNoticeNewVersion: Bool {
            if ignoreThisVersion { return false }
            if let skipTime = skipNoticeBefore,
               skipTime > Date() {
                return false
            }
            return isNew
        }
    }

    /// 已经获取到的版本信息
    private(set) var info: VersionInfo? {
        get { infoCache?.value(as: VersionInfo.self) }
        set { infoCache = OptionalBox(newValue) }
    }

    // MARK: - 操作

    func checkAndNoticeNewVersionIfNeeded() {
        if let info = info,
           info.shouldNoticeNewVersion {
            AlertController.show {
                $0.title = "版本更新"
                $0.message = "系统已检测到有更新版本，是否更新？"
                $0.cancelTitle = "暂不更新"
                $0.actionTitle = "立即更新"
                $0.cancelHandler = {
                    self.ignore(until: Date(timeIntervalSinceNow: Self.defaultIgnoreInterval))
                }
                $0.actionHandler = {
                    self.defaultUpdateAction()
                }
                $0.skipIfAnotherAlertShown = true
            }
        }
        if Date.isRecent(info?.refreshTime, range: Self.checkInterval) {
            return
        }
        check(silent: true, callback: Self.defaultBackgroundCheckCallback)
    }

    typealias CheckCallback = (AppNewVersionChecker, VersionInfo?, Error?) -> Void

    /**
     请求更新检测

     如果之前正在执行检查，会取消之前的任务

     - Parameter callback: 错误发生时会把之前成功获取的版本信息返回
     */
    func check(silent: Bool, callback: CheckCallback?) {
        task?.cancel()
        currentCheckCallback = callback
        switch checkSource {
        case .appStore:
            fatalError("应用商店检查不再可用")
        case .firim:
            checkFirim(silent: silent)
        }
        assert(task != nil)
    }

    /// 暂不提醒更新，直到制定日期
    func ignore(until: Date) {
        guard var info = info else {
            fatalError()
        }
        info.skipNoticeBefore = until
        self.info = info
        saveInfo()
    }

    /// 该版本不再提醒更新
    func ignore(version: VersionInfo) {
        guard var info = info else {
            fatalError()
        }
        assert(info.version == version.version)
        info.ignoreThisVersion = true
        self.info = info
        saveInfo()
    }

    // MARK: - 内部

    private var task: RFAPITask?
    private var currentCheckCallback: CheckCallback?
    private func noticeResultCallback(error: Error?) {
        guard let cb = currentCheckCallback else { return }
        DispatchQueue.main.async { [self] in
            cb(self, info, error)
        }
    }
    private func cleanRequest() {
        task?.cancel()
        task = nil
        currentCheckCallback = nil
    }

    private lazy var currentVersion = MBApp.status().version
    private var infoCache: OptionalBox?

    private func loadLastInfo() {
        if let data = AppUserDefaultsShared().value(forKey: Self.userDefaultResultKey) as? Data,
           let cached = try? JSONDecoder().decode(VersionInfo.self, from: data) {
            if cached.source == checkSource {
                infoCache = OptionalBox(cached)
            }
        }
    }

    /// 版本信息持久化
    private func saveInfo() {
        guard let value = info else { return }
        let data = try? JSONEncoder().encode(value)
        AppUserDefaultsShared().setValue(data, forKey: Self.userDefaultResultKey)
    }
    private static var userDefaultResultKey: String {
        "AppNewVersionChecker.Result"
    }

    // MARK: - firim

    private func checkFirim(silent: Bool) {
        let define = RFAPIDefine()
        define.method = "GET"
        define.path = "https://fir-download.fircli.cn/\(appID)"
        define.responseSerializerClass = AFJSONResponseSerializer.self
        define.needsAuthorization = false
        define.responseExpectType = .default

        task = AppAPI().request(define: define, context: { c in
            c.identifier = "CheckFirim"
            c.groupIdentifier = "AppNewVersionChecker"
            c.timeoutInterval = 10
            if !silent {
                c.loadMessage = "检查版本中，请稍后"
            }
            c.failure { [weak self] _, error in
                guard let sf = self else { return }
                AppLog().critical("\(error)")
                sf.noticeResultCallback(error: error)
            }
            c.success { [weak self] _, rsp in
                guard let sf = self else { return }
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: rsp as Any, options: [])
                    let results = try JSONDecoder().decode(FirImResponse.self, from: jsonData)
                    sf.handle(response: results)
                } catch {
                    AppLog().critical("\(error)")
                    sf.noticeResultCallback(error: error)
                }
            }
            c.finished { [weak self] _, _ in
                self?.cleanRequest()
            }
        })
    }

    private func handle(response: FirImResponse) {
        let item = response.app.releases.master
        if var info = info,
           info.version == item.version {
            info.refreshTime = Date()
            self.info = info
        } else {
            info = VersionInfo(version: item.version, build: item.build, releaseNote: item.changelog, source: .firim, refreshTime: Date())
            saveInfo()
        }
        saveInfo()
        noticeResultCallback(error: nil)
    }

    private struct FirImResponse: Decodable {
        var app: AppInfo

        struct AppInfo: Decodable {
            var releases: ReleaseCollection
        }

        struct ReleaseCollection: Decodable {
            var master: ReleaseItem
        }

        struct ReleaseItem: Decodable {
            var version: String
            var build: String
            var changelog: String?
        }
    }
}

/// 默认行为定制
extension AppNewVersionChecker {
    /// 默认供后台静默检测的回调，只有有新版本且用户未忽略过版本提示时才弹窗
    static var defaultBackgroundCheckCallback: CheckCallback {
        { checker, info, _ in
            guard checker.info?.shouldNoticeNewVersion == true else { return }
            AlertController.show {
                $0.title = "版本更新"
                $0.message = String.join("系统已检测到有更新版本，是否更新？", info?.releaseNote, separator: "\n")
                $0.cancelTitle = "暂不更新"
                $0.actionTitle = "立即更新"
                $0.cancelHandler = {
                    checker.ignore(until: Date(timeIntervalSinceNow: defaultIgnoreInterval))
                }
                $0.actionHandler = {
                    checker.defaultUpdateAction()
                }
                $0.skipIfAnotherAlertShown = true
            }
        }
    }

    /// 默认供用户手动点检测更新时用的回调，
    static var defaultCheckCallback: CheckCallback {
        { checker, info, error in
            if let info = info {
                if info.isNew {
                    AlertController.show {
                        $0.title = "版本更新"
                        $0.message = String.join("系统已检测到有更新版本，是否更新？", info.releaseNote, separator: "\n")
                        $0.cancelTitle = "暂不更新"
                        $0.actionTitle = "立即更新"
                        $0.cancelHandler = {
                            checker.ignore(until: Date(timeIntervalSinceNow: defaultIgnoreInterval))
                        }
                        $0.actionHandler = {
                            checker.defaultUpdateAction()
                        }
                    }
                } else {
                    AlertController.show {
                        $0.title = "应用版本"
                        $0.message = "当前为最新版本"
                        $0.actionTitle = "确定"
                        $0.cancelTitle = nil
                    }
                }
                return
            }
            if let err = error {
                AppHUD().alertError(err, title: "版本检测失败", fallbackMessage: nil)
            }
        }
    }

    /// 用户点暂不更新默认的不弹窗的时长
    static var defaultIgnoreInterval: TimeInterval {
        3600 * 24 * 7
    }

    /// 自动版本检查间隔
    static var checkInterval: TimeInterval {
        defaultIgnoreInterval / 2
    }

    func defaultUpdateAction() {
        switch checkSource {
        case .appStore:
            let link = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)")!
            UIApplication.shared.open(link, options: [:], completionHandler: nil)

        case .firim:
            let link = URL(string: "https://jappstore.com/\(appID)")!
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
    }
}
