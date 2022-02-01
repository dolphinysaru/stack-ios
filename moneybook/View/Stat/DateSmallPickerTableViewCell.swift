//
//  DateSmallPickerTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/20.
//

import UIKit

class DateSmallPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    var didTapPrevious: (() -> Void)?
    var didTapNext: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .large)
        let leftImage = UIImage(systemName: "chevron.left", withConfiguration: largeConfig)
        let rightImage = UIImage(systemName: "chevron.right", withConfiguration: largeConfig)
        
        leftButton.setImage(leftImage, for: .normal)
        rightButton.setImage(rightImage, for: .normal)
    }
    
    func updateUI(startDate: Date, endDate: Date) {
        titleLabel.text = startDate.toString + "~" + endDate.toString
    }
    
    @IBAction func leftButtonAction(_ sender: Any) {
        didTapPrevious?()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        didTapNext?()
    }
}
