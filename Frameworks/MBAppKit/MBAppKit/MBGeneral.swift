/*!
 MBGeneral
 MBAppKit

 Copyright © 2018, 2023 BB9z.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

/// 统一的列表界面
protocol GeneralListDisplaying {
    associatedtype ListType

    var listView: ListType! { get }

    func refresh()
}
