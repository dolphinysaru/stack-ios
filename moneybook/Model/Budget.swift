//
//  BudgetManager.swift
//  moneybook
//
//  Created by jedmin on 2022/01/03.
//

import Foundation
import Localize_Swift
import WidgetKit

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupId = appGroupName
        return UserDefaults(suiteName: appGroupId)!
    }
}

struct Budget {
    enum CycleTerm: Int {
        case monthly
        case weekly
        
        var title: String {
            switch self {
            case .monthly:
                return "total_spend_of_budget_month".localized()
            case .weekly:
                return "total_spend_of_budget_week".localized()
            }
        }
    }
    
    enum DayOfTheWeek: Int {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
    
    var cycleTerm: CycleTerm = .monthly
    var price: Double = 0
    var dayOfTheWeek: DayOfTheWeek = .sunday
    var startDay: Int = 1
    var priceString: String {
        "\(price)".price()
    }
    
    var totalExpend: Double {
        let items = items(types: [.expenditure])
        return Budget.sumPriceOfItems(items)
    }
    
    static func sumPriceOfItems(_ items: [Item]) -> Double {
        return items.reduce(0.0, { partialResult, item in
            return partialResult + item.price
        })
    }
    
    static func refreshTotalExpend() {
        let budget = Budget.load()
        UserDefaults.shared.set(budget.totalExpend, forKey: UserDefault.budget_totalspend)
        WidgetCenter.shared.reloadAllTimelines()
        
        NSUbiquitousKeyValueStore.default.set(budget.totalExpend, forKey: UserDefault.budget_totalspend)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    static func syncIcloud() {
        let cycleTerm = NSUbiquitousKeyValueStore.default.object(forKey: UserDefault.budget_cycle_term)
        let cycleStartDay = NSUbiquitousKeyValueStore.default.object(forKey: UserDefault.budget_cycle_start_day)
        let startDayOfWeek = NSUbiquitousKeyValueStore.default.object(forKey: UserDefault.budget_cycle_start_day_of_week)
        let price = NSUbiquitousKeyValueStore.default.double(forKey: UserDefault.budget_price)
        let isOn = NSUbiquitousKeyValueStore.default.bool(forKey: UserDefault.budget_is_on)
        let totalExpend = NSUbiquitousKeyValueStore.default.double(forKey: UserDefault.budget_totalspend)
        
        UserDefaults.shared.set(cycleTerm, forKey: UserDefault.budget_cycle_term)
        UserDefaults.shared.set(cycleStartDay, forKey: UserDefault.budget_cycle_start_day)
        UserDefaults.shared.set(startDayOfWeek, forKey: UserDefault.budget_cycle_start_day_of_week)
        UserDefaults.shared.set(price, forKey: UserDefault.budget_price)
        UserDefaults.shared.set(isOn, forKey: UserDefault.budget_is_on)
        UserDefaults.shared.set(totalExpend, forKey: UserDefault.budget_totalspend)
    }
    
    func save() {
        UserDefaults.shared.set(cycleTerm.rawValue, forKey: UserDefault.budget_cycle_term)
        UserDefaults.shared.set(startDay, forKey: UserDefault.budget_cycle_start_day)
        UserDefaults.shared.set(dayOfTheWeek.rawValue, forKey: UserDefault.budget_cycle_start_day_of_week)
        UserDefaults.shared.set(price, forKey: UserDefault.budget_price)
        UserDefaults.shared.set(true, forKey: UserDefault.budget_is_on)
        WidgetCenter.shared.reloadAllTimelines()
        
        NSUbiquitousKeyValueStore.default.set(cycleTerm.rawValue, forKey: UserDefault.budget_cycle_term)
        NSUbiquitousKeyValueStore.default.set(startDay, forKey: UserDefault.budget_cycle_start_day)
        NSUbiquitousKeyValueStore.default.set(dayOfTheWeek.rawValue, forKey: UserDefault.budget_cycle_start_day_of_week)
        NSUbiquitousKeyValueStore.default.set(price, forKey: UserDefault.budget_price)
        NSUbiquitousKeyValueStore.default.set(true, forKey: UserDefault.budget_is_on)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    static func reset() {
        UserDefaults.shared.set(CycleTerm.monthly.rawValue, forKey: UserDefault.budget_cycle_term)
        UserDefaults.shared.set(1, forKey: UserDefault.budget_cycle_start_day)
        UserDefaults.shared.set(DayOfTheWeek.monday.rawValue, forKey: UserDefault.budget_cycle_start_day_of_week)
        UserDefaults.shared.set(0, forKey: UserDefault.budget_price)
        UserDefaults.shared.set(false, forKey: UserDefault.budget_is_on)
        WidgetCenter.shared.reloadAllTimelines()
        
        NSUbiquitousKeyValueStore.default.set(CycleTerm.monthly.rawValue, forKey: UserDefault.budget_cycle_term)
        NSUbiquitousKeyValueStore.default.set(1, forKey: UserDefault.budget_cycle_start_day)
        NSUbiquitousKeyValueStore.default.set(DayOfTheWeek.monday.rawValue, forKey: UserDefault.budget_cycle_start_day_of_week)
        NSUbiquitousKeyValueStore.default.set(0, forKey: UserDefault.budget_price)
        NSUbiquitousKeyValueStore.default.set(false, forKey: UserDefault.budget_is_on)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    static func isSavedBudget() -> Bool {
        UserDefaults.shared.bool(forKey: UserDefault.budget_is_on)
    }
    
    static func syncAppGroupData() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    static func load() -> Budget {
        let termRawValue = UserDefaults.shared.integer(forKey: UserDefault.budget_cycle_term)
        let cycleTerm = Budget.CycleTerm(rawValue: termRawValue) ?? .monthly
        
        let startDay = UserDefaults.shared.integer(forKey: UserDefault.budget_cycle_start_day)
        let dayOfWeekRawValue = UserDefaults.shared.integer(forKey: UserDefault.budget_cycle_start_day_of_week)
        let dayOfWeek = DayOfTheWeek(rawValue: dayOfWeekRawValue) ?? .monday
        let price = UserDefaults.shared.double(forKey: UserDefault.budget_price)
        
        return Budget(cycleTerm: cycleTerm, price: price, dayOfTheWeek: dayOfWeek, startDay: startDay)
    }
        
    func startDate() -> Date? {
        if cycleTerm == .monthly {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d"
            guard let dayInt = Int(dayFormatter.string(from: Date())) else { return nil }
            
            var month = Date().thisMonth
            var year = Date().thisYear
            
            if dayInt < self.startDay {
                // ago month
                let aMonthComp = DateComponents(month: -1)
                guard let date = Calendar.current.date(byAdding: aMonthComp, to: Date()) else { return nil }
                month = date.getDate(format: "MM")
                year = date.getDate(format: "yyyy")
            }
            
            let day = String(format: "%02d", startDay)
            let dateString = "\(year)-\(month)-\(day)"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: dateString)
        } else {
            let dayNumber = Date().dayNumberOfWeek()
            
            var gapDay = dayNumber - dayOfTheWeek.rawValue
            if gapDay < 0 {
                gapDay += 7
            }
            
            let dayComp = DateComponents(day: -gapDay)
            return Calendar.current.date(byAdding: dayComp, to: Date())
        }
    }
    
    func endDate() -> Date? {
        guard let start = startDate() else { return nil }
        if cycleTerm == .monthly {
            guard let date = Calendar.current.date(byAdding: DateComponents(month: 1), to: start) else { return nil }
            return Calendar.current.date(byAdding: DateComponents(day: -1), to: date)
        } else {
            return Calendar.current.date(byAdding: DateComponents(day: 6), to: start)
        }
    }
    
    func items(types: [ItemType]) -> [Item] {
        guard let startDate = startDate() else { return [Item]() }
        return CoreData.shared.loadItems(fromDateInt: startDate.toInt, types: types)
    }
    
    var shortStartDay: String? {
        guard let date = startDate() else { return nil }
        return date.toShortString
    }
    
    var shortEndDay: String? {
        guard let date = endDate() else { return nil }
        return date.toShortString
    }
    
}
