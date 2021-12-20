/*
 AlertController

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 需统一定制弹窗样式时，作为 UIAlertController 的替代
 */
class AlertController: MBModalPresentViewController, StoryboardCreation {
    static var storyboardID: StoryboardID { .main }

    // MARK: -

    /// 展示弹窗
    class func show(alert: (AlertController) -> Void) {
        let vc = AlertController.newFromStoryboard()
        alert(vc)
        vc.present(from: nil, animated: true, completion: vc.presentCompletion)
    }

    /// 提示一段信息
    class func promote(title: String?, message: String?) {
        let vc = AlertController.newFromStoryboard()
        vc.title = title
        vc.message = message
        vc.actionTitle = "知道了"
        vc.cancelTitle = nil
        vc.present(from: nil, animated: true, completion: nil)
    }

    var message: String?
    /// 取消按钮标题，为空不显示取消
    var cancelTitle: String? = "取消"
    /// 操作按钮标题，为空不显示操作按钮
    var actionTitle: String? = "确定"

    /// 点击取消执行
    var cancelHandler: (() -> Void)?

    /// 点击操作按钮执行
    var actionHandler: (() -> Void)?

    /// 展示完成回调
    var presentCompletion: (() -> Void)?

    /// 当有其他弹窗显示时跳过展示
    var skipIfAnotherAlertShown = false

    /// 如果设置，弹出时会检查 source 是否正在显示，若未显示不弹
    weak var source: UIViewController? {
        didSet {
            isSourceSet = source != nil
        }
    }
    private var isSourceSet = false

    // MARK: - 展示队列
    /// 当前展示中的弹窗
    private(set) static weak var currentController: AlertController?

    typealias PresentCallback = (() -> Void)?
    private static var displayQueue = [(AlertController, PresentCallback)]()
    private static func showQueuedIfNeeded() {
        Self.currentController = nil
        while displayQueue.isNotEmpty {
            let (vc, cb) = displayQueue.removeFirst()
            vc.present(from: nil, animated: true, completion: cb)
            if Self.currentController === vc {
                return
            }
        }
    }

    override func present(from parentViewController: UIViewController?, animated: Bool, completion: (() -> Void)? = nil) {
        assert(parentViewController == nil, "不允许定制弹出来源")
        if isSourceSet {
            guard let from = source,
                  from.isViewAppeared else {
                return
            }
            if let nav = from.navigationController {
                if nav.visibleViewController !== from { return }
            }
        }

        if Self.currentController != nil {
            if !skipIfAnotherAlertShown {
                Self.displayQueue.append((self, completion))
            }
            return
        }
        Self.currentController = self
        super.present(from: AppRootViewController(), animated: animated, completion: completion)
    }

    override func dismissSelf(animated: Bool, completion: (() -> Void)? = nil) {
        super.dismissSelf(animated: animated, completion: {
            Self.showQueuedIfNeeded()
            completion?()
        })
    }

    // MARK: -

    override func awakeFromNib() {
        super.awakeFromNib()
        preferredStyle = .alert
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.setTextOrHide(title)
        messageLabel.setTextOrHide(message)
        cancelButton.text = cancelTitle
        cancelButton.isHidden = cancelTitle == nil
        actionButton.text = actionTitle
        actionButton.isHidden = actionTitle == nil
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var actionButton: UIButton!

    @IBAction private func onCancel(_ sender: Any) {
        cancelHandler?()
        cancelHandler = nil
        dismissSelf(animated: true, completion: nil)
    }
    @IBAction private func onAction(_ sender: Any) {
        actionHandler?()
        actionHandler = nil
        dismissSelf(animated: true, completion: nil)
    }
}
