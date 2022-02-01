//
//  HeaderView.swift
//  moneybook
//
//  Created by jedmin on 2022/01/24.
//

import UIKit

class HeaderView: UIView {
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground

        titleLabel = UILabel(frame: CGRect(x: 20, y: 0, width: frame.width - 20, height: 35))
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = UIFont.systemFont(ofSize: 14)

        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func updateUI(title: String) {
        titleLabel.text = title
    }
}
