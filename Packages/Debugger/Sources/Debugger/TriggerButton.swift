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
        if floatWindow.rootViewController == nil {
            let storyboard = UIStoryboard(name: "Debugger", bundle: Bundle.module)
            let vc = storyboard.instantiateInitialViewController()
            floatWindow.rootViewController = vc
        }
        floatWindow.frame = window!.screen.bounds
        floatWindow.isHidden = false
        floatWindow.windowLevel = .alert + 1
    }

    private lazy var floatWindow: UIWindow = {
        let win = UIWindow()
        win.backgroundColor = nil
        win.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return win
    }()

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
