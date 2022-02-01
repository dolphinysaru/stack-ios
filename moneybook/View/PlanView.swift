//
//  PlanView.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import UIKit

class PlanView: UIView {
    var didTapAddItem: (() -> Void)?
    var didTapDetailView: (() -> Void)?
    
    var budget: Budget = Budget.load()
    @IBOutlet weak var progressBar: GradientCircularProgressBar!
    @IBOutlet weak var backgroundBar: GradientCircularProgressBar!
    @IBOutlet weak var remainTitleLabel: UILabel!
    @IBOutlet weak var spendLabel: UILabel!
    @IBOutlet weak var budgetTotalLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    internal class func instanceFromNib() -> PlanView {
        let view = UINib(nibName: "PlanView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! PlanView
        view.setupUI()
        return view
    }
    
    private func setupUI() {
        addButton.setupCornerRadius()
        addButton.setTitle("add_button_title".localized(), for: .normal)
        
        progressBar.progress = 0.5
        progressBar.color = UIColor.systemBlue
        progressBar.gradientColor = UIColor.systemBlue
        
        backgroundBar.progress = 1.0
        backgroundBar.color = UIColor.secondarySystemBackground
        backgroundBar.gradientColor = UIColor.secondarySystemBackground
        
        remainTitleLabel.text = budget.cycleTerm.title
        
        arrowImageView.image = UIImage(systemName: "chevron.forward.circle.fill")
    }
    
    func updateUI() {
        let budget = Budget.load()
        let totalSpend = budget.totalExpend
        let spend = "\(totalSpend)".price()
        let budgetPrice = budget.priceString
        spendLabel.text = "\(CurrencyManager.currencySymbol) \(spend)"
        
        budgetTotalLabel.text = "/ \(CurrencyManager.currencySymbol) \(budgetPrice)"
        
        let percent: CGFloat = CGFloat(totalSpend) / CGFloat(budget.price)
        progressBar.progress = percent
        
        remainTitleLabel.text = budget.cycleTerm.title
    }
        
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButtonAction(_ sender: Any) {
        didTapAddItem?()
    }
    
    @IBAction func didTapDetailButton(_ sender: Any) {
        didTapDetailView?()
    }
}
