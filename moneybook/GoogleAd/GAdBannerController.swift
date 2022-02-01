//
//  GAdBannerController.swift
//  LottoQR
//
//  Created by jedmin on 2020/12/21.
//  Copyright © 2020 mck. All rights reserved.
//

import Foundation
import GoogleMobileAds
import Firebase

class GAdBannerController: NSObject, GADBannerViewDelegate {
    var didReceivedAd: (() -> Void)?
        
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
        
        didReceivedAd?()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 0
        })
    }
}
