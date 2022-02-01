//
//  Category.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import Foundation
import GRDB

struct Category: Codable, Identifiable {
    var id: Int64?
    var title: String
    var icon: String // emoji
    var updateAt: Date
    var type: CategoryType
    var visible: Bool
}

enum CategoryType: String, Codable {
    case income
    case expenditure
    case payment
    
    var title: String {
        switch self {
        case .income:
            return "income_category_title".localized()
        case .expenditure:
            return "expenditure_category_title".localized()
        case .payment:
            return "payment_category_title".localized()
        }
    }
    
    var editViewTitle: String {
        switch self {
        case .income:
            return "income_category_edit_title".localized()
        case .expenditure:
            return "expenditure_category_edit_title".localized()
        case .payment:
            return "payment_category_edit_title".localized()
        }
    }
}

extension Category: FetchableRecord, MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}
