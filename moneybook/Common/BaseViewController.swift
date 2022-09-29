//
//  BaseViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit
import GoogleMobileAds

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        if let alert = controller as? UIAlertController {
            if let navigationController = alert.presentingViewController as? UINavigationController {
                return navigationController.viewControllers.last
            }
            return alert.presentingViewController
        }
        return controller
    }
}

class BaseViewController: UIViewController {
    var gadBannerView: GADBannerView?
    var gaId: String?
    var gadBannerController = GAdBannerController()
    private var observer: NSObjectProtocol?
    var interstitial: GADInterstitialAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main) {
                [weak self] notification in
                // background에서 foreground로 돌아오는 경우 실행 될 코드
                
                if let topVC = UIApplication.topViewController(), topVC == self {
                    self?.loadGABannerView()
                }
            }
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeBannerView), name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    @objc func removeBannerView() {
        gadBannerView?.removeFromSuperview()
    }
    
    func loadGAInterstitial() {
        guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
        
        #if DEBUG
        let adid = "ca-app-pub-3940256099942544/4411468910"
        #else
        let adid = "ca-app-pub-2613397310926695/6807450924"
        #endif
        
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: adid,
            request: request,
            completionHandler: { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                self.interstitial.present(fromRootViewController: self)
            }
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()    
        updateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        loadGABannerView()
    }
    
    func updateLayout() {
        
    }
    
    func updateData() {
        
    }
    
    func setupPrefersLargeTitles() {
        if Device.isSmallHeightDevice {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
            navigationController?.navigationBar.sizeToFit()
        }
    }
    
    internal func setupUI() {
        
    }

    internal func registerKeyboardShowNotification(selector aSelector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: aSelector,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    internal func registerKeyboardHideNotification(selector aSelector: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: aSelector,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    internal func keyboardHeight(notification: NSNotification) -> CGFloat {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            return keyboardHeight
        }

        return 0
    }

    internal func keyboardAnimationDuration(notification: NSNotification) -> Double {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0
        return duration
    }

    internal func keyboardAnimationCurve(notification: NSNotification) -> UIView.AnimationOptions {
        let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        return UIView.AnimationOptions(rawValue: curve)
    }
    
    func loadGABannerView() {
        guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
        
        guard let gaId = gaId else { return }
        guard isEnabledAd else { return }
        
        if gadBannerView != nil {
            gadBannerView?.removeFromSuperview()
            gadBannerView = nil
        }
        
        gadBannerView = AdUtil.initGABannerView(id: gaId, delegate: gadBannerController, vc: self)
        view.addSubview(gadBannerView!)
        gadBannerView?.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(-(tabBarController?.tabBar.frame.height ?? 0))
            $0.height.equalTo(50)
        }
        
        gadBannerView?.load(GADRequest())
    }
}

extension BaseViewController: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }

    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
    }
}
