/*
 MBOptionSwitch

 Copyright © 2018, 2022 BB9z.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
import UIKit

// @MBDependency:2
/**
 自动从 NSUserDefaults 读取设置并可自动更新首选项的 UISwitch
 */
final class MBOptionSwitch: UISwitch {
    /// 设定为 key 值，不是属性名
    @IBInspectable var optionKey: String?

    /// 选项是从应用共享配置还是用户个人配置读取，默认是用户配置
    @IBInspectable var sharedPreferences: Bool = false

    /// 显示与存储值是相反的
    @IBInspectable var reversed: Bool = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        onInit()
    }

    private func onInit() {
        addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            updateOn()
        }
    }

    func updateOn() {
        guard let optionKey = optionKey else {
            return
        }
        guard let defaults = sharedPreferences ? AppUserDefaultsShared() : AppUserDefaultsPrivate() else {
            AppLog().warning("Cannot read value as specified UserDefaults is nil.")
            return
        }
        var value = defaults.value(forKey: optionKey)
        if value != nil, !(value is NSNumber) {
            AppLog().error("Except \(optionKey) to be a NSNumber, got \(value as Any).")
            value = nil
        }
        let valueInConfig = (value as? NSNumber)?.boolValue ?? false
        isOn = reversed ? !valueInConfig : valueInConfig
    }

    @objc private func onValueChanged() {
        guard let defaults = sharedPreferences ? AppUserDefaultsShared() : AppUserDefaultsPrivate() else {
            AppLog().warning("Cannot save changes as specified UserDefaults is nil.")
            return
        }
        if let key = optionKey {
            defaults.setValue((reversed ? !isOn : isOn), forKey: key)
            defaults.synchronize()
        }
    }
}
