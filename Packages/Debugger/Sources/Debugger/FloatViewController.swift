//
//  File.swift
//  
//
//  Created by BB9z on 2022/4/5.
//

import UIKit

class FloatViewController: UIViewController {
    typealias Item = DebugActionItem

    class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
        private(set) var items = [Item]()

        var tableView: UITableView? {
            didSet {
                tableView?.dataSource = self
                tableView?.delegate = self
            }
        }

        func update(items: [Item]) {
            self.items = items
            tableView?.reloadData()
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            items.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = items[indexPath.row].title
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            items[indexPath.row].perform()
        }
    }

    /// 全局操作
    @IBOutlet private weak var globalList: UITableView!
    /// 当前视图中的操作
    @IBOutlet private weak var contextList: UITableView!
    private lazy var globalListDatasource = DataSource()
    private lazy var contextListDatasource = DataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        globalListDatasource.tableView = globalList
        contextListDatasource.tableView = contextList
    }

    @IBAction func refresh() {
        var globalItems = [
            DebugActionItem(title: "视图层级", action: Debugger.showViewControllerHierarchy),
            DebugActionItem(title: "模拟内存警告", action: Debugger.simulateMemoryWarning),
        ]
        globalItems.append(DebugActionItem(title: "隐藏左下调试按钮片刻", action: Debugger.hideControlCenterForAwhile))
        globalListDatasource.update(items: globalItems)
    }

    @IBAction private func onHide(_ sender: Any) {
        Debugger.hideControlCenter()
    }
}

/// 可调尺寸、位置的容器
internal final class DragableResizableView: UIView {

    @IBOutlet private weak var xConstraint: NSLayoutConstraint!
    @IBOutlet private weak var yConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    private let minSize = CGSize(width: 60 + 50 + 100, height: 100 + 50)

    @IBAction private func onDrag(_ sender: UIPanGestureRecognizer) {
        let offset = sender.translation(in: self)
        sender.setTranslation(.zero, in: self)
        xConstraint.constant += offset.x
        yConstraint.constant += offset.y
    }

    @IBAction private func onResize(_ sender: UIPanGestureRecognizer) {
        let offset = sender.translation(in: self)
        sender.setTranslation(.zero, in: self)
        let width = max(widthConstraint.constant + offset.x * 2, minSize.width).rounded()
        let height = max(heightConstraint.constant + offset.y * 2, minSize.height).rounded()
        if abs(widthConstraint.constant - width) > 1 {
            widthConstraint.constant = width
        }
        if abs(heightConstraint.constant - height) > 1 {
            heightConstraint.constant = height
        }
    }
}
