//
//  ReviewHelper.swift
//  QRReader
//
//  Created by jedmin on 2021/12/30.
//  Copyright © 2021 mck. All rights reserved.
//

import Foundation
import StoreKit

let UserDefaultsKeyReviewCount = "UserDefaultsKeyReviewCount"

struct ReviewHelper {
    static func reviewIfNeeded() {
        let launchCount = UserDefaults.standard.integer(forKey: UserDefaultsKeyReviewCount) + 1
        UserDefaults.standard.set(launchCount, forKey: UserDefaultsKeyReviewCount)
        
        if launchCount == 3 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                DispatchQueue.main.async {
                    if #available(iOS 14.0, *) {
                        SKStoreReviewController.requestReview(in: scene)
                    } else {
                        SKStoreReviewController.requestReview()
                    }
                }
            }
        }
    }
}
