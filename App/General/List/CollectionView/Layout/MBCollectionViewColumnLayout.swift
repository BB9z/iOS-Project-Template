/*
 MBCollectionViewColumnLayout

 Copyright © 2018-2021 BB9z.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 按列布局，根据列数等比例调整 cell 的大小并保持 cell 的间距不变

 可以指定一个固定列数或一个 cell 的参考大小自动调整列数

 不支持通过 delegate 设置 itemSize。如果 delegate 返回了 itemSize，则列设置将失效。
 多 section 将根据第一个 section 的尺寸进行布局，不支持多 section 有不同的 itemSize。
 */
class MBCollectionViewColumnLayout: UICollectionViewFlowLayout {

    /**
     根据宽度自适应调整列数

     开启时，外部设置的 columnCount 失效，将根据 itemSize 决定列数，能显示几列就显示几列。
     但跟原始的 UICollectionViewFlowLayout 不同之处在于会等比拉大 cell 保持最小间隙。

     默认 NO
     */
    @IBInspectable var autoColumnDecideOnItemMinimumWidth: Bool = false

    /// 列数量，默认 3
    @IBInspectable var columnCount: Int = 3 {
        didSet {
            if oldValue == columnCount { return }
            if !autoColumnDecideOnItemMinimumWidth {
                invalidateLayout()
            }
        }
    }

    /**
     布局的参考 item size，这个类会修改实际 itemSize

     从 nib 里载入后会吧 itemSize 复制给这个属性，如果手动更新该属性需要手动调用重新布局的方法
     */
    @IBInspectable var referenceItemSize: CGSize = .zero

    /**
     仅宽度自适应，保持高度
     */
    @IBInspectable var onlyAdjustWidth: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        referenceItemSize = itemSize
    }

    override func prepare() {
        super.prepare()
        guard let list = collectionView else { return }
        let layoutChanged = updateLayout(bounds: list.bounds)
        if layoutChanged {
            list.invalidateIntrinsicContentSize()
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if newBounds.width != collectionView?.bounds.width {
            updateLayout(bounds: newBounds)
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    /// 返回是否更新了布局
    @discardableResult private func updateLayout(bounds: CGRect) -> Bool {
        if (collectionView?.numberOfSections ?? 0) == 0 { return false }
        let size = itemSize(for: bounds)
        if itemSize == size { return false }
        itemSize = size
        return true
    }

    // MARK: - 布局计算

    private var delegateRefrence: UICollectionViewDelegateFlowLayout? {
        collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }

    private func itemSize(for bounds: CGRect) -> CGSize {
        let reference = referenceItemSize
        if autoColumnDecideOnItemMinimumWidth {
            let width = innerLayoutWidth(section: 0, bounds: bounds)
            columnCount = Int(width / reference.width)
        }
        let width = itemWidth(section: 0, bounds: bounds)
        let height = onlyAdjustWidth ? reference.height : width / reference.width * reference.height
        return CGSize(width: width, height: height)
    }

    private func itemWidth(section: Int, bounds: CGRect) -> CGFloat {
        let width = innerLayoutWidth(section: section, bounds: bounds)
        let column = CGFloat(max(1, columnCount))
        return ((width - (column - 1) * minimumInteritemSpacing) / column).rounded(.down)
    }

    private func innerLayoutWidth(section: Int, bounds: CGRect) -> CGFloat {
        var inset = sectionInset
        if let list = collectionView,
           let dInset = delegateRefrence?.collectionView?(list, layout: self, insetForSectionAt: section) {
            inset = dInset
        }
        return bounds.width - inset.left - inset.right
    }
}
