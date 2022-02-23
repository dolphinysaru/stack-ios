//
//  InAppProducts.swift
//  gifviewer
//
//  Created by jedmin on 2021/12/19.
//

import Foundation

public struct InAppProducts {
    public static let product = "com.ckmin.stack.pro"
    private static let productIdentifiers: Set<String> = [InAppProducts.product]
    internal static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
}
