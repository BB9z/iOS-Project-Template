/*
 ListStateView

 Copyright © 2020-2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 列表状态 view，也可用详情
 List state view, can also be used for details

 通过设置状态变量切换状态
 Switch state by setting state variables
 */
class ListStateView: UIView {
    enum State {
        case loading(String?)
        case error(Error?)
        /// 列表为空，会禁用交互响应，允许用户操作覆盖在下面的列表
        /// An empty list will disable the interaction response.
        /// Allow users to interact with the list which is covered below
        case empty(String?)
        /// 正常状态，隐藏 view
        /// Normal state, this view is hidden
        case normal

        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
    }

    var state: State = .normal {
        didSet {
            updateUI(state)
        }
    }

    /// 可选，加载时执行动画，其他状态停止
    /// Optional, start animation when loading, stop in other states
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView?
    /// 可选，失败时显示，供点击重试用
    /// Optional, show when failed, for click to retry
    @IBOutlet private weak var retryButton: UIButton?
    /// 显示状态文本
    /// Display status text
    @IBOutlet private weak var statesLabel: UILabel?

    /// 加载时需要隐藏？
    /// Need to hide when loading?
    @IBInspectable var shouldHiddenWhenLoading: Bool = false
    @IBInspectable var defaultLoadingText: String = "Loading..."
    @IBInspectable var defaultEmptyText: String = "暂无内容"
    @IBInspectable var defaultErrorText: String = "请求失败"

    private func updateUI(_ state: State) {
        switch state {
        case .loading(let text):
            if shouldHiddenWhenLoading {
                isHidden = true
            } else {
                isHidden = false
                activityIndicator?.startAnimating()
                retryButton?.isHidden = true
                statesLabel?.text = text ?? defaultLoadingText
            }
            isUserInteractionEnabled = true

        case .normal:
            isHidden = true
            activityIndicator?.stopAnimating()
            statesLabel?.text = nil

        case .empty(let text):
            isHidden = false
            activityIndicator?.stopAnimating()
            retryButton?.isHidden = true
            statesLabel?.text = text ?? defaultEmptyText
            isUserInteractionEnabled = false

        case .error(let error):
            isHidden = false
            activityIndicator?.stopAnimating()
            retryButton?.isHidden = false
            statesLabel?.text = error?.localizedDescription ?? defaultErrorText
            isUserInteractionEnabled = true
        }
    }
}
