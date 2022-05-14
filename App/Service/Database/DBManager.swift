//
//  DBManager.swift
//  App
//

#if canImport(GRDB)
// https://github.com/groue/GRDB.swift
import GRDB

/// 数据库单例
func AppDatabase() -> DBManager {  // swiftlint:disable:this identifier_name
    DBManager.shared
}

/**
 数据库访问界面

 参考：
 https://github.com/groue/GRDB.swift/blob/master/Documentation/GoodPracticesForDesigningRecordTypes.md
 */
final class DBManager {
    static let shared = DBManager()

    let dbQueue: DatabaseQueue

    init() {
        do {
            let databaseURL = try FileURL.database()
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
            try _KVRecord.createTable(db)
        }

//        migrator.registerMigration("v1") { db in
//            try db.alter(table: "xxx", body: { alteration in
//                alteration.add(column: "sync", .boolean)
//            })
//        }

        return migrator
    }

    let workQueue = DispatchQueue(label: "AppDB", qos: .default, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
}

// MARK: - Database Access

/// 读写便捷方法
extension DBManager {
    typealias DatabaseWorkItem = (Database) throws -> Void

    func asyncRead(_ work: @escaping DatabaseWorkItem) {
        workQueue.async {
            do {
                try self.dbQueue.read(work)
            } catch {
                AppLog().critical("读取失败 \(error)")
            }
        }
    }

    func asyncWrite(_ work: @escaping DatabaseWorkItem, noTransaction: Bool = false) {
        workQueue.async {
            do {
                if noTransaction {
                    try self.dbQueue.writeWithoutTransaction(work)
                } else {
                    try self.dbQueue.write(work)
                }
            } catch {
                AppLog().critical("写入失败 \(error)")
            }
        }
    }
}

extension Record {
    /// Codable 列获取辅助方法
    static func jsonDecode<T>(row: Row, column: String) -> T? where T: Decodable {
        guard let data = row.dataNoCopy(named: column) else {
            return nil
        }
        return try? Self.databaseJSONDecoder(for: column).decode(T.self, from: data)
    }

    /// Codable 列存储辅助方法
    func jsonEncode<T>(value: T, column: String) -> String? where T: Encodable {
        guard let jsonData = try? Self.databaseJSONEncoder(for: column).encode(value),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }

    /// 尽量只更新变化的列到数据库，如果记录未插入则插入
    func smartSave(_ db: Database) throws {
        do {
            try updateChanges(db)
        } catch PersistenceError.recordNotFound {
            try insert(db)
        }
    }
}

#endif
