//
//  DemoVCs.swift
//  Navigation
//

/// 样式设置演示页
class StyleConfigViewController: UIViewController {
    var barColorIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        if barColorIndex < currentPageColorControl.numberOfSegments {
            currentPageColorControl.selectedSegmentIndex = barColorIndex
        }
        updateStyleAttributes()
    }

    @IBOutlet private weak var currentPageColorControl: UISegmentedControl!
    @IBAction private func onCurrentBarColorChange(_ sender: Any) {
        updateStyleAttributes()
        updateNavigationAppearance(animated: true)
    }
    private func updateStyleAttributes() {
        preferredNavigationBarColor = colorForSegmentIndex(currentPageColorControl.selectedSegmentIndex)
    }

    @IBOutlet private weak var nextPageColorControl: UISegmentedControl!

    private func colorForSegmentIndex(_ idx: Int) -> UIColor? {
        switch idx {
        case 1:
            return #colorLiteral(red: 0.5, green: 0.1487184289, blue: 0.1545731218, alpha: 1)
        case 2:
            return #colorLiteral(red: 0.2151789291, green: 0.1487585616, blue: 0.5, alpha: 1)
        default:
            return nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StyleConfigViewController {
            vc.barColorIndex = nextPageColorControl.selectedSegmentIndex
            vc.title = "Page \(navigationController?.viewControllers.count ?? 0)"
            return
        }
        super.prepare(for: segue, sender: sender)
    }
}

class ViewAppearWayRootViewController: UIViewController {
    @IBAction private func onDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

/// 在 viewWillAppear 中设置样式的演示，不推荐
class StyleConfigAppearViewController: UIViewController {
    var barColorIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        if barColorIndex < currentPageColorControl.numberOfSegments {
            currentPageColorControl.selectedSegmentIndex = barColorIndex
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStyle()
    }

    @IBOutlet private weak var currentPageColorControl: UISegmentedControl!
    @IBAction private func onCurrentBarColorChange(_ sender: Any) {
        updateStyle()
    }
    private func updateStyle() {
        navigationController?.navigationBar.barTintColor = colorForSegmentIndex(currentPageColorControl.selectedSegmentIndex)
    }

    @IBOutlet private weak var nextPageColorControl: UISegmentedControl!

    private func colorForSegmentIndex(_ idx: Int) -> UIColor? {
        switch idx {
        case 1:
            return #colorLiteral(red: 0.5, green: 0.1487184289, blue: 0.1545731218, alpha: 1)
        case 2:
            return #colorLiteral(red: 0.2151789291, green: 0.1487585616, blue: 0.5, alpha: 1)
        default:
            return nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StyleConfigAppearViewController {
            vc.barColorIndex = nextPageColorControl.selectedSegmentIndex
            vc.title = "Page \(navigationController?.viewControllers.count ?? 0)"
            return
        }
        super.prepare(for: segue, sender: sender)
    }
}
