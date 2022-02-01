//
//  DatePickerTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/14.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
    internal var didChangeDate: ((Date) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        datePicker.addTarget(self, action: #selector(changePickerDate(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc
    private func changePickerDate(_ picker: UIDatePicker) {
        didChangeDate?(picker.date)
    }
}
