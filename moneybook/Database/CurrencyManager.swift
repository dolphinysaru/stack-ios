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
    static var currencySymbol: String {
        return UserDefaults.standard.string(forKey: UserDefault.currency_symbol) ?? ""
    }
    
    static var currencyCode: String {
        return UserDefaults.standard.string(forKey: UserDefault.currency_code) ?? ""
    }
    
    static var viewCurrency: String {
        return "\(currencySymbol)"
    }
    
    static func setupCurrencyIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: UserDefault.currency_is_set) else { return }
        
        let locale = Locale.current
        UserDefaults.standard.set(locale.currencySymbol ?? "", forKey: UserDefault.currency_symbol)
        UserDefaults.standard.set(locale.currencyCode ?? "", forKey: UserDefault.currency_code)
    }
    
    static func setupCurrency(currency: Currency) {
        UserDefaults.standard.set(currency.symbol, forKey: UserDefault.currency_symbol)
        UserDefaults.standard.set(currency.code, forKey: UserDefault.currency_code)
    }
    
    static var currentCurrency: Currency {
        Currency(symbol: currencySymbol, code: currencyCode)
    }
}
