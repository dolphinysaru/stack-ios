//
//  AppDatabase+Item.swift
//  moneybook
//
//  Created by jedmin on 2022/01/03.
//

import Foundation
import GRDB

extension AppDatabase {
    func loadAllItems() throws -> [Item] {
        let items = try? databaseReader.read { db in
            try Item.fetchAll(db)
        }
        
        return items ?? [Item]()
    }
    
    func saveItem(_ item: inout Item) throws {
        try dbWriter.write { db in
            try item.save(db)
        }
        
        CloudDataManager.sharedInstance.copyFileToCloud()
    }
    
    func loadItem(_ id: Int64) throws -> Item? {
        return try? databaseReader.read { db in
            try Item.fetchOne(db, sql: "SELECT * FROM Item where id = :id", arguments: ["id": id])
        }
    }
    
    func loadItems(dateInt: Int, types: [ItemType]) throws -> [Item] {
        let items: [Item]? = try? databaseReader.read { db in
            try Item.fetchAll(db, sql: "SELECT * FROM Item WHERE dateInt = :dateInt", arguments: ["dateInt": dateInt])
        }
                
        return items?.filter { item in
            return types.contains { item.type == $0 }
        }.sorted(by: { $0.date < $1.date }) ?? [Item]()
    }
    
    
    func loadItems(fromDateInt: Int, toDateInt: Int, sign: String = "<=", types: [ItemType]) throws -> [Item] {
        let items: [Item]? = try? databaseReader.read { db in
            try Item.fetchAll(db, sql: "SELECT * FROM Item WHERE dateInt >= '\(fromDateInt)' AND dateInt \(sign) '\(toDateInt)'")
        }
                
        return items?.filter { item in
            return types.contains { item.type == $0 }
        }.sorted(by: { $0.date < $1.date }) ?? [Item]()
    }
    
    func loadItems(fromDateInt: Int, types: [ItemType]) throws -> [Item] {
        let items: [Item]? = try? databaseReader.read { db in
            try Item.fetchAll(db, sql: "SELECT * FROM Item where dateInt >= '\(fromDateInt)'")
        }
                
        return items?.filter { item in
            return types.contains { item.type == $0 }
        }.sorted(by: { $0.date < $1.date }) ?? [Item]()
    }
    
    func removeItem(_ item: Item) throws {
        guard let id = item.id else { return }
        
        try dbWriter.write { db in
            _ = try Item.deleteAll(db, ids: [id])
        }
    }
}
