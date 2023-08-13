/*
 对特殊约定的数据类型进行定义以示区分
 */

/// 账号系统 ID 的类型
typealias AccountID = String

typealias MBIdentifier = String

/// 专用于标示日期哪一天
typealias MBDateDayIdentifier = String

/// 整形 ID
typealias MBID = Int64

/* 🔰 例如

/// 服务器时长用的是整型
typealias Duration = Int32

/// 从 1 开始的序号
typealias NIdx = Int
 */

protocol ListDisplaying {
    associatedtype ListType

    var listView: ListType { get }
}
