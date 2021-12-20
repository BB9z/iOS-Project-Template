//
//  DBManager+KVStorage.swift
//  App
//

#if canImport(GRDB)
import GRDB

extension DBManager {
    /// 简单 KV 存储，读
    func value(key: String, in db: Database? = nil) -> String? {
        func action(in db: Database) throws -> String? {
            let record = try _KVRecord.fetchOne(db, key: key.description)
            return record?.value
        }
        do {
            if let db = db {
                return try action(in: db)
            } else {
                return try dbQueue.read(action(in:))
            }
        } catch {
            AppLog().critical("\(error)")
            return nil
        }
    }

    /// 简单 KV 存储，写
    func setValue(string value: String?, key: String, in db: Database? = nil) {
        func action(_ db: Database) throws {
            if value == nil {
                try _KVRecord.deleteOne(db, key: key)
                return
            }
            if var record = try? _KVRecord.fetchOne(db, key: key.description) {
                if record.value != value {
                    record.value = value
                    try record.update(db)
                }
            } else {
                let record = _KVRecord(key: key.description, value: value)
                try record.insert(db)
            }
        }
        Do.try {
            if let db = db {
                try action(db)
            } else {
                try dbQueue.write(action(_:))
            }
        }
    }

    /// 简单 KV 存储，读
    func value<T: Decodable>(type: T.Type, key: String, in db: Database? = nil) -> T? {
        if let raw = value(key: key, in: db) {
            return try? JSONDecoder().decode(type, from: raw)
        }
        return nil
    }

    /// 简单 KV 存储，写
    func setValue<T: Encodable>(_ value: T, key: String, in db: Database? = nil) {
        Do.try {
            let raw = try JSONEncoder().encodeToString(value)
            setValue(string: raw, key: key, in: db)
        }
    }
}

private struct _KVRecord: Codable, TableRecord, FetchableRecord, PersistableRecord {
    var key: String
    var value: String?

    static var databaseTableName: String { "kv" }

    static func createTable(_ db: Database) throws {
        try db.create(table: Self.databaseTableName, body: { table in
            table.primaryKey(["key"], onConflict: .replace)
            table.column("key", .text)
            table.column("value", .text)
        })
    }
}

#endif
