//
//  PriceTextField.swift
//  moneybook
//
//  Created by jedmin on 2022/01/10.
//

import Foundation
import UIKit

class PriceTextField: UITextField {
    var didChangeText: ((String?) -> Void)?
    
    internal init() {
        super.init(frame: .zero)
        setup()
    }

    internal required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        keyboardType = .decimalPad
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChangeNotification),
            name: UITextField.textDidChangeNotification,
            object: nil
        )
    }
    
    @objc func textDidChangeNotification() {
        guard let priceText = self.text else { return }
        self.text = priceText.price(isEditing: true)
        
        didChangeText?(self.text)
    }
    
    var doubleValue: Double {
        let removeString = self.text?.removeDecimal() ?? ""
        return Double(removeString) ?? 0.0
    }
}
