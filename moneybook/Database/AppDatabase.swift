//
//  AppDatabase.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import Foundation
import GRDB

class AppDatabase {
    init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    internal let dbWriter: DatabaseWriter
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("createItem") { db in
            try db.create(table: "item", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("price", .double).notNull()
                t.column("type", .text).notNull()
                t.column("kindId", .integer).notNull()
                t.column("paymentId", .integer)
                t.column("date", .date).notNull()
                t.column("dateInt", .integer).notNull()
                t.column("updateAt", .date).notNull()
                t.column("memo", .text).notNull()
            })
        }
        
        migrator.registerMigration("createCategory") { db in
            try db.create(table: "category", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("icon", .text).notNull()
                t.column("updateAt", .date).notNull()
                t.column("type", .text).notNull()
                t.column("visible", .boolean).notNull()
            })
        }
                
        return migrator
    }
}

extension AppDatabase {
    /// Provides a read-only access to the database
    var databaseReader: DatabaseReader {
        dbWriter
    }
}

extension AppDatabase {
    /// The database for the application
    static let shared = makeShared()
    static let old = oldShared()
    
    internal static func migrateAppGroup() throws {
        let categories = try AppDatabase.old.loadAllCategories()
        try categories.forEach {
            var category = $0
            try AppDatabase.shared.saveCategory(&category)
        }
        
        let items = try AppDatabase.old.loadAllItems()
        try items.forEach {
            var item = $0
            try AppDatabase.shared.saveItem(&item)
        }
    }
    
    private static func makeShared() -> AppDatabase {
        do {
            // Create a folder for storing the SQLite database, as well as
            // the various temporary files created during normal database
            // operations (https://sqlite.org/tempfiles.html).
            let fileManager = FileManager()
            let folderURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupName)!
//                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                .appendingPathComponent("database", isDirectory: true)
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to a database on disk
            // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let dbPool = try DatabasePool(path: dbURL.path)
            
            // Create the AppDatabase
            let appDatabase = try AppDatabase(dbPool)
                        
            return appDatabase
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
    
    private static func oldShared() -> AppDatabase {
        do {
            // Create a folder for storing the SQLite database, as well as
            // the various temporary files created during normal database
            // operations (https://sqlite.org/tempfiles.html).
            let fileManager = FileManager()
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("database", isDirectory: true)
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            // Connect to a database on disk
            // See https://github.com/groue/GRDB.swift/blob/master/README.md#database-connections
            let dbURL = folderURL.appendingPathComponent("db.sqlite")
            let dbPool = try DatabasePool(path: dbURL.path)
            
            // Create the AppDatabase
            let appDatabase = try AppDatabase(dbPool)
                        
            return appDatabase
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            //
            // Typical reasons for an error here include:
            // * The parent directory cannot be created, or disallows writing.
            // * The database is not accessible, due to permissions or data protection when the device is locked.
            // * The device is out of space.
            // * The database could not be migrated to its latest schema version.
            // Check the error message to determine what the actual problem was.
            fatalError("Unresolved error \(error)")
        }
    }
}
