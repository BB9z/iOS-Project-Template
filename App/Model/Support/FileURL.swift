//
//  FileURL.swift
//  App
//

/**
 文件路径集中管理
 */
enum FileURL {

    /// 数据库路径
    static func database() throws -> URL {
        try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("App.db")
    }
}
