//
//  BudgetReportTopTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/10.
//

import UIKit

class BudgetReportTopTableViewCell: UITableViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    var didTapAddButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    func setupUI() {
        addButton.setupCornerRadius()
        addButton.setTitle("add".localized(), for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        didTapAddButton?()
    }
    
    func updateUI(header: String, price: String) {
        priceLabel.text = price
        headerLabel.text = header
    }
}
