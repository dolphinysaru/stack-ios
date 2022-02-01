//
//  StatSummaryTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/14.
//

import UIKit

class StatSummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var expendTitleLabel: UILabel!
    @IBOutlet weak var incomeTitleLabel: UILabel!
    @IBOutlet weak var expendValueLabel: UILabel!
    @IBOutlet weak var incomeValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        expendTitleLabel.text = "total_expend_price".localized()
        incomeTitleLabel.text = "total_income_price".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(income: Double, expend: Double) {        
        let expendString = "\((expend))".price()
        let incomeString = "\(income)".price()
        
        expendValueLabel.text = "\(CurrencyManager.currencySymbol) \(expendString)"
        incomeValueLabel.text = "\(CurrencyManager.currencySymbol) \(incomeString)"
    }
    
    func updateUI(title: String, value: Double) {
        expendTitleLabel.text = title
        
        let valueString = "\((value))".price()
        expendValueLabel.text = "\(CurrencyManager.currencySymbol) \(valueString)"
        
        incomeTitleLabel.isHidden = true
        incomeValueLabel.isHidden = true
    }
}
