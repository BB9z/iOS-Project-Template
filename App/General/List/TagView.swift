/// 可被 TagView 展示的元素
@objc public protocol TagViewElement {
    /// Tag 标题
    var title: String { get }

    /// 可选背景色
    @objc optional var backgroundColor: UIColor? { get }
}

// @MBDependency:2 示例性质，根据需求修改
/// 自定义绘制，展示若干 tag
public class TagView: UIView {
    public typealias Item = TagViewElement
    public var items: [Item] = [] {
        didSet {
            invalidateIntrinsicContentSize()
            updateTagLayout(targetSize: bounds.size, force: true)
            setNeedsDisplay()
        }
    }

    // MARK: - 外观配置

    /// 为 true 时 tag 不换行
    @IBInspectable public var oneLine: Bool = false
    @IBInspectable public var cellHeight: CGFloat = 18
    /// Cell 文字距两边的距离
    @IBInspectable public var cellPadding: CGFloat = 10
    @IBInspectable public var cellCornerRadius: CGFloat = 2
    /// 同行 cell 之间的空隙
    @IBInspectable public var itemSpacing: CGFloat = 10
    /// 列之间的空隙
    @IBInspectable public var lineSpacing: CGFloat = 8
    /// cell 四周绘制边框
    @IBInspectable public var isDrawBorder: Bool = false

    lazy var titleAttribute: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: tintColor as Any,
            .paragraphStyle: style
        ]
    }()

    override public func tintColorDidChange() {
        super.tintColorDidChange()
        defaultTintCellFillColor = tintColor.withAlphaComponent(0.1)
        titleAttribute[.foregroundColor] = tintColor
        setNeedsDisplay()
    }
    private lazy var defaultTintCellFillColor: UIColor = tintColor.withAlphaComponent(0.1)

    // MARK: - 布局

    override public func layoutSubviews() {
        updateTagLayout(targetSize: bounds.size)
        super.layoutSubviews()
        setNeedsDisplay()
    }

    override public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        updateTagLayout(targetSize: targetSize, force: false)
        return lastContentSize
    }
    override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        updateTagLayout(targetSize: targetSize, force: false)
        return lastContentSize
    }
    override public var intrinsicContentSize: CGSize {
        if items.isEmpty { return .zero }
        return lastContentSize
    }
    private var lastContentSize: CGSize = .zero {
        didSet {
            if oldValue != lastContentSize {
                invalidateIntrinsicContentSize()
            }
        }
    }

    private var lastLayoutContentWidth: CGFloat?
    private var tagFrameCache = [CGRect]()
    private func updateTagLayout(targetSize: CGSize, force: Bool = false) {
        let isOneLine = oneLine
        let contentWidth = targetSize.width
        if !force && lastLayoutContentWidth == contentWidth {
            return
        }
        lastLayoutContentWidth = contentWidth
        var ctX: CGFloat = 0
        var ctY: CGFloat = 0
        let textAttribute = titleAttribute
        var tagFrames = [CGRect]()

        func nextLine() {
            ctX = 0
            ctY += cellHeight + lineSpacing
        }

        let cellPaddingSum = cellPadding * 2
        for ctItem in items {
            let text = ctItem.title
            let textSize = text.boundingRect(with: CGSize(width: contentWidth - cellPaddingSum, height: cellHeight), options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: textAttribute, context: nil)
            let lineLeft = contentWidth - ctX
            if !isOneLine, textSize.width + cellPaddingSum > lineLeft {
                nextLine()
            }
            let tagFrame = CGRect(x: ctX, y: ctY, width: textSize.width + cellPaddingSum, height: cellHeight)
            tagFrames.append(tagFrame.integral)
            ctX += tagFrame.width + itemSpacing
            if !isOneLine, ctX >= contentWidth {
                nextLine()
            }
        }
        tagFrameCache = tagFrames
        if isOneLine {
            lastContentSize = CGSize(width: ctX > 0 ? ctX - itemSpacing : 0, height: ctX > 0 ? cellHeight : 0)
        } else {
            lastContentSize = CGSize(width: contentWidth, height: tagFrameCache.last?.maxY ?? 0)
        }
    }

    // MARK: - 绘制

    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        if tagFrameCache.count != items.count {
            updateTagLayout(targetSize: bounds.size, force: true)
        }
        items.enumerateElements { tag, idx, _ in
            let tagFrame = tagFrameCache[idx]
            if rect.intersects(tagFrame) {
                let bgColor = (tag.backgroundColor as? UIColor) ?? defaultTintCellFillColor
                drawTag(frame: tagFrame, title: tag.title, background: bgColor)
            }
        }
    }

    private func drawTag(frame: CGRect, title: String, background: UIColor) {
        let boxPath = UIBezierPath(roundedRect: frame, cornerRadius: cellCornerRadius)
        background.setFill()
        boxPath.fill()
        if isDrawBorder {
            let lineWidth = 1 / layer.contentsScale
            let strokePath = UIBezierPath(roundedRect: frame.inset(by: UIEdgeInsets(top: lineWidth, left: lineWidth, bottom: lineWidth, right: lineWidth)), cornerRadius: cellCornerRadius)
            tintColor.setStroke()
            strokePath.lineWidth = lineWidth
            strokePath.stroke()
        }

        let titleRect = frame
        let attributes = titleAttribute

        let titleTextHeight: CGFloat = title.boundingRect(with: frame.size, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], attributes: attributes, context: nil).height
        title.draw(in: CGRect(x: titleRect.minX, y: titleRect.minY + (titleRect.height - titleTextHeight) / 2, width: titleRect.width, height: titleTextHeight), withAttributes: attributes)
    }
}
