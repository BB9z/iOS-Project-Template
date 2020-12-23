//
//  DBManager.swift
//  App
//

#if canImport(GRDB)
// https://github.com/groue/GRDB.swift
import GRDB

// swiftlint:disable identifier_name
/// 数据库单例
func AppDatabase() -> DBManager {
    if let this = _sharedInstance {
        return this
    }
    let this = DBManager()
    _sharedInstance = this
    return this
}
private var _sharedInstance: DBManager?

/**
 数据库访问界面

 参考：
 https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
 */
final class DBManager {
    let dbQueue: DatabaseQueue

    init() {
        do {
            let databaseURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("App.db")
            var config = Configuration()
            #if DEBUG
            config.prepareDatabase { db in
                db.trace { print("SQL> \($0)") }
            }
            #endif
            dbQueue = try DatabaseQueue(path: databaseURL.path, configuration: config)
            try schema.migrate(dbQueue)
        } catch {
            fatalError("数据库初始化失败 \(error)")
        }
    }

    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md
    private var schema: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("v0") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "xxx") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("type", .text).notNull()
            }
        }

//        migrator.registerMigration("v1") { db in
//            try db.alter(table: "xxx", body: { alteration in
//                alteration.add(column: "sync", .boolean)
//            })
//        }

        return migrator
    }

    lazy var workQueue = DispatchQueue(label: "AppDB", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
}

// MARK: - Database Access

/// 读写便捷方法
extension DBManager {
    typealias DatabaseWorkItem = (Database) throws -> Void

    func asyncRead(_ work: @escaping DatabaseWorkItem) {
        workQueue.async {
            do {
                try self.dbQueue.read { db in
                    try work(db)
                }
            } catch {
                AppLog().critical("读取失败 \(error)")
            }
        }
    }

    func asyncWrite(_ work: @escaping DatabaseWorkItem) {
        workQueue.async {
            do {
                try self.dbQueue.write { db in
                    try autoreleasepool {
                        try work(db)
                    }
                }
            } catch {
                AppLog().critical("写入失败 \(error)")
            }
        }
    }

    func read<T: FetchableRecord & TableRecord>(id: MBID) -> T? {
        return dbQueue.read { db -> T? in
            return try? T.fetchOne(db, key: id)
        }
    }

    /// Save (insert or update) a model.
    func save(model: inout MutablePersistableRecord) {
        do {
            try dbQueue.write { db in
                try model.save(db)
            }
        } catch {
            AppLog().critical("保存失败 \(error)")
        }
    }

    func save(_ updates: DatabaseWorkItem) {
        do {
            try dbQueue.write { db in
                try updates(db)
            }
        } catch {
            AppLog().critical("保存失败 \(error)")
        }
    }
}

/// Codable 列的存取辅助方法
extension Record {
    static func jsonDecode<T>(row: Row, column: String) -> T? where T: Decodable {
        guard let data = row.dataNoCopy(named: column) else {
            return nil
        }
        return try? Self.databaseJSONDecoder(for: column).decode(T.self, from: data)
    }
    func jsonEncode<T>(value: T, column: String) -> String? where T: Encodable {
        guard let jsonData = try? Self.databaseJSONEncoder(for: column).encode(value),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

#endif
