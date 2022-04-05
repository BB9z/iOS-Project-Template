//
//  File.swift
//  
//
//  Created by BB9z on 2022/4/5.
//

import UIKit

class FloatViewController: UIViewController {

}

/// 可拖拽的 view
internal final class DragableResizableView: UIView {

    @IBOutlet private weak var xConstraint: NSLayoutConstraint!
    @IBOutlet private weak var yConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    private let minSize = CGSize(width: 150, height: 100)

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
