//
//  ReviewHelper.swift
//  QRReader
//
//  Created by jedmin on 2021/12/30.
//  Copyright © 2021 mck. All rights reserved.
//

import Foundation
import StoreKit

let UserDefaultsKeyLaunchCount = "UserDefaultsKeyLaunchCount"
let UserDefaultsKeyShowRequestReview = "UserDefaultsKeyShowRequestReview"

struct ReviewHelper {
    static func reviewIfNeeded() {
        let launchCount = UserDefaults.standard.integer(forKey: UserDefaultsKeyLaunchCount)
        let isRequestReview = UserDefaults.standard.bool(forKey: UserDefaultsKeyShowRequestReview)
        if launchCount > 2 && !isRequestReview {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeyShowRequestReview)
            SKStoreReviewController.requestReview()
        }
        
        UserDefaults.standard.set(launchCount + 1, forKey: UserDefaultsKeyLaunchCount)
    }
}
