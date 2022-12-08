/*
 FloatViewController.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/// 主浮窗
internal final class FloatViewController: UIViewController {
    typealias Item = DebugActionItem

    private final class DataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
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
            let action = items[indexPath.row]
            if shouldHideOnSelect {
                if action.action != #selector(FloatViewController.onSwitchAutoHide) {
                    Debugger.hideControlCenter()
                }
            }
            action.perform()
        }

        var shouldHideOnSelect = false
    }

    @IBOutlet private weak var contentView: UIView!
    /// 全局操作
    @IBOutlet private weak var globalList: UITableView!
    /// 当前视图中的操作
    @IBOutlet private weak var contextList: UITableView!
    private lazy var globalListDatasource = DataSource()
    private lazy var contextListDatasource = DataSource()

    internal var customView: UIView? {
        didSet {
            if let cView = customView {
                contentView.addSubview(cView)
                if cView.translatesAutoresizingMaskIntoConstraints {
                    cView.frame = contentView.bounds
                } else {
                    contentView.addConstraints([
                        cView.topAnchor.constraint(equalTo: contentView.topAnchor),
                        cView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                        cView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                        cView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                    ])
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        globalListDatasource.tableView = globalList
        contextListDatasource.tableView = contextList
    }

    // MARK: - 操作

    @IBAction func refresh() {
        var globalItems = Debugger.internalGlobalItems()
        let autoHideItem = DebugActionItem(isAutoHideAfterPerformAction ? "操作自动隐藏: 开启" : "操作自动隐藏: 关闭", target: self, #selector(onSwitchAutoHide))
        globalItems.append(autoHideItem)
        globalListDatasource.update(items: globalItems)
        contextListDatasource.update(items: contextItems(currentVC: Debugger.currentViewController))
        customView = nil
    }

    private func contextItems(currentVC: UIViewController?) -> [DebugActionItem] {
        var items = [DebugActionItem]()
        var viewController = currentVC
        while viewController != nil {
            if let source = viewController as? DebugActionSource {
                items.append(contentsOf: source.debugActionItems())
            }
            viewController = viewController?.parent
        }
        return items
    }

    // MARK: - 隐藏控制

    private var isAutoHideAfterPerformAction: Bool {
        get {
            globalListDatasource.shouldHideOnSelect
        }
        set {
            globalListDatasource.shouldHideOnSelect = newValue
            contextListDatasource.shouldHideOnSelect = newValue
        }
    }
    @objc private func onSwitchAutoHide() {
        isAutoHideAfterPerformAction.toggle()
        refresh()
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
