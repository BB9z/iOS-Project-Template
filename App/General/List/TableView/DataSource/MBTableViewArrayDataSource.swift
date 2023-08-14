/*
 MBTableViewArrayDataSource

 Copyright © 2018, 2023 BB9z.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import AppFramework
import UIKit

// @MBDependency:3
/**
 数组作为数据源的 data source

 An array-based data source for table view.
 */
class MBTableViewArrayDataSource<ObjectType>:
    NSObject,
    UITableViewDelegate,
    UITableViewDataSource
{
    /// 可选择设置，如果设置了数据源更新后会自动刷新 table view
    ///
    /// If set, the table view will automatically reload after the data source is updated.
    weak var tableView: UITableView?

    var items = [ObjectType]() {
        didSet {
            tableView?.reloadData()
        }
    }

    /**
     A closure that provides the cell identifier for a given data source and item.
     */
    var cellIdentifierProvider: ((_ dataSource: MBTableViewArrayDataSource<ObjectType>, _ item: ObjectType, _ indexPath: IndexPath) -> String)?

    /// Returns the item at the given index path.
    ///
    /// - Parameter indexPath: Throws an exception if the index path is nil.
    func item(at indexPath: IndexPath) -> ObjectType? {
        guard indexPath.row < items.count else {
            return nil
        }
        return items[indexPath.row]
    }

    /**
     Returns the items at the given index paths.
     */
    func items(at indexPaths: [IndexPath]?) -> [ObjectType]? {
        guard let indexPaths = indexPaths,
              !indexPaths.isEmpty else {
            return nil
        }
        return indexPaths.compactMap { items.element(at: $0.row) }
    }

    /**
     Returns the index path for the given item.
     */
    func indexPath(for item: ObjectType) -> IndexPath? where ObjectType: Equatable {
        guard let idx = items.firstIndex(of: item) else {
            return nil
        }
        return IndexPath(row: idx, section: 0)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = cellIdentifierProvider?(self, item(at: indexPath)!, indexPath) ?? "Cell"
        guard var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? (UITableViewCell & AnyHasItem) else {
            fatalError()
        }
        cell.setItem(item(at: indexPath))
        return cell
    }

    // MARK: - List operation
    // 这些操作会更新单元对应的数据

    /**
     删除指定单元

     Deletes the row at the given index path.

     - Parameters:
       - indexPath: 为空什么也不做。越界会断言异常
     */
    func deleteRow(at indexPath: IndexPath?, with animation: UITableView.RowAnimation) {
        guard let indexPath = indexPath else { return }
        assert(indexPath.row < items.count)
        var newItems = items
        newItems.remove(at: indexPath.row)
        self.items = newItems

        tableView?.deleteRows(at: [indexPath], with: animation)
    }

    /**
     移动 cell 到另一个位置

     Moves the row at the given index path to a new index path.

     - Parameters:
       - indexPath: 如果不合法会忽略
       - newIndexPath: 越界会断言异常
     */
    func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        guard indexPath.row < items.count else { return }
        assert(newIndexPath.row < items.count)
        var newItems = items
        let item = newItems.remove(at: indexPath.row)
        newItems.insert(item, at: newIndexPath.row)
        self.items = newItems

        tableView?.moveRow(at: indexPath, to: newIndexPath)
    }
}
