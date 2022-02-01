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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        try? AppDatabase.shared.initialCategory()
        CurrencyManager.setupCurrencyIfNeeded()
        initViewControllers()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        ReviewHelper.reviewIfNeeded()
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                // Tracking authorization completed. Start loading ads here.
            })
        } else {
            
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

