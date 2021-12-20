//
//  NavigationController+Tab.swift
//  App
//

/// tab 序号定义
enum NavigationTab: Int {
    case home = 0, topic, more, count
    static let `default` = NavigationTab.home
    static let login = NSNotFound
}

/// 导航 tab 支持
extension NavigationController: MBControlGroupDelegate {

    /// 控制 tab item 选中状态
    var tabItems: MBControlGroup {
        guard let bar = bottomBar as? MBControlGroup else {
            fatalError("使用底部 tab 时，bottomBar 必须是 MBControlGroup")
        }
        return bar
    }

    /// 存储各个 tab 的 view controller
    private var tabControllers: NSPointerArray {
        if let array = tabControllersAssociation[self] {
            return array
        }
        let array = NSPointerArray(options: .strongMemory)
        array.count = NavigationTab.count.rawValue
        tabControllersAssociation[self] = array
        return array
    }

    /// 可以控制释放允许选中某一 tab
    func controlGroup(_ controlGroup: MBControlGroup, shouldSelectControlAt index: Int) -> Bool {
        return true
    }

    func selectTab(_ tabKind: NavigationTab) {
        let tabIndex = tabKind.rawValue
        if tabItems.selectIndex != tabIndex {
            tabItems.selectIndex = tabIndex
        }
        let newVCs = [ viewControllerForTab(tabKind) ]
        if viewControllers != newVCs {
            viewControllers = newVCs
        }
    }

    @IBAction private func onTabSelect(_ sender: MBControlGroup) {
        guard let tabKind = NavigationTab(rawValue: sender.selectIndex) else {
            fatalError()
        }
        selectTab(tabKind)
    }

    private func viewControllerForTab(_ tabKind: NavigationTab) -> UIViewController {
        let tabIndex = tabKind.rawValue
        if let vc = tabControllers.object(at: tabIndex) as? UIViewController {
            return vc
        }
        var vc: UIViewController!
        // 🔰 调整每个 tab 对应的 view controller
        switch tabKind {
        case .home:
            vc = HomeViewController.newFromStoryboard()
        case .topic:
            vc = TopicRecommendListController.newFromStoryboard()
        case .more:
            vc = MoreViewController.newFromStoryboard()
        default:
            fatalError()
        }
        vc.prefersBottomBarShown = true
        tabControllers.replaceObject(at: tabIndex, withObject: vc)
        return vc
    }

    /// 释放未显示的 tab vc
    func releaseTabViewControllersIfNeeded() {
        let idx = tabItems.selectIndex
        for i in 0..<tabControllers.count where i != idx {
            tabControllers.replacePointer(at: i, withPointer: nil)
        }
    }
}
private let tabControllersAssociation = AssociatedObject<NSPointerArray>()

extension NavigationController: MBDebugNavigationReleaseChecking {
    func debugShouldIgnoralCheckRelease(for viewController: UIViewController!) -> Bool {
        return (tabControllers.allObjects as NSArray).contains(viewController!)
    }
}
