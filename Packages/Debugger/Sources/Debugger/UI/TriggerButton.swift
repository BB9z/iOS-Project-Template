/*
 TriggerButton.swift
 Debugger

 Copyright © 2022-2023 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

import UIKit

internal final class TriggerButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }

    private func onInit() {
        addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    @objc private func onTap() {
        Debugger.toggleControlCenterVisibleFromButton()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil { return }
        if userDefaultsObserver == nil {
            userDefaultsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: UserDefaults.standard, queue: .main) { [weak self] _ in
                self?.updateHidden()
            }
        }
        updateHidden()
    }

    private func updateHidden() {
        isHidden = !Debugger.isDebugEnabled
    }

    private var userDefaultsObserver: Any?

    deinit {
        if let observer = userDefaultsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
