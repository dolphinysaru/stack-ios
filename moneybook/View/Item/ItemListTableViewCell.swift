//
//  ItemListTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/11.
//

import UIKit

class ItemListTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func updateUI(item: Item) {
        if let category = CoreData.shared.loadCategory(item.kindId) {
            let image = UIImage.imageWithEmoji(emoji: category.icon, fontSize: 100, size: CGSize(width: 200, height: 200))
            iconImageView.image = image
            
            if item.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                titleLabel.text = category.title
            } else {
                titleLabel.text = category.title + " - " + item.memo
            }
        }
        
        if item.type == .income {
            priceLabel.text = CurrencyManager.currencySymbol + " +" + "\(item.price)".price()
        } else {
            priceLabel.text = CurrencyManager.currencySymbol + " -" + "\(item.price)".price()
        }
    }
    
    func updateUI(title: String, icon: UIImage, selection: UITableViewCell.SelectionStyle = .none) {
        iconImageView.image = icon
        titleLabel.text = title
        selectionStyle = selection
        priceLabel.text = ""
    }
}
