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
    var isNew: Bool = false
    
    func setup(type: ItemType, price: Double, date: Date, isNew: Bool) {
        self.type = type
        self.price = price
        self.date = date
        self.isNew = isNew
    }
    
    func save(id: Int64? = nil) {
        guard let kindId = kind?.id else { return }
        let item = Item(
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
        
        CoreData.shared.saveItem(item, isNew: isNew)
        ReviewHelper.reviewIfNeeded()
    }
}
