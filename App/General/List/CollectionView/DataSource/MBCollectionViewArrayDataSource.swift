/*
 MBCollectionViewArrayDataSource

 Copyright © 2018, 2023 BB9z.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import HasItem
import UIKit

// @MBDependency:4
/**
 数组作为数据源的 data source

 提供：
 - 可选在正常数据前添加一个特殊 cell

 Array data source for collection view

 Provides:
 - Optional special cell at the beginning of the normal data
 */
class MBCollectionViewArrayDataSource<ObjectType>: NSObject, UICollectionViewDataSource {

    /// 可选择设置，如果设置了数据源更新后会自动刷新 collection view
    ///
    /// Optional, if set, the collection view will be automatically refreshed after the data source is updated
    @IBOutlet weak var collectionView: UICollectionView?

    var items = [ObjectType]()

    /// 选中的对象，不支持 KVO
    ///
    /// The selected items, not KVO compliant
    var selectedItems: [ObjectType]?

    /**
     重载后保持之前的对象选中，即使顺序、元素个数已改变

     当前只支持设置 items 属性后保持不变

     Reloads the collection view and maintains the previously selected objects, even if the order and number of elements have changed

     Currently only supports keeping the selection after setting the items property
     */
    @IBInspectable var keepSelectionAfterReload: Bool = false

    /**
     Returns the object at the specified index path

     - parameter indexPath: The index path of the object to be returned

     - returns: The object at the specified index path
     */
    func item(at indexPath: IndexPath) -> ObjectType? {
        if isFirstItemIndexPath(indexPath) {
            return firstItemObject as? ObjectType
        }
        return items.element(at: indexPath.item - (hasFirstItem ? 1 : 0))
    }

    /**
     Returns an array of objects at the specified index paths

     - parameter indexPaths: The index paths of the objects to be returned

     - returns: An array of objects at the specified index paths
     */
    func items(at indexPaths: [IndexPath]) -> [ObjectType] {
        let hasFirstItem = self.hasFirstItem
        return indexPaths.compactMap { ip in
            if hasFirstItem && ip.item == 0 {
                return firstItemObject as? ObjectType
            }
            return items.element(at: ip.item - (hasFirstItem ? 1 : 0))
        }
    }

    /**
     Returns the index path of the specified object

     - parameter item: The object to find the index path for

     - returns: The index path of the specified object
     */
    func indexPath(for item: ObjectType) -> IndexPath? {
        if item as AnyObject === firstItemObject as AnyObject {
            return IndexPath(item: 0, section: 0)
        }
        if let index = items.firstIndex(where: { $0 as AnyObject === item as AnyObject }) {
            return IndexPath(item: index + (hasFirstItem ? 1 : 0), section: 0)
        }
        return nil
    }

    /// A closure that returns the cell identifier for the specified data source, item, and index path
    var cellIdentifierProvider: ((_ dataSource: MBCollectionViewArrayDataSource<ObjectType>, _ item: ObjectType, _ indexPath: IndexPath) -> String)?

    // MARK: - Additional Item

    /// 第一个特殊 cell 的标识
    /// 设置则添加
    ///
    /// The identifier of the first special cell
    /// If set, it will be added
    @IBInspectable var firstItemReuseIdentifier: String?

    /// 可选，绑定在第一个特殊 cell 的对象
    ///
    /// Optional, bound to the object of the first special cell
    var firstItemObject: Any?

    /// Returns true if the data source has a first special cell
    var hasFirstItem: Bool {
        firstItemReuseIdentifier != nil
    }

    /**
     Returns true if the specified index path is the first special cell

     - parameter indexPath: The index path to check

     - returns: True if the specified index path is the first special cell
     */
    func isFirstItemIndexPath(_ indexPath: IndexPath) -> Bool {
        return hasFirstItem && indexPath.item == 0
    }

    private func _arrayIndex(indexPath: IndexPath) -> Int {
        indexPath.item - (hasFirstItem ? 1 : 0)
    }

    private func _indexPath(arrayIndex: Int) -> IndexPath {
        IndexPath(row: arrayIndex + (hasFirstItem ? 1 : 0), section: 0)
    }

    // MARK: - List operation

    /**
     删除指定单元

     如果 indexPath 指的是第一个特殊 cell，会清空 firstItemReuseIdentifier 和 firstItemObject 属性

     Deletes the specified item

     If the index path points to the first special cell, the firstItemReuseIdentifier and firstItemObject properties will be cleared
     */
    func deleteItem(at indexPath: IndexPath) {
        if isFirstItemIndexPath(indexPath) {
            firstItemReuseIdentifier = nil
            firstItemObject = nil
            collectionView?.deleteItems(at: [indexPath])
            return
        }

        let index = _arrayIndex(indexPath: indexPath)
        var items = self.items
        items.remove(at: index)
        self.items = items
        collectionView?.deleteItems(at: [indexPath])
    }

    /**
     附加一个对象在末尾

     Appends an object to the end of the list

     - parameter item: The object to append

     - returns: 插入对象对应的 index path

               The index path of the inserted object
     */
    func append(item: ObjectType?) -> IndexPath? {
        guard let item = item else { return nil }
        var items = self.items
        items.append(item)
        self.items = items
        let indexPath = _indexPath(arrayIndex: items.count - 1)
        collectionView?.insertItems(at: [indexPath])
        return indexPath
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + (hasFirstItem ? 1 : 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = isFirstItemIndexPath(indexPath) ? firstItemReuseIdentifier ?? "Cell" : (cellIdentifierProvider?(self, item(at: indexPath)!, indexPath) ?? "Cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if var itemCell = cell as? AnyHasItem {
            itemCell.setItem(item(at: indexPath))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return !isFirstItemIndexPath(indexPath)
    }

    //    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //        if isFirstItemIndexPath(sourceIndexPath) || isFirstItemIndexPath(destinationIndexPath) {
    //            return
    //        }
    //        var items = self.items ?? []
    //        items.moveObject(from: sourceIndexPath.item - (hasFirstItem ? 1 : 0), to: destinationIndexPath.item - (hasFirstItem ? 1 : 0))
    //        self.items = items
    //    }

}
