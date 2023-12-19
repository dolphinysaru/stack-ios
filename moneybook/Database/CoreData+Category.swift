//
//  CoreData+Category.swift
//  moneybook
//
//  Created by jedmin on 2023/12/05.
//

import Foundation
import UIKit
import CoreData

class CoreData {
    static let shared = CoreData()
    lazy var container: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentCloudKitContainer(name: "stack")
        
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func initializeCloudKit() {
        let container = NSPersistentCloudKitContainer(name: "stack")
        try? container.initializeCloudKitSchema()
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // iCloud 변경 사항 감지
    func observeCloudChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeChanges),
                                               name: NSNotification.Name.NSPersistentStoreRemoteChange,
                                               object: nil)
    }

    @objc func mergeChanges(notification: Notification) {
        container.performBackgroundTask { context in
            context.mergeChanges(fromContextDidSave: notification)
            self.saveContext()
        }
    }
    
    func reorderCategory() {
        do {
            let fetchRequest: NSFetchRequest<CoreCategory> = CoreCategory.fetchRequest()
            let categories = try self.container.viewContext.fetch(fetchRequest)
            
            for (index, object) in categories.enumerated() {
                object.id = Int64(index)
            }
            
        } catch {
            
        }
        
        saveContext()
    }
    
    func loadAllCategories(sort: Bool = false) -> [Category] {
        do {
            let fetchRequest: NSFetchRequest<CoreCategory> = CoreCategory.fetchRequest()
            
            if sort {
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            }
            
            let categories = try self.container.viewContext.fetch(fetchRequest)
            let cate = categories.map { c in
                Category(
                    id: c.id,
                    title: c.title ?? "",
                    icon: c.icon ?? "",
                    updateAt: c.updateAt ?? Date(),
                    type: CategoryType(rawValue: c.type ?? "income") ?? .income,
                    visible: c.visible
                )
            }
            
            return cate
        } catch {
            
        }
        
        return [Category]()
    }
    
    func loadCategories(type: CategoryType) -> [Category] {
        let fetchRequest: NSFetchRequest<CoreCategory> = CoreCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@", type.rawValue)
        
        do {
            let categories = try self.container.viewContext.fetch(fetchRequest)
            let cate = categories.map { c in
                Category(
                    id: c.id,
                    title: c.title ?? "",
                    icon: c.icon ?? "",
                    updateAt: c.updateAt ?? Date(),
                    type: CategoryType(rawValue: c.type ?? "income") ?? .income,
                    visible: c.visible
                )
            }
            
            return cate
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    func loadCategory(_ id: Int64) -> Category? {
        let fetchRequest: NSFetchRequest<CoreCategory> = CoreCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try self.container.viewContext.fetch(fetchRequest)
            if let c = results.first {
                return Category(
                    id: c.id,
                    title: c.title ?? "",
                    icon: c.icon ?? "",
                    updateAt: c.updateAt ?? Date(),
                    type: CategoryType(rawValue: c.type ?? "income") ?? .income,
                    visible: c.visible
                )
            } else {
                return nil
            }
            
        } catch {
            print("Error fetching category: \(error)")
            return nil
        }
    }
    
    func resetCategory() {
        removeAllCategory()
        initialCategory()
    }
    
    func removeAllCategory() {
        let categories = loadAllCategories()
        categories.forEach { c in
            removeCategory(c)
        }
        
        NSUbiquitousKeyValueStore.default.set(false, forKey: "is_initial_category")
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func removeCategory(_ category: Category) {
        guard let id = category.id else { return }
        let fetchRequest: NSFetchRequest<CoreCategory> = CoreCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            if let itemToDelete = try self.container.viewContext.fetch(fetchRequest).first {
                self.container.viewContext.delete(itemToDelete)
                try self.container.viewContext.save()
            } else {
                print("Item with id \(id) not found")
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    func initialCategory() {
        let isSetCategory = NSUbiquitousKeyValueStore.default.bool(forKey: "is_initial_category")
        if isSetCategory {
            return
        }
        
        NSUbiquitousKeyValueStore.default.set(true, forKey: "is_initial_category")
        
        let categories = loadAllCategories()
        if !categories.isEmpty {
            return
        }
        
        initExpenditureCategory()
        initIncomeCategory()
        initPaymentCategory()
    }
    
    func saveCategory(_ c: Category, isNew: Bool = true) {
        guard let categoryEntity = NSEntityDescription.entity(forEntityName: "CoreCategory", in: self.container.viewContext) else { return }
        
        if isNew {
            let categories = loadAllCategories(sort: true)
            let id = (categories.last?.id ?? 0) + 1
            
            let category = NSManagedObject(entity: categoryEntity, insertInto: self.container.viewContext)
            category.setValue(id, forKey: "id")
            category.setValue(c.icon, forKey: "icon")
            category.setValue(c.title, forKey: "title")
            category.setValue(c.updateAt, forKey: "updateAt")
            category.setValue(c.type.rawValue, forKey: "type")
            category.setValue(c.visible, forKey: "visible")
        } else {
            guard let id = c.id else { return }
            let fetchRequest: NSFetchRequest<CoreCategory> = CoreCategory.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            
            do {
                if let existingCategory = try self.container.viewContext.fetch(fetchRequest).first {
                    // Update values of the existing category
                    existingCategory.setValue(c.icon, forKey: "icon")
                    existingCategory.setValue(c.title, forKey: "title")
                    existingCategory.setValue(c.updateAt, forKey: "updateAt")
                    existingCategory.setValue(c.type.rawValue, forKey: "type")
                    existingCategory.setValue(c.visible, forKey: "visible")
                }
            } catch {
                // Handle the error
            }
        }
        
        do {
            try self.container.viewContext.save()
        } catch {
            
        }
    }
    
    private func initExpenditureCategory() {
        let categories = [
            Category(id: nil, title: "category_food".localized(), icon: "🍽", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_transportation".localized(), icon: "🚌", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_necessity".localized(), icon: "🛒", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_cultural".localized(), icon: "🎷", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_clothes".localized(), icon: "👚", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_beauty".localized(), icon: "💇‍♀️", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_health".localized(), icon: "🏥", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_education".localized(), icon: "🎓", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_communication".localized(), icon: "📱", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_congratulations".localized(), icon: "🎐", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_saving".localized(), icon: "🏦", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_appliances".localized(), icon: "📺", updateAt: Date(), type: .expenditure, visible: true),
            Category(id: nil, title: "category_utility_bill".localized(), icon: "🚰", updateAt: Date(), type: .expenditure, visible: true)
        ]
        
        categories.forEach {
            saveCategory($0)
        }
    }
    
    private func initPaymentCategory() {
        let categories = [
            Category(id: nil, title: "category_card".localized(), icon: "💳", updateAt: Date(), type: .payment, visible: true),
            Category(id: nil, title: "category_cash".localized(), icon: "💵", updateAt: Date(), type: .payment, visible: true)
        ]
        
        categories.forEach {
            saveCategory($0)
        }
    }
    
    private func initIncomeCategory() {
        let categories = [
            Category(id: nil, title: "category_salary".localized(), icon: "💰", updateAt: Date(), type: .income, visible: true),
            Category(id: nil, title: "category_pin_money".localized(), icon: "💸", updateAt: Date(), type: .income, visible: true),
            Category(id: nil, title: "category_bonus".localized(), icon: "🎁", updateAt: Date(), type: .income, visible: true)
        ]
        
        categories.forEach {
            saveCategory($0)
        }
    }
}
