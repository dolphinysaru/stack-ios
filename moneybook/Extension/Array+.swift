//
//  File.swift
//  moneybook
//
//  Created by jedmin on 2022/01/11.
//

import Foundation

extension Array {
    internal subscript (safe index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
