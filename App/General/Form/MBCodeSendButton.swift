/*!
 MBCodeSendButton

 Copyright © 2018, 2020, 2023 BB9z.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/**
 短信发送按钮

 对刷新逻辑进行了封装。推荐使用方式：

 1. IB 中设置按钮类
 2. 设置 normal 状态的文字，如「发送」
 3. 设置 disabled 状态的文字，如「%d 秒后重发」
 4. 可选设置 frozeSecond
 5. 短信发送成功后调用 froze 方法

 */
class MBCodeSendButton: MBButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        if disableNoticeFormat == nil {
            disableNoticeFormat = title(for: .disabled)
        }
    }

    /**
     发送短信后显示的文字

     必须包含 %d 或其他整型格式化字符，例如：@"%d 秒后重发"
     默认设置为 interface builder 中 disabled 状态的标题
     */
    var disableNoticeFormat: String?

    /**
     短信发送后按钮禁用的时长

     默认 60s
     */
    @IBInspectable var frozeSecond: UInt = 60

    /**
     标记往服务器的请求正在发送中

     同时禁用按钮，并设置禁用文字标题

     - Parameter message: 即将显示的文本，如果为空，尝试取 selected 状态的文本
     */
    func markSending(message: String?) {
        let message = message ?? title(for: .selected)
        setTitle(message ?? "发送中", for: .disabled)
        isEnabled = false
        invalidateIntrinsicContentSize()
    }

    /**
     冻结按钮，进入倒计时

     在短信发送成功后调用
     */
    func froze() {
        isEnabled = false
        nextField?.becomeFirstResponder()
        if timer?.isScheduled() == true { return }

        let initTitle = String(format: disableNoticeFormat ?? "", frozeSecond)
        setTitle(initTitle, for: .disabled)
        unfreezeTime = Date.timeIntervalSinceReferenceDate + TimeInterval(frozeSecond)

        timer = RFTimer.scheduledTimer(withTimeInterval: 1, repeats: true, fire: { [weak self] _, _ in
            guard let sf = self else { return }
            let left = sf.unfreezeTime - Date.timeIntervalSinceReferenceDate
            if left <= 0 {
                sf.timer?.invalidate()
                sf.timer = nil
                sf.isEnabled = true
            } else {
                sf.setTitle(String(format: sf.disableNoticeFormat ?? "", Int(left)), for: .disabled)
            }
        })
    }

    /// 短信发送后按钮解禁的时间，timeIntervalSinceReferenceDate
    private var unfreezeTime: TimeInterval = 0
    private var timer: RFTimer?

    /**
     请求成功后焦点转移到下一个
     */
    @IBOutlet weak var nextField: UIResponder?

}
