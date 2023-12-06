//
//  Item.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import Foundation
import GRDB

struct ItemInfo {
    var item: Item
    var kind: Category
    var payment: Category?
}

struct Item: Codable, Identifiable {
    var id: Int64?
    var price: Double
    var type: ItemType
    var kindId: Int64
    var paymentId: Int64?
    var date: Date
    var dateInt: Int // 조회용 - save 당시의 날짜 기준으로 Int 형태로 저장
    var updateAt: Date
    var memo: String
    
    var kind: Category? {
        return CoreData.shared.loadCategory(self.kindId)
    }
    
    var payment: Category? {
        guard let paymentId = paymentId else {
            return nil
        }
 
        return CoreData.shared.loadCategory(paymentId)
    }
}

enum ItemType: String, Codable {
    case income
    case expenditure
}

extension Item: FetchableRecord, MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension Item {
    static func sortByDate(items: [Item]) -> [[Item]] {
        var dates = [[Item]]()
        
        for (_, item) in items.enumerated() {
            if var date = dates.last, let first = date.first {
                if item.date.toString(with: "yyyyMMdd") == first.date.toString(with: "yyyyMMdd") {
                    date.append(item)
                    dates[dates.count - 1] = date
                    continue
                }
            }
            
            var its = [Item]()
            its.append(item)
            dates.append(its)
        }
                
        return dates
    }
    
    static func makeChartData(startDate: Date, endDate: Date, items: [Item], month: Bool = false) -> [String: [String: [Item]]] {
        let format = !month ? "yyyyMMdd" : "yyyyMM"
        var itemsChart = [String: [String: [Item]]]()
        let start = startDate.toString(with: format)
        let end = endDate.toString(with: format)
        
        guard let startInt = Int(start) else { return itemsChart }
        guard let endInt = Int(end) else { return itemsChart }
        
        for v in (startInt...endInt) {
            var d = [String: [Item]]()
            d[ItemType.expenditure.rawValue] = [Item]()
            d[ItemType.income.rawValue] = [Item]()
            
            itemsChart["\(v)"] = d
        }
                
        items.forEach { item in
            let date = item.date.toString(with: format)
            if var d = itemsChart[date], var i = d[item.type.rawValue] {
                i.append(item)
                d[item.type.rawValue] = i
                itemsChart[date] = d
            }
        }
        
        return itemsChart
    }
}
