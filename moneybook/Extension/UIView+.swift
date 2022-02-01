//
//  UIView+.swift
//  moneybook
//
//  Created by jedmin on 2022/01/03.
//

import Foundation
import UIKit

extension UIView {
    func setupCornerRadius(_ radius: CGFloat = 15) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
