//
//  AppDelegate.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit
import Localize_Swift
import Firebase
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

let isEnabledAd = true

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appOpenAd: GADAppOpenAd?
    var isEnterBackground = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        try? AppDatabase.shared.initialCategory()
        CurrencyManager.setupCurrencyIfNeeded()
        initViewControllers()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        isEnterBackground = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        ReviewHelper.reviewIfNeeded()
        
        if !isEnterBackground {
            return
        }
        
        isEnterBackground = false
        appOpenAd = nil
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] _ in
                // Tracking authorization completed. Start loading ads here.
                self?.tryToPresentAd()
            })
        } else {
            tryToPresentAd()
        }
    }
    
    private func initViewControllers() {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else { return }
        
        let planVC = PlanViewController(nibName: "PlanViewController", bundle: nil)
        planVC.tabBarItem = UITabBarItem(title: "plan_title".localized(), image: UIImage(systemName: "line.horizontal.3.decrease.circle"), tag: 0)
        
        let planNV = UINavigationController(rootViewController: planVC)
        
        let statVC = StatViewController(nibName: "StatViewController", bundle: nil)
        statVC.tabBarItem = UITabBarItem(title: "calendar_title".localized(), image: UIImage(systemName: "calendar"), tag: 1)
        
        let statNV = UINavigationController(rootViewController: statVC)
        
        let moreVC = MoreViewController(nibName: "MoreViewController", bundle: nil)
        moreVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        
        let moreNV = UINavigationController(rootViewController: moreVC)
        
        tabBarController.setViewControllers([planNV, statNV, moreNV], animated: true)
    }
}

extension AppDelegate: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}

extension AppDelegate {
    func requestAppOpenAd() {
#if DEBUG
        let adUnitID = "ca-app-pub-3940256099942544/5662855259"
#else
        let adUnitID = ga_openning
#endif
        
        appOpenAd = nil
        GADAppOpenAd.load(
            withAdUnitID: adUnitID,
            request: GADRequest(),
            orientation: UIInterfaceOrientation.portrait) { (ad, error) in
                
                if let error = error {
                    print("Failed to load app open ad: \(error)");
                    return
                }
                
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.tryToPresentAd()
            }
    }
    
    func tryToPresentAd() {
        if let ad = appOpenAd {
            if let vc = window?.rootViewController {
                ad.present(fromRootViewController: vc)
            }
        } else {
            requestAppOpenAd()
        }
    }
}
