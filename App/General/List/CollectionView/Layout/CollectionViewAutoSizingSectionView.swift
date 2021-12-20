/*
 CollectionViewAutoSizingSectionView

 Copyright © 2020 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

/**
 自动更新高度的 section header/footer view，通常用于单 section 列表在顶部和底部添加自适应高度的区域

 通过修改 headerReferenceSize/footerReferenceSize 更新高度，所以只支持单 section 的情形；
 如果需要多个 section 有不同的高度，需定制 UICollectionViewLayout
 */
class CollectionViewAutoSizingSectionView: UICollectionReusableView, ResizeObserver {
    @IBOutlet weak var refrenceHeightView: ResizeObservableView!
    @IBInspectable var isFooter: Bool = false

    func didResized(view: UIView, oldSize: CGSize) {
        if view == refrenceHeightView {
            if height != refrenceHeightView.height {
                updateHeight()
            }
        }
    }

    func updateHeight() {
        guard let list = superview as? UICollectionView else {
            NSLog("⚠️ CollectionViewAutoSizingSectionView: 父视图需要是 collection view")
            return
        }
        guard let layout = list.collectionViewLayout as? UICollectionViewFlowLayout else {
            NSLog("⚠️ CollectionViewAutoSizingSectionView: 只支持  UICollectionViewFlowLayout")
            return
        }
        if isFooter {
            layout.footerReferenceSize = intrinsicContentSize
        } else {
            layout.headerReferenceSize = intrinsicContentSize
        }
    }

    override var intrinsicContentSize: CGSize {
        if let ref = refrenceHeightView {
            return CGSize(width: width, height: ref.height)
        }
        return super.intrinsicContentSize
    }
}
