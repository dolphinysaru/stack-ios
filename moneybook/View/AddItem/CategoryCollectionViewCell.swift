//
//  CategoryCollectionViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupUI()
    }
    
    func setupUI() {
        circleView.layer.cornerRadius = 35
        circleView.layer.masksToBounds = true
    }

    func updateUI(category: Category) {
        let image = UIImage.imageWithEmoji(emoji: category.icon, fontSize: 100, size: CGSize(width: 200, height: 200))
        iconImageView.image = image
        
        categoryNameLabel.text = category.title
    }
}
