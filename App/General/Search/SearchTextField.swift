/**
 搜索输入框，搜索时显示菊花进度
 */
class SearchTextField: MBSearchTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 16 + 16 + 12, height: 44))
        leftView = container
        leftViewMode = .always
        container.addSubview(iconView)
        iconView.frame = CGRect(x: 16, y: (container.height - 16) / 2, width: 16, height: 16)
        container.addSubview(loadingView)
        loadingView.center = CGPointOfRectCenter(container.bounds)
        loadingView.move(xOffset: 2, yOffset: 0)
        loadingView.isHidden = true
    }

    lazy var iconView: UIImageView = {
        let icon = UIImageView(image: #imageLiteral(resourceName: "search_24"))
        icon.contentMode = .center
        return icon
    }()

    lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .init(medium: true))
        indicator.startAnimating()
        indicator.hidesWhenStopped = false
        return indicator
    }()

    override var isSearching: Bool {
        didSet {
            iconView.isHidden = isSearching
            loadingView.isHidden = !isSearching
        }
    }
}
