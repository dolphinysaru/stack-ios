//
//  UserDefaults.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import Foundation

let appGroupName = "group.com.ckmin.stack"

enum UserDefault {
    static let budget_cycle_term = "budget_cycle_term"
    static let budget_cycle_start_day = "budget_cycle_start_day"
    static let budget_cycle_start_day_of_week = "budget_cycle_start_day_of_week"
    static let budget_price = "budget_price"
    static let budget_is_on = "budget_is_on"
    static let budget_totalspend = "budget_totalspend"
    
    static let currency_is_set = "currency_is_set"
    static let currency_symbol = "currency_symbol"
    static let currency_code = "currency_code"
}
