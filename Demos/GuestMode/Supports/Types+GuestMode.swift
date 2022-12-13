/*
 对特殊约定的数据类型进行定义以示区分
 */

/// 账号系统 ID 的类型
#if MBUserStringUID
typealias AccountID = String
#else
typealias AccountID = Int64
#endif

/* 🔰 例如

/// 服务器时长用的是整型
typealias Duration = Int32

/// 从 1 开始的序号
typealias NIdx = Int
 */
