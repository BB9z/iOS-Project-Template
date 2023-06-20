//
//  Current.swift
//  App
//
//

import UIKit

enum Current {
    static var defualts: UserDefaults {
        Mocked.defualts ?? {
            let instance = UserDefaults.standard
            Mocked.defualts = instance
            return instance
        }()
    }

    static var identifierForVendor: String {
        Mocked.identifierForVendor ?? {
            let uuid = (UIDevice.current.identifierForVendor ?? UUID()).uuidString
            Mocked.identifierForVendor = uuid
            return uuid
        }()
    }

    static var keyWindow: UIWindow? {
        Mocked.keyWindow ?? {
            (UIApplication.shared as DeprecatedKeyWindow).keyWindow
        }()
    }
}

enum Mocked {
    static var defualts: UserDefaults?
    static var identifierForVendor: String?
    static var keyWindow: UIWindow?

    static func reset() {
        defualts = nil
        identifierForVendor = nil
        keyWindow = nil
    }
}

private protocol DeprecatedKeyWindow {
    var keyWindow: UIWindow? { get }
}
extension UIApplication: DeprecatedKeyWindow {
}

