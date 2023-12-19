//
//  CoreDataMigration.swift
//  moneybook
//
//  Created by jedmin on 2023/12/05.
//

import Foundation
import UIKit
import CoreData

class CoreDataMigration {
    static let shared = CoreDataMigration()
    
    var container: NSPersistentContainer = CoreData.shared.container
        
    func migrationIfNeeded() {
        if !isNeedMigrationCoreData() {
            return
        }
        
        NSUbiquitousKeyValueStore.default.set(true, forKey: "core_date_migration")
        NSUbiquitousKeyValueStore.default.synchronize()
        
        do {
            // 카테고리 마이그레이션
            let categories = try AppDatabase.shared.loadAllCategories()
            
            guard let categoryEntity = NSEntityDescription.entity(forEntityName: "CoreCategory", in: self.container.viewContext) else { return }
            
            categories.forEach { c in
                let category = NSManagedObject(entity: categoryEntity, insertInto: self.container.viewContext)
                category.setValue(c.id, forKey: "id")
                category.setValue(c.icon, forKey: "icon")
                category.setValue(c.title, forKey: "title")
                category.setValue(c.updateAt, forKey: "updateAt")
                category.setValue(c.type.rawValue, forKey: "type")
                category.setValue(c.visible, forKey: "visible")
                
                do {
                    try self.container.viewContext.save()
                } catch {
                    
                }
            }
            
            // item 마이그레이션
            let items = try AppDatabase.shared.loadAllItems()
            
            guard let itemEntity = NSEntityDescription.entity(forEntityName: "CoreItem", in: self.container.viewContext) else { return }
            
            items.forEach { i in
                let item = NSManagedObject(entity: itemEntity, insertInto: self.container.viewContext)
                item.setValue(i.id, forKey: "id")
                item.setValue(i.price, forKey: "price")
                item.setValue(i.type.rawValue, forKey: "type")
                item.setValue(i.kindId, forKey: "kindId")
                item.setValue(i.paymentId, forKey: "paymentId")
                item.setValue(i.date, forKey: "date")
                item.setValue(i.dateInt, forKey: "dateInt")
                item.setValue(i.updateAt, forKey: "updateAt")
                item.setValue(i.memo, forKey: "memo")
                
                do {
                    try self.container.viewContext.save()
                } catch {
                    
                }
            }
        } catch {
            
        }
    }
    
    func isNeedMigrationCoreData() -> Bool {
        let migration = NSUbiquitousKeyValueStore.default.bool(forKey: "core_date_migration")
        if migration {
            return false
        }
        
        do {
            let oldCategories = try AppDatabase.shared.loadAllCategories()
            let categories = CoreData.shared.loadAllCategories()
            if !oldCategories.isEmpty && categories.isEmpty {
                return true
            }
            
            return false
        } catch {
            
        }
        
        return false
    }
    
    func migrateId() {
        let migration = NSUbiquitousKeyValueStore.default.bool(forKey: "core_data_id_migrate")
        if migration {
            return
        }
        
        NSUbiquitousKeyValueStore.default.set(true, forKey: "core_data_id_migrate")
        NSUbiquitousKeyValueStore.default.synchronize()
        
        CoreData.shared.reorderCategory()
        CoreData.shared.reorderItem()
    }
}
