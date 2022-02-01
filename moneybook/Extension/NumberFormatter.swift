//
//  NumberFormatter.swift
//  moneybook
//
//  Created by jedmin on 2022/01/10.
//

import Foundation

extension String {
    func decimalFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    func thousand() -> String {
        let formatter = decimalFormatter()
        if let numberWithoutGroupingSeparator = formatter.number(from: self) {
            return formatter.string(from: numberWithoutGroupingSeparator) ?? self
        }
        
        return self
    }
    
    var groupingSeparator: String {
        let formatter = decimalFormatter()
        if let groupingSeparator = formatter.groupingSeparator {
            return groupingSeparator
        }
        
        return ""
    }
    
    func removeDecimal() -> String {
        replacingOccurrences(of: groupingSeparator, with: "")
    }
    
    func price(isEditing: Bool = false) -> String {
        let components = self.components(separatedBy: ".")
        guard let first = components.first else { return self }
        let remove = first.removeDecimal()
        
        if components.count == 2 && (isEditing || (!isEditing && components[1] != "0")) {
            return remove.thousand() + "." + components[1]
        } else {
            return remove.thousand()
        }
    }
}
