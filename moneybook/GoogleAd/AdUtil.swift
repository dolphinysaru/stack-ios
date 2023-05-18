//
//  AdUtil.swift
//  QRReader
//
//  Created by jedmin on 2020/07/22.
//  Copyright © 2020 mck. All rights reserved.
//

import Foundation
import GoogleMobileAds

enum Ecpm {
    case all
    case medium
    case high
}

enum AdType {
    case appOpen(_ ecpm: Ecpm)
    case fullAddItem(_ ecpm: Ecpm)
    case banner(_ ecpm: Ecpm)
    
    var id: String {
        switch self {
        case .appOpen(let ecpm):
            if ecpm == .high {
                return "ca-app-pub-2613397310926695/4216714081"
            } else if ecpm == .medium {
                return "ca-app-pub-2613397310926695/8614004531"
            } else {
                return "ca-app-pub-2613397310926695/8582539355"
            }
            
        case .fullAddItem(let ecpm):
            if ecpm == .high {
                return "ca-app-pub-2613397310926695/9277469075"
            } else if ecpm == .medium {
                return "ca-app-pub-2613397310926695/2048596183"
            } else {
                return "ca-app-pub-2613397310926695/6807450924"
            }
            
        case .banner(let ecpm):
            if ecpm == .high {
                return "ca-app-pub-2613397310926695/2240167874"
            } else if ecpm == .medium {
                return "ca-app-pub-2613397310926695/9469040763"
            } else {
                return "ca-app-pub-2613397310926695/9084785008"
            }
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
