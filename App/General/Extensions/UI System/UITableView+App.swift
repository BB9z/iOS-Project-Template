/*
 应用级别的便捷方法
 */
extension UITableView {

    // @MBDependency:2
    /// 选中某一 section 的全部 cell
    func selectRows(ofSection section: Int, animated: Bool) {
        for i in 0..<numberOfRows(inSection: section) {
            selectRow(at: IndexPath(row: i, section: section), animated: animated, scrollPosition: .none)
        }
    }

    // @MBDependency:2
    /// 反选某一 section 的全部 cell
    func deselectRows(ofSection section: Int, animated: Bool) {
        for i in 0..<numberOfRows(inSection: section) {
            deselectRow(at: IndexPath(row: i, section: section), animated: animated)
        }
    }

    // @MBDependency:1
    /// 某一 section 的选中单元数量
    func selectRowCount(inSection section: Int) -> Int {
        guard let ips = indexPathsForSelectedRows else {
            return 0
        }
        var count = 0
        for ip in ips where ip.section == section {
            count += 1
        }
        return count
    }

    // @MBDependency:2
    /// 可见 cell 的 IndexPath 集合
    var indexPathsForVisibleCells: [IndexPath] {
        visibleCells.compactMap { indexPath(for: $0) }
    }
}

/// 防止 cell 高亮时变色
class TableCellBackground: UIView {
    var color: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    override var backgroundColor: UIColor? {
        get {
            color
        }
        set {
            if color != nil { return }
            color = newValue
        }
    }
    override func draw(_ rect: CGRect) {
        color?.setFill()
        UIRectFill(rect)
    }
}
