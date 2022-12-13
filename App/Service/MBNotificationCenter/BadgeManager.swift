/*!
 BadgeManager.swift
 MBNotificationCenter
 
 Copyright © 2020, 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

// swiftlint:disable:next identifier_name
func AppBadge() -> BadgeManager {
    BadgeManager.defaultManager
}

/**
 应用红点管理器
 */
class BadgeManager: MBNotificationBadgeManager {
    // 默认 requiresUser 为 YES，登出全部重置

    override func onInit() {
        super.onInit()
        pollingInterval = 60
    }

    // MARK: - 单组状态示例
/*
    @objc var hasNotice: Bool = false {
        didSet {
            setNeedsPostStatusChangedNotification()
        }
    }

    override func statusPolling() {
        API.requestName("NoticeNew") { c in
            c.success { [weak self] _, rsp in
                let has = (rsp as? Bool) ?? false
                self?.hasNotice = has
            }
            c.failureCallback = APISlientFailureHandler(true)
        }
    }
 */

    // MARK: - 多组状态示例
/*
    /// 正在检查状态
    private var isCheckingStatus = false

    //
    struct CheckStatus {
        var count = 0

        /// 周期：一个大数意味着启动最多检查一次
        var cycle = OnceCycle

        static let OnceCycle = 9999

        init(cycle: Int) {
            self.cycle = cycle
            count = cycle
        }

        /// 是否应该获取
        var shouldRefresh: Bool {
            return count >= cycle
        }

        mutating func bump() {
            count = count + 1
        }
        mutating func reset() {
            count = 0
        }
    }

    private var centerStaus = CheckStatus(cycle: 3)
    @objc var centerUnreadCount: Int = 0 {
        didSet {
            setNeedsPostStatusChangedNotification()
        }
    }

    private var newFollowerStaus = CheckStatus(cycle: CheckStatus.OnceCycle)
    @objc var hasNewFollower: Bool = false {
        didSet {
            setNeedsPostStatusChangedNotification()
        }
    }

    // 每次检查一组状态
    override func statusPolling() {
        if !AppActive() { return }

        centerStaus.bump()
        newFollowerStaus.bump()

        if isCheckingStatus { return }

        if centerStaus.shouldRefresh {
            centerStaus.reset()
            isCheckingStatus = true
            debugPrint("Updating center")
            dispatch_after_seconds(1) { [weak self] in
                guard let sf = self else { return }
                sf.centerUnreadCount = 99
                sf.isCheckingStatus = false
            }
        }
        else if newFollowerStaus.shouldRefresh {
            newFollowerStaus.reset()
            debugPrint("Updating new follower")
            dispatch_after_seconds(1) { [weak self] in
                guard let sf = self else { return }
                sf.hasNewFollower = true
                sf.isCheckingStatus = false
            }
        }
    }
 */
}
