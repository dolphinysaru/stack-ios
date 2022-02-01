//
//  ItemMemoTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/11.
//

import UIKit

class ItemMemoTableViewCell: UITableViewCell {
    @IBOutlet weak var memoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(text: String?) {
        memoLabel.text = text
    }
}
