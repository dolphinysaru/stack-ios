//
//  UITextField+.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import Foundation
import UIKit

extension UITextView {
    var isEmpty: Bool {
        if let text = self.text, !text.isEmpty {
             return false
        }
        return true
    }
}

extension UITextField {
    var isEmpty: Bool {
        if let text = self.text, !text.isEmpty {
             return false
        }
        return true
    }
}
