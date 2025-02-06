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
import CoreData
import UserMessagingPlatform

let isEnabledAd = true

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let ubiquitousStore = NSUbiquitousKeyValueStore.default
    var appOpenAd: GADAppOpenAd?
    var isEnterBackground = true
    var adUnitID: String = "ca-app-pub-2613397310926695/4216714081"
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NSUbiquitousKeyValueStore.default.synchronize()
        // 테스트 코드
//        CoreData.shared.resetCategory()
        
        
        // 테스크 코드
//        NSUbiquitousKeyValueStore.default.set(false, forKey: "core_date_migration")
//        NSUbiquitousKeyValueStore.default.synchronize()
//        CoreData.shared.removeAllCategory()
        
        let _ = InAppProducts.store
        
        FirebaseApp.configure()
        RemoteConfigManager.shared.fetch()
        Budget.syncIcloud()
        
        if CoreDataMigration.shared.isNeedMigrationCoreData() {
            CoreDataMigration.shared.migrationIfNeeded()
        } else {
            CoreData.shared.initialCategory()
            CurrencyManager.setupCurrencyIfNeeded()
        }
        
        CoreDataMigration.shared.migrateId()
        
        initViewControllers()
        registerKeyValueStoreObserver()
        
        return true
    }
    
    func registerKeyValueStoreObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousStore
        )
    }
    
    // iCloud 데이터가 변경되면 호출되는 메서드
    @objc
    func storeDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            // 변경된 키-값 쌍 확인
            if let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
                for key in changedKeys {
                    if let value = ubiquitousStore.object(forKey: key) {
                        print("Key: \(key), Value: \(value)")
                    }
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if !isEnterBackground {
            return
        }
        
        isEnterBackground = false
        appOpenAd = nil
        
        if UMPConsentInformation.sharedInstance.canRequestAds {
            self.requestAppOpenAd()
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

extension AppDelegate {
    func requestAppOpenAd() {
        guard !InAppProducts.store.isProVersion() else { return }
        
#if DEBUG
        adUnitID = "ca-app-pub-3940256099942544/5575463023"
#endif
        
        appOpenAd = nil
        GADAppOpenAd.load(
            withAdUnitID: adUnitID,
            request: GADRequest()) { [weak self] (ad, error) in
                guard let self = self else { return }
                
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
            if let vc = window?.rootViewController?.presentedViewController {
                ad.present(fromRootViewController: vc)
            } else if let vc = window?.rootViewController {
                ad.present(fromRootViewController: vc)
            }
        }
    }
}

extension AppDelegate: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}
