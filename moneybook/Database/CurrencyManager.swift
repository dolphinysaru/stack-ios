//
//  CurrencyManager.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import Foundation

struct Currency {
    let symbol: String
    let code: String
}

extension Currency: Equatable, Hashable {
    internal static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.symbol == rhs.symbol && lhs.code == rhs.code
    }
}

struct CurrencyManager {
    static func migrate() {
        let symbol = UserDefaults.standard.string(forKey: UserDefault.currency_symbol)
        UserDefaults.shared.set(symbol, forKey: UserDefault.currency_symbol)
        
        let code = UserDefaults.standard.string(forKey: UserDefault.currency_code)
        UserDefaults.shared.set(code, forKey: UserDefault.currency_code)
    }
    
    static var currencySymbol: String {
        return UserDefaults.shared.string(forKey: UserDefault.currency_symbol) ?? ""
    }
    
    static var currencyCode: String {
        return UserDefaults.shared.string(forKey: UserDefault.currency_code) ?? ""
    }
    
    static var viewCurrency: String {
        return "\(currencySymbol)"
    }
    
    static func setupCurrencyIfNeeded() {
        guard !NSUbiquitousKeyValueStore.default.bool(forKey: UserDefault.currency_is_set) else { return }
        
        NSUbiquitousKeyValueStore.default.set(true, forKey: UserDefault.currency_is_set)
        
        let locale = Locale.current
        UserDefaults.shared.set(locale.currencySymbol ?? "", forKey: UserDefault.currency_symbol)
        UserDefaults.shared.set(locale.currencyCode ?? "", forKey: UserDefault.currency_code)
    }
    
    static func setupCurrency(currency: Currency) {
        UserDefaults.shared.set(currency.symbol, forKey: UserDefault.currency_symbol)
        UserDefaults.shared.set(currency.code, forKey: UserDefault.currency_code)
    }
    
    static var currentCurrency: Currency {
        Currency(symbol: currencySymbol, code: currencyCode)
    }
}
