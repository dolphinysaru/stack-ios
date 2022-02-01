//
//  MoreTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/24.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
