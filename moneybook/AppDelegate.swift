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
    var appOpenAd: GADAppOpenAd?
    var isEnterBackground = true
    let gcmMessageIDKey = "gcm.message_id"
    var adUnitID: String = AdType.appOpen(.high).id
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let _ = InAppProducts.store
        
        FirebaseApp.configure()
        RemoteConfigManager.shared.fetch()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
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
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        RemoteConfigManager.shared.didFetchOpenAd = { [weak self] in
            if $0 {
                self?.tryToPresentAd()
            }
        }
        
        RemoteConfigManager.shared.callBacks.append { [weak self] in
            guard let self = self else { return }
            
            let languageCode = Locale.preferredLanguages[0]
            if !languageCode.lowercased().contains("ko") {
                return
            }
            
            if !RemoteConfigManager.shared.isShoppingTab {
                return
            }
                
            DispatchQueue.main.async {
                if let tabBarController = self.window?.rootViewController as? UITabBarController {
                    var vcs = tabBarController.viewControllers
                    
                    let shoppingViewController = ShoppingViewController(nibName: "ShoppingViewController", bundle: nil)
                    shoppingViewController.tabBarItem = UITabBarItem(title: "쇼핑", image: UIImage(systemName: "cart"), tag: 2)
                    let nav3 = UINavigationController(rootViewController: shoppingViewController)
                    vcs?.insert(nav3, at: 2)
                    tabBarController.setViewControllers(vcs, animated: true)
                }
            }
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        isEnterBackground = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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
        retryAd()
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}

extension AppDelegate {
    func requestAppOpenAd() {
        guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
        
#if DEBUG
        adUnitID = "ca-app-pub-3940256099942544/5662855259"
#endif
        
        appOpenAd = nil
        GADAppOpenAd.load(
            withAdUnitID: adUnitID,
            request: GADRequest(),
            orientation: UIInterfaceOrientation.portrait) { (ad, error) in
                
                if let error = error {
                    print("Failed to load app open ad: \(error)");
                    self.retryAd()
                    return
                }
                
                self.appOpenAd = ad
                self.appOpenAd?.fullScreenContentDelegate = self
                self.tryToPresentAd()
            }
    }
    
    func retryAd() {
        if adUnitID == AdType.appOpen(.high).id {
            appOpenAd = nil
            adUnitID = AdType.appOpen(.medium).id
            requestAppOpenAd()
        } else if adUnitID == AdType.appOpen(.medium).id {
            appOpenAd = nil
            adUnitID = AdType.appOpen(.all).id
            requestAppOpenAd()
        }
    }
    
    func tryToPresentAd() {
        guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
        guard isEnabledAd else { return }
        guard RemoteConfigManager.shared.enabledOpenad else { return }
        
        if let ad = appOpenAd {
            if let vc = window?.rootViewController {
                ad.present(fromRootViewController: vc)
            }
        } else {
            requestAppOpenAd()
        }
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
         Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
