/*
 EnumListView.swift

 Copyright © 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

@objc protocol EnumListElement {
    var enumListDiscription: String { get }
}

/**
 从一些对象中选中一个的列表
 */
class EnumListView: UICollectionView, UICollectionViewDelegateFlowLayout {
    typealias EnumObject = AnyObject & EnumListElement

    override var intrinsicContentSize: CGSize {
        collectionViewLayout.collectionViewContentSize
    }

    override var bounds: CGRect {
        didSet {
            if oldValue.width != bounds.width {
                invalidateIntrinsicContentSize()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let ds = MBCollectionViewArrayDataSource<EnumObject>()
        ds.collectionView = self
        ds.keepSelectionAfterReload = true
        dataSource = ds
        listDataSource = ds
        delegate = self
    }

    var listDataSource: MBCollectionViewArrayDataSource<EnumObject>!

    /// 已选中 cell 再次点击反选
    @IBInspectable var allowsDeselection: Bool = true

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            if allowsDeselection {
                collectionView.deselectItem(at: indexPath, animated: true)
                selectedIndexPath = nil
            }
        } else {
            selectedIndexPath = indexPath
        }
    }

    var selectionDidChanged: ((EnumObject?) -> Void)?
    var selectedIndexPath: IndexPath? {
        didSet {
            if let cb = selectionDidChanged {
                if let ip = selectedIndexPath, let obj = listDataSource.item(at: ip) {
                    cb(obj)
                } else {
                    cb(nil)
                }
            }
        }
    }

    @IBInspectable var cellMinWidth: CGFloat = 110
    @IBInspectable var cellHight: CGFloat = 36

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let string = listDataSource.item(at: indexPath)?.enumListDiscription ?? ""
        var size = (string as NSString).size(withAttributes: cellLabelAttributes)
        size.width = max(ceil(min(size.width + 30, collectionView.width - 60)), cellMinWidth)
        size.height = cellHight
        return size
    }

    // 按需修改，用于计算 cell 大小
    lazy var cellLabelAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold)]
}

class EnumListCell: UICollectionViewCell {
    @objc var item: EnumListView.EnumObject! {
        didSet {
            button.text = item.enumListDiscription
        }
    }
    @IBOutlet weak var button: UIButton!

    override var isSelected: Bool {
        didSet {
            button.isSelected = isSelected
        }
    }
}

extension NSString: EnumListElement {
    var enumListDiscription: String {
        self as String
    }
}
