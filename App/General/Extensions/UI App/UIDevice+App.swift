import CoreTelephony
import SystemConfiguration.CaptiveNetwork

/**
 应用级别的便捷方法
 */
extension UIDevice {

    private var currentRadioAccessTechnology: String? {
        #if targetEnvironment(macCatalyst)
        return nil
        #else
        return CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology?.values.first(where: { !$0.isEmpty })
        #endif
    }

    // @MBDependency:2
    /// 用户网络是否是移动数据
    var isUsingMobileNetwork: Bool { currentRadioAccessTechnology != nil }

    // @MBDependency:2
    /// 用户网络是否是高速移动网络
    var isUsingHighSpeedMobileNetwork: Bool {
        #if targetEnvironment(macCatalyst)
        return false
        #else
        guard let type = currentRadioAccessTechnology else {
            return false
        }
        // 只列旧类型，免于出新类型更新，新出的正常都是更快的技术
        // REF: https://en.wikipedia.org/wiki/Template:Cellular_network_standards
        switch type {
        case
//        CTRadioAccessTechnologyeHRPD    // 保留: 速度可以
//        CTRadioAccessTechnologyCDMAEVDORevB, // 保留: 速度可以
//        CTRadioAccessTechnologyHSUPA,   // 保留: 下行至少 7M，上行 5M
        CTRadioAccessTechnologyCDMAEVDORevA,  // 下行 3M，上行不到 2M
        CTRadioAccessTechnologyCDMAEVDORev0,  // 3G 早期技术，不能算高速网络
        CTRadioAccessTechnologyHSDPA,   // 上行不足，废之
        CTRadioAccessTechnologyCDMA1x,  // 属于 3G 家族，但 2G 速率
        CTRadioAccessTechnologyWCDMA,   // CT 里特指早期 3G 技术，被 HSDPA、HSUPA 取代，速率不能算高速
        CTRadioAccessTechnologyGPRS,
        CTRadioAccessTechnologyEdge:
            return false
        default:
            return true
        }
        #endif
    }

    // @MBDependency:1
    /// 获取当前加入 Wi-Fi 的 SSID
    /// iOS 12 需要在 Capabilities 选项卡中打开 Access WiFi Information
    @available(macCatalyst 14.0, *)
    var wifiSSID: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
}
