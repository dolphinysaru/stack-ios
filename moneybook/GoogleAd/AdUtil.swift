//
//  AdUtil.swift
//  QRReader
//
//  Created by jedmin on 2020/07/22.
//  Copyright © 2020 mck. All rights reserved.
//

import Foundation
import GoogleMobileAds

enum AdType {
    case appOpen
    case interstitial
    case banner
    
    var id: String {
        switch self {
        case .appOpen:
            return "ca-app-pub-2613397310926695/4216714081"
                        
        case .interstitial:
            return "ca-app-pub-2613397310926695/9277469075"
                        
        case .banner:
            return "ca-app-pub-2613397310926695/2240167874"
        }
    }
}

class AdUtil {
    static func initGABannerView(id: String, delegate: GAdBannerController, vc: UIViewController) -> GADBannerView {
//        let adSize = GADAdSizeFromCGSize(CGSize(width: 300, height: 50))
        let gadBannerView = GADBannerView()
        gadBannerView.delegate = delegate
        #if DEBUG
        gadBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        gadBannerView.adUnitID = id
        #endif
        
        gadBannerView.rootViewController = vc
        gadBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(vc.view.frame.width)
//        gadBannerView.alpha = 0.0
        
        return gadBannerView
    }
}
