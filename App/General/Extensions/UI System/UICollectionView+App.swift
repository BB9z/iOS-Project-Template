/*
 应用级别的便捷方法: Collection view 扩展
 */
extension UICollectionView {
    // @MBDependency:2
    /**
     便捷方法，通过类名找相应 nib 注册，且 cell 的 reuse identifier 也是类名
     */
    func registerNib(with aClass: AnyClass) {
        let name = MBSwift.typeName(aClass)
        let nib = UINib(nibName: name, bundle: nil)
        register(nib, forCellWithReuseIdentifier: name)
    }

    // @MBDependency:1
    /**
     安全地刷新 collection view
     collection view 在正在滚动时，reloadData 不会立即执行，于是可能出现数据更新了，但是 collection view 状态没同步，导致崩溃
     */
    func safeReload(animated: Bool) {
        // REF
        // http://stackoverflow.com/questions/19032869/
        // http://stackoverflow.com/questions/19448488/
        UIView.setAnimationsEnabled(animated)
        performBatchUpdates({
            self.reloadSections(IndexSet(0..<numberOfSections))
        }, completion: { _ in
            UIView.setAnimationsEnabled(true)
        })
    }

    // @MBDependency:2
    /// 安全地取消选中
    func deselectItems(animated: Bool) {
        guard let items = indexPathsForSelectedItems,
              items.isNotEmpty else { return }
        performBatchUpdates({
            // 重新获取选中单元，在这个间隔内状态可能已经变了
            guard let indexPaths = self.indexPathsForSelectedItems else { return }
            for ip in indexPaths {
                self.deselectItem(at: ip, animated: animated)
            }
        }, completion: nil)
    }
}
