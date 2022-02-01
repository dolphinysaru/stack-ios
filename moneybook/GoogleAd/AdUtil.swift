//
//  AdUtil.swift
//  QRReader
//
//  Created by jedmin on 2020/07/22.
//  Copyright © 2020 mck. All rights reserved.
//

import Foundation
import GoogleMobileAds

let ga_banner_id_home = "ca-app-pub-2613397310926695/9084785008"
let ga_banner_id_calendar = "ca-app-pub-2613397310926695/5405394449"
let ga_openning = "ca-app-pub-2613397310926695/8582539355"
let ga_banner_id_setting = "ca-app-pub-2613397310926695/5405394449"

class AdUtil {
    static func initGABannerView(id: String, delegate: GAdBannerController, vc: UIViewController) -> GADBannerView {
//        let adSize = GADAdSizeFromCGSize(CGSize(width: 300, height: 50))
        let gadBannerView = GADBannerView(adSize: GADAdSizeBanner)
        gadBannerView.delegate = delegate
        #if DEBUG
        gadBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
        gadBannerView.adUnitID = id
        #endif
        
        gadBannerView.rootViewController = vc
//        gadBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(vc.view.frame.width)
//        gadBannerView.alpha = 0.0
        
        return gadBannerView
    }
}
