//
//  CoreData+Item.swift
//  moneybook
//
//  Created by jedmin on 2023/12/05.
//

import Foundation
import CoreData

extension CoreData {
    func loadAllItems() -> [Item] {
        do {
            let items = try self.container.viewContext.fetch(CoreItem.fetchRequest()) as! [CoreItem]
            let itemss = items.map { i in
                Item(
                    id: i.id,
                    price: i.price,
                    type: ItemType(rawValue: i.type ?? "income") ?? .income,
                    kindId: i.kindId,
                    date: i.date ?? Date(),
                    dateInt: Int(i.dateInt),
                    updateAt: i.updateAt ?? Date(),
                    memo: i.memo ?? ""
                )
            }
            
            return itemss
        } catch {
            
        }
        
        return [Item]()
    }
    
    func reorderItem() {
        do {
            let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
            let items = try self.container.viewContext.fetch(fetchRequest)
            
            for (index, object) in items.enumerated() {
                object.id = Int64(index)
            }
            
        } catch {
            
        }
        
        saveContext()
    }
    
    func fetchItemCount() -> Int {
        let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()

        do {
            let count = try self.container.viewContext.count(for: fetchRequest)
            return count
        } catch {
            print("Error fetching category count: \(error)")
            return 0
        }
    }
    
    func loadItems(sort: Bool = false) -> [CoreItem] {
        do {
            let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
            
            if sort {
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            }
            
            let items = try self.container.viewContext.fetch(fetchRequest)
            return items
        } catch {
            
        }
        
        return [CoreItem]()
    }
    
    func saveItem(_ i: Item, isNew: Bool = true) {
        guard let itemEntity = NSEntityDescription.entity(forEntityName: "CoreItem", in: self.container.viewContext) else { return }
        
        if isNew {
            let items = loadItems(sort: true)
            let id = (items.last?.id ?? 0) + 1
            
            let item = NSManagedObject(entity: itemEntity, insertInto: self.container.viewContext)
            item.setValue(id, forKey: "id")
            item.setValue(i.price, forKey: "price")
            item.setValue(i.type.rawValue, forKey: "type")
            item.setValue(i.kindId, forKey: "kindId")
            item.setValue(i.paymentId, forKey: "paymentId")
            item.setValue(i.date, forKey: "date")
            item.setValue(i.dateInt, forKey: "dateInt")
            item.setValue(i.updateAt, forKey: "updateAt")
            item.setValue(i.memo, forKey: "memo")
        } else {
            guard let id = i.id else { return }
            let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            
            do {
                if let item = try self.container.viewContext.fetch(fetchRequest).first {
                    // Update values of the existing category
                    item.setValue(i.price, forKey: "price")
                    item.setValue(i.type.rawValue, forKey: "type")
                    item.setValue(i.kindId, forKey: "kindId")
                    item.setValue(i.paymentId, forKey: "paymentId")
                    item.setValue(i.date, forKey: "date")
                    item.setValue(i.dateInt, forKey: "dateInt")
                    item.setValue(i.updateAt, forKey: "updateAt")
                    item.setValue(i.memo, forKey: "memo")
                }
            } catch {
                // Handle the error
            }
        }
        
        do {
            try self.container.viewContext.save()
        } catch {
            
        }
        
        Budget.refreshTotalExpend()
    }
    
    func removeItem(_ item: Item) {
        guard let id = item.id else { return }
        let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
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
        
        Budget.refreshTotalExpend()
    }
    
    func loadItem(_ id: Int64) -> Item? {
        let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try self.container.viewContext.fetch(fetchRequest)
            
            if let i = results.first {
                let item = Item(
                    id: i.id,
                    price: i.price,
                    type: ItemType(rawValue: i.type ?? "income") ?? .income,
                    kindId: i.kindId,
                    paymentId: i.paymentId,
                    date: i.date ?? Date(),
                    dateInt: Int(i.dateInt),
                    updateAt: i.updateAt ?? Date(),
                    memo: i.memo ?? ""
                )
                return item
            } else {
                return nil
            }
        } catch {
            print("Error fetching data: \(error)")
            return nil
        }
    }
    
    func loadItems(dateInt: Int, types: [ItemType]) -> [Item] {
        let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateInt == %ld", dateInt)

        do {
            var items = try self.container.viewContext.fetch(fetchRequest)
            items = items.filter { item in
                return types.contains { item.type == $0.rawValue }
            }
            items.sort { $0.date ?? Date() < $1.date ?? Date() }
            return items.map { i in
                Item(
                    id: i.id,
                    price: i.price,
                    type: ItemType(rawValue: i.type ?? "income") ?? .income,
                    kindId: i.kindId,
                    date: i.date ?? Date(),
                    dateInt: Int(i.dateInt),
                    updateAt: i.updateAt ?? Date(),
                    memo: i.memo ?? ""
                )
            }
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }

    func loadItems(fromDateInt: Int, toDateInt: Int, sign: String = "<=", types: [ItemType]) -> [Item] {
        let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateInt >= %ld AND dateInt \(sign) %ld", fromDateInt, toDateInt)

        do {
            var items = try self.container.viewContext.fetch(fetchRequest)
            items = items.filter { item in
                return types.contains { item.type == $0.rawValue }
            }
            items.sort { $0.date ?? Date() < $1.date ?? Date() }
            return items.map { i in
                Item(
                    id: i.id,
                    price: i.price,
                    type: ItemType(rawValue: i.type ?? "income") ?? .income,
                    kindId: i.kindId,
                    date: i.date ?? Date(),
                    dateInt: Int(i.dateInt),
                    updateAt: i.updateAt ?? Date(),
                    memo: i.memo ?? ""
                )
            }
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }

    func loadItems(fromDateInt: Int, types: [ItemType]) -> [Item] {
        let fetchRequest: NSFetchRequest<CoreItem> = CoreItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dateInt >= %ld", fromDateInt)

        do {
            var items = try self.container.viewContext.fetch(fetchRequest)
            items = items.filter { item in
                return types.contains { item.type == $0.rawValue }
            }
            items.sort { $0.date ?? Date() < $1.date ?? Date() }
            return items.map { i in
                Item(
                    id: i.id,
                    price: i.price,
                    type: ItemType(rawValue: i.type ?? "income") ?? .income,
                    kindId: i.kindId,
                    date: i.date ?? Date(),
                    dateInt: Int(i.dateInt),
                    updateAt: i.updateAt ?? Date(),
                    memo: i.memo ?? ""
                )
            }
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }
    
}
