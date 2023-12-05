//
//  AddItemManager.swift
//  moneybook
//
//  Created by jedmin on 2022/01/03.
//

import Foundation
import UIKit

class AddItemManager {
    static let shared = AddItemManager()
    
    var type: ItemType = .income
    var price: Double = 0
    var date = Date()
    var payment: Category?
    var kind: Category?
    var memo: String = ""
        
    func setup(type: ItemType, price: Double, date: Date) {
        self.type = type
        self.price = price
        self.date = date
    }
    
    func save(id: Int64? = nil) {
        guard let kindId = kind?.id else { return }
        var item = Item(
            id: id,
            price: price,
            type: type,
            kindId: kindId,
            paymentId: payment?.id,
            date: date,
            dateInt: date.toInt,
            updateAt: Date(),
            memo: memo
        )
        
        try? AppDatabase.shared.saveItem(&item)
        
        ReviewHelper.reviewIfNeeded()
    }
}
