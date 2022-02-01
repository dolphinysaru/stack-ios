//
//  FeaturedTableViewCell.swift
//  QRReader
//
//  Created by jedmin on 2021/12/28.
//  Copyright © 2021 mck. All rights reserved.
//

import UIKit
import Kingfisher

class FeaturedTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    var appId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.masksToBounds = true
        descriptionLabel.lineBreakMode = .byWordWrapping
        
        downloadButton.setTitle("download".localized(), for: .normal)
        downloadButton.layer.cornerRadius = 10
        downloadButton.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(icon: String, appname: String?, description: String?, appId: String) {
        let url = URL(string: icon)
        iconImageView.kf.setImage(with: url)
        appNameLabel.text = appname
        descriptionLabel.text = description
        self.appId = appId
    }
    
    @IBAction func downloadButtonAction(_ sender: Any) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/\(self.appId ?? "")"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
