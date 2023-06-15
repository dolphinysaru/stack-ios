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
    let bannerHeight = min(UIScreen.main.bounds.width / 6.4, 80)
    var gadBannerView: GADBannerView?
    var isBannerAd: Bool = false
    var gadBannerController = GAdBannerController()
    private var observer: NSObjectProtocol?
    var interstitial: GADInterstitialAd!
    var fullAdId = AdType.fullAddItem(.high).id
    var bannerId = AdType.banner(.high).id
    var webView: WKWebView?
    
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
        
        RemoteConfigManager.shared.callBacks.append { [weak self] in
            DispatchQueue.main.async {
                self?.loadGABannerView()
            }
        }
    }
    
    @objc func removeBannerView() {
        gadBannerView?.removeFromSuperview()
    }
    
    func loadGAInterstitial() {
        guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
        
        #if DEBUG
        fullAdId = "ca-app-pub-3940256099942544/4411468910"
        #endif
        
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: fullAdId,
            request: request,
            completionHandler: { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    self.retryAd()
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
        self.loadGABannerView()
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
    
    //쿠팡-관심사 기반
//    <iframe src="https://ads-partners.coupang.com/widgets.html?id=670069&template=carousel&trackingCode=AF7673990&subId=&width=680&height=1000&tsource=" width="680" height="1000" frameborder="0" scrolling="no" referrerpolicy="unsafe-url"></iframe>
    func loadCoupangBanner() {
        let file = Bundle.main.path(forResource: "coupang", ofType: "html")!
        let localHtmlString = try! String(contentsOfFile: file, encoding: .utf8)
        
        let height = 80
        let width = UIScreen.main.bounds.width - 16
        
        let coupangIframe = String(format: "<iframe src=\"https://ads-partners.coupang.com/widgets.html?id=670069&template=carousel&trackingCode=AF7673990&subId=&width=%@&height=%@&tsource=\" width=\"%@\" height=\"%@\" frameborder=\"0\" scrolling=\"no\" referrerpolicy=\"unsafe-url\"></iframe>", "\(width)", "\(height)", "\(width)", "\(height)")
        
        let lastHtmlString = String(format: localHtmlString, coupangIframe)
        
        webView = WKWebView()
        view.addSubview(webView!)
        webView?.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(-(tabBarController?.tabBar.frame.height ?? 0))
            $0.height.equalTo(90)
        }
        
        webView?.scrollView.isScrollEnabled = false
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.loadHTMLString(lastHtmlString, baseURL: URL(string: "https://www.naver.com")!)
    }
    
    func loadGABannerView() {
        guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
        
        guard isBannerAd else { return }
        guard isEnabledAd else { return }
        
        if gadBannerView != nil {
            gadBannerView?.removeFromSuperview()
            gadBannerView = nil
        }
        
        if webView != nil {
            webView?.removeFromSuperview()
            webView = nil
        }
        
        let languageCode = Locale.preferredLanguages[0]
        
        if RemoteConfigManager.shared.isAdmobBanner || !languageCode.lowercased().contains("ko") {
            gadBannerView = AdUtil.initGABannerView(id: bannerId, delegate: gadBannerController, vc: self)
            gadBannerView?.delegate = self
            view.addSubview(gadBannerView!)
            gadBannerView?.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(-(tabBarController?.tabBar.frame.height ?? 0))
                $0.height.equalTo(bannerHeight)
            }
            
            gadBannerView?.load(GADRequest())
        } else if RemoteConfigManager.shared.isCoupangBanner {
            loadCoupangBanner()
        }
    }
}

extension BaseViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 0
        })
        
        if bannerId == AdType.banner(.high).id {
            bannerId = AdType.banner(.medium).id
            loadGABannerView()
        } else if bannerId == AdType.banner(.medium).id {
            bannerId = AdType.banner(.all).id
            loadGABannerView()
        }
    }
}

extension BaseViewController: GADFullScreenContentDelegate {
    func retryAd() {
        if fullAdId == AdType.fullAddItem(.high).id {
            interstitial = nil
            fullAdId = AdType.fullAddItem(.medium).id
            loadGAInterstitial()
        } else if fullAdId == AdType.fullAddItem(.medium).id {
            interstitial = nil
            fullAdId = AdType.fullAddItem(.all).id
            loadGAInterstitial()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        retryAd()
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        
        InAppProducts.store.requestProducts(
            { success, products in
                guard success else { return }
                guard let product = products?.first else { return }
                
                print("product price \(product.localizedPrice)")
                
                DispatchQueue.main.async {
                    let cancelAction = SnackBarAction(title: "cancel".localized(), style: .cancel, handler: nil)
                    let buyAction = SnackBarAction(title: "buy_button_title".localized() + ", " + product.localizedPrice + "/" + "month".localized(), style: .default, handler: { _ in
                        InAppProducts.store.buyProduct(product) { [weak self] success, message in
                            guard let self = self else { return }
                            let title: String
                            if success {
                                title = "success_iap".localized()
                            } else {
                                title = "fail_iap".localized()
                            }

                            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "common_confirm".localized(), style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    
                    SnackBarController.show(message: "snackbar_iap_message".localized(), actions: [cancelAction, buyAction])
                }
            }
        )
    }
}

extension BaseViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("navigationAction.request \(navigationAction.request)")
        
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url)
            }
        }
        return nil
    }
}
