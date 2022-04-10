/*
 ListDiscovering.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/// 自定义的列表类适配该协议以支持单元检查
/// UITableView 和 UICollectionView 直接支持
public protocol VisableCellInspecting {
    /// 返回列表可见单元
    func visibleCells() -> [Any]
}

func inspectListCell(_ vc: UIViewController?) -> [Any]? {
    var viewController = vc
    while let current = viewController {
        if let anyList = possiableList(current) {
            if let table = anyList as? UITableView {
                return table.visibleCells
            }
            if let collection = anyList as? UICollectionView {
                return collection.visibleCells
            }
            if let list = anyList as? VisableCellInspecting {
                return list.visibleCells()
            }
        }
        viewController = current.parent
    }
    return nil
}

func listInspectingAction(_ vc: UIViewController?) -> DebugActionItem? {
    var viewController = vc
    while let current = viewController {
        if possiableList(current) != nil {
            return DebugActionItem("检测列表可见单元") {
                Debugger.inspectVisableCell()
            }
        }
        viewController = current.parent
    }
    return nil
}

func possiableList(_ obj: Any) -> Any? {
    if let table = obj as? UITableViewController {
        return table.tableView
    }
    if let collection = obj as? UICollectionViewController {
        return collection.collectionView
    }
    let labels = Debugger.inspectingListPropertyNames
    for (label, value) in Mirror(reflecting: obj).children {
        if let label = label,
           labels.contains(label),
           isList(value) {
            return value
        }
    }
    return nil
}

func isList(_ obj: Any) -> Bool {
    obj is UITableView || obj is UICollectionView || obj is VisableCellInspecting
}
