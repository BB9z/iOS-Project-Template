/*
 DescriptionViewController.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

/// 展示文本内容的页面
internal final class DescriptionViewController: UIViewController {
    static func new() -> DescriptionViewController {
        // swiftlint:disable:next force_cast
        Debugger.storyboard.instantiateViewController(withIdentifier: "DescriptionViewController") as! DescriptionViewController
    }

    var item: String!
    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = item
    }

    @IBAction private func onCopy(_ sender: Any) {
        UIPasteboard.general.string = item
    }
}
