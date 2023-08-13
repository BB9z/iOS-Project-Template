/*
 MBTableViewDataSource

 Copyright © 2018, 2020, 2023 BB9z
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import UIKit

class MBTableViewDataSource<CellType, ItemType: AnyObject>: MBListDataSource<ItemType>, UITableViewDataSource {
    weak var tableView: UITableView?
    weak var delegate: UITableViewDataSource?

    typealias CellReuseIdentifierClosure = (UITableView, IndexPath, ItemType) -> String
    typealias ConfigureCellClosure = (UITableView, CellType, IndexPath, ItemType) -> Void

    var cellReuseIdentifier: CellReuseIdentifierClosure = { tableView, indexPath, item in
        return "Cell"
    }

    var configureCell: ConfigureCellClosure = { tableView, cell, indexPath, item in
        guard let cell = cell as? UITableViewCell & Settable else { return }
        cell.setItem(item)
    }

    var animationReload = false
    var animationReloadDisabledOnFirstPage = false

    func fetchItemsFromViewController(_ viewController: Any?, nextPage: Bool, success: ((MBTableViewDataSource, [Any]) -> Void)?, completion: ((MBTableViewDataSource) -> Void)?) {
        super.fetchItemsFromViewController(viewController, nextPage: nextPage, success: { [weak self] dataSource, fetchedItems in
            guard let self = self else { return }

            if self.animationReload {
                if nextPage {
                    var indexPaths = [IndexPath]()
                    let rowCount = dataSource.items.count
                    for (idx, obj) in fetchedItems.enumerated() {
                        indexPaths.append(IndexPath(row: rowCount - idx - 1, section: 0))
                    }
                    self.tableView?.insertRows(at: indexPaths, with: .automatic)
                } else {
                    if self.animationReloadDisabledOnFirstPage {
                        self.tableView?.reloadData()
                    } else {
                        self.tableView?.reloadSections(IndexSet(integer: 0), with: .automatic)
                    }
                }
            } else {
                self.tableView?.reloadData()
            }

            success?(dataSource, fetchedItems)
        }, completion: { [weak self] dataSource in
            completion?(dataSource)
        })
    }

    func clearData() {
        prepareForReuse()
        tableView?.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.item(at: indexPath)
        let reuseIdentifier = cellReuseIdentifier(tableView, indexPath, item)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? CellType else {
            fatalError()
        }
        configureCell(tableView, cell, indexPath, item)
        return cell
    }

    func tableView(_ tableView: UITableView, cellReuseIdentifierForRowAtIndexPath indexPath: IndexPath) -> String {
        let item = self.item(at: indexPath)
        return cellReuseIdentifier(tableView, indexPath, item)
    }

    func reconfigVisableCells() {
        guard let tableView = tableView else { return }
        for case let cell as UITableViewCell & Settable in tableView.visibleCells {
            guard let indexPath = tableView.indexPath(for: cell) else { continue }
            configureCell(tableView, cell, indexPath, item(at: indexPath))
        }
    }

    func removeItem(_ item: Any?, with animation: UITableView.RowAnimation) {
        guard let item = item else { return }
        guard let indexPath = indexPath(for: item) else { return }
        items.remove(at: indexPath.row)
        if items.isEmpty && pageEnd {
            empty = true
        }
        tableView?.deleteRows(at: [indexPath], with: animation)
    }

    func appendItem(_ item: Any?, with animation: UITableView.RowAnimation) -> IndexPath? {
        guard let item = item else { return nil }
        guard indexPath(for: item) == nil else { return nil }
        items.append(item)
        guard let indexPath = indexPath(for: item) else { return nil }
        if empty {
            empty = false
        }
        guard let tableView = tableView else { return nil }
        if !tableView.window {
            return indexPath
        }
        tableView.insertRows(at: [indexPath], with: animation)
        return indexPath
    }

    override func setItems(withRawData responseData: Any?) {
        super.setItems(withRawData: responseData)
        tableView?.reloadData()
    }
}

protocol Settable {
    associatedtype ItemType
    func setItem(_ item: ItemType)
}

extension UITableViewCell: Settable {
    typealias ItemType = Any

    func setItem(_ item: Any) {
        // Implement this method in your UITableViewCell subclass
    }
}
