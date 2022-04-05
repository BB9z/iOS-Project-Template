/*
 TriggerButton.swift
 Debugger

 Copyright © 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import Combine
import UIKit

internal final class TriggerButton: UIButton {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        userDefaultsObserver = NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification, object: UserDefaults.standard).sink(receiveValue: { [weak self] notice in
            self?.updateHidden()
        })
        updateHidden()
    }

    private func updateHidden() {
        dispatchPrecondition(condition: .onQueue(.main))
        isHidden = !Debugger.isDebugEnabled
    }

    private var userDefaultsObserver: AnyCancellable?
}
