//
//  PlanViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit
import SnapKit
import GoogleMobileAds

class PlanViewController: BaseViewController {
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyDescriptionLabel: UILabel!
    @IBOutlet weak var startPlanButton: UIButton!
    @IBOutlet weak var addItemButton: UIButton!
    var planView = PlanView.instanceFromNib()
    
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
        showRemoveAdsButton = true
        
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
