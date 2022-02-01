//
//  ItemTitleTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/11.
//

import UIKit

class ItemTitleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(text: String?) {
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
    }
}
