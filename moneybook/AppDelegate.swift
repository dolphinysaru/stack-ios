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
import WidgetKit
import FirebaseMessaging

let isEnabledAd = true

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let _ = InAppProducts.store
        
        FirebaseApp.configure()
        RemoteConfigManager.shared.fetch()
        
        if CloudDataManager.sharedInstance.isCloudEnabled() {
            CloudDataManager.sharedInstance.createDirICloud()
            
            let isExist = CloudDataManager.sharedInstance.isExistCloudFile()
            if isExist {
                CloudDataManager.sharedInstance.copyFileToLocal()
            }
        }
        
        let isSetCategory = UserDefaults.standard.bool(forKey: "is_initial_category")
        if !UserDefaults.standard.bool(forKey: "is_migrate_appgroup_1") && isSetCategory {
            try? AppDatabase.migrateAppGroup()
            CurrencyManager.migrate()
            Budget.migrate()
            
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            try? AppDatabase.shared.initialCategory()
            CurrencyManager.setupCurrencyIfNeeded()
        }
        
        UserDefaults.standard.set(true, forKey: "is_migrate_appgroup_1")
        initViewControllers()
                
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] _ in
                // Tracking authorization completed. Start loading ads here.
                
            })
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
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
