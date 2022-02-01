//
//  CategoryEditTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/24.
//

import UIKit

class CategoryEditTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var removeToggleButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var didTapRemoveToggleButton: (() -> Void)?
    var didTapEditButton: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        removeToggleButton.setupCornerRadius(17)
        editButton.setupCornerRadius(17)
        
        removeToggleButton.backgroundColor = UIColor.systemRed
        editButton.backgroundColor = UIColor.systemBlue
        
        editButton.setTitle("common_edit".localized(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(category: Category, removed: Bool) {
        titleLabel?.text = category.icon + " " + category.title
        
        if removed {
            removeToggleButton.backgroundColor = UIColor.systemGreen
            editButton.backgroundColor = UIColor.systemBlue
            
            removeToggleButton.setTitle("common_add".localized(), for: .normal)
        } else {
            removeToggleButton.backgroundColor = UIColor.systemRed
            editButton.backgroundColor = UIColor.systemBlue
            
            removeToggleButton.setTitle("common_remove".localized(), for: .normal)
        }
    }
    
    @IBAction func removeToggleButtonAction(_ sender: Any) {
        didTapRemoveToggleButton?()
    }
    
    @IBAction func editButtonAction(_ sender: Any) {
        didTapEditButton?()
    }
}
