//
//  AppDatebase+Category.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import Foundation

extension AppDatabase {
    internal func loadCategories(type: CategoryType) throws -> [Category] {
        let categories: [Category]? = try? databaseReader.read { db in
            try Category.fetchAll(db, sql: "SELECT * FROM category where type = :type", arguments: ["type": type.rawValue])
        }
        
        return categories ?? [Category]()
    }
    
    internal func loadAllCategories() throws -> [Category] {
        let categories: [Category]? = try? databaseReader.read { db in
            try Category.fetchAll(db, sql: "SELECT * FROM category")
        }
        
        return categories ?? [Category]()
    }
        
    func saveCategory(_ category: inout Category) throws {
        try dbWriter.write { db in
            try category.save(db)
        }
    }
    
    func initialCategory() throws {
        let isSetCategory = UserDefaults.standard.bool(forKey: "is_initial_category")
        if isSetCategory {
            return
        }
        
        UserDefaults.standard.set(true, forKey: "is_initial_category")
        try initExpenditureCategory()
        try initIncomeCategory()
        try initPaymentCategory()
    }
    
    private func initExpenditureCategory() throws {
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
        
        try categories.forEach {
            var category = $0
            try saveCategory(&category)
        }
    }
    
    private func initPaymentCategory() throws {
        let categories = [
            Category(id: nil, title: "category_card".localized(), icon: "💳", updateAt: Date(), type: .payment, visible: true),
            Category(id: nil, title: "category_cash".localized(), icon: "💵", updateAt: Date(), type: .payment, visible: true)
        ]
        
        try categories.forEach {
            var category = $0
            try saveCategory(&category)
        }
    }
    
    private func initIncomeCategory() throws {
        let categories = [
            Category(id: nil, title: "category_salary".localized(), icon: "💰", updateAt: Date(), type: .income, visible: true),
            Category(id: nil, title: "category_pin_money".localized(), icon: "💸", updateAt: Date(), type: .income, visible: true),
            Category(id: nil, title: "category_bonus".localized(), icon: "🎁", updateAt: Date(), type: .income, visible: true)
        ]
        
        try categories.forEach {
            var category = $0
            try saveCategory(&category)
        }
    }
    
    func loadCategory(_ id: Int64) throws -> Category? {
        return try? databaseReader.read { db in
            try Category.fetchOne(db, sql: "SELECT * FROM category where id = :id", arguments: ["id": id])
        }
    }
}
