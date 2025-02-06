//
//  PlanViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit
import SnapKit
import GoogleMobileAds
import UserMessagingPlatform

class PlanViewController: BaseViewController {
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyDescriptionLabel: UILabel!
    @IBOutlet weak var startPlanButton: UIButton!
    @IBOutlet weak var addItemButton: UIButton!
    var planView = PlanView.instanceFromNib()
    private var isMobileAdsStartCalled = false
    
    func requestUMP() {
        // Create a UMPRequestParameters object.
        let parameters = UMPRequestParameters()
        // Set tag for under age of consent. false means users are not under age
        // of consent.
        parameters.tagForUnderAgeOfConsent = false
        
//        ae5ec39f07c6f6a1985ac1e06b19f4c8
//#if DEBUG
//        let debugSettings = UMPDebugSettings()
//        debugSettings.testDeviceIdentifiers = ["FA290B1F-F345-44F3-8E55-95DBB9BCB2DF"]
//        debugSettings.geography = .EEA
//        parameters.debugSettings = debugSettings
//#endif
        
        // Request an update for the consent information.
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
            [weak self] requestConsentError in
            guard let self else { return }
            
            if let consentError = requestConsentError {
                // Consent gathering failed.
                return print("Error: \(consentError.localizedDescription)")
            }
            
            UMPConsentForm.loadAndPresentIfRequired(from: self) { [weak self] loadAndPresentError in
                guard let self else { return }
                
                if let consentError = loadAndPresentError {
                    // Consent gathering failed.
                    return print("Error: \(consentError.localizedDescription)")
                }
                
                // Consent has been gathered.
                if UMPConsentInformation.sharedInstance.canRequestAds {
                    self.startGoogleMobileAdsSDK(appopen: true)
                }
            }
        }
        
        // Check if you can initialize the Google Mobile Ads SDK in parallel
        // while checking for new consent information. Consent obtained in
        // the previous session can be used to request ads.
        if UMPConsentInformation.sharedInstance.canRequestAds {
            startGoogleMobileAdsSDK(appopen: false)
        }
    }
    
    private func startGoogleMobileAdsSDK(appopen: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.isMobileAdsStartCalled else { return }
            
            self.isMobileAdsStartCalled = true
            
            // Initialize the Google Mobile Ads SDK.
            GADMobileAds.sharedInstance().start()
            
            self.loadGABannerView()
            
            if appopen {
                (UIApplication.shared.delegate as! AppDelegate).requestAppOpenAd()
            }
        }
    }
    
    override func updateData() {
        if Budget.isSavedBudget() {
            emptyView.isHidden = true
            planView.isHidden = false
            planView.updateUI()
        } else {
            emptyView.isHidden = false
            planView.isHidden = true
        }
    }
    
    override func setupUI() {
        setupPrefersLargeTitles()
        
        title = "plan_title".localized()
        
        setupEmptyView()
        view.addSubview(planView)
        planView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(-(tabBarController?.tabBar.frame.height ?? 0))
        }
        
        planView.didTapAddItem = { [weak self] in
            let vc = InputPriceViewController(nibName: "InputPriceViewController", bundle: nil)
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        planView.didTapDetailView = { [weak self] in
            let vc = BugetReportViewController(nibName: "BugetReportViewController", bundle: nil)
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        isBannerAd = true
        requestUMP()
    }
        
    func setupEmptyView() {
        let image = UIImage.imageWithEmoji(emoji: "🐷", fontSize: 200, size: CGSize(width: 160, height: 160))
        emptyImageView.image = image
        emptyDescriptionLabel.text = "no_plan_description".localized()
        
        startPlanButton.setTitle("start_plan_button_title".localized(), for: .normal)
        startPlanButton.setupCornerRadius()
        addItemButton.setupCornerRadius()
        
        addItemButton.setTitle("add_button_title".localized(), for: .normal)
    }
    
    @IBAction func addItemButtonAction(_ sender: Any) {
        let vc = InputPriceViewController(nibName: "InputPriceViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func startPlanButtonAction(_ sender: Any) {
        let budgetVC = BudgetViewController(nibName: "BudgetViewController", bundle: nil)
        budgetVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(budgetVC, animated: true)
    }
}
