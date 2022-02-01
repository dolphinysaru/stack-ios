//
//  InputPriceViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import UIKit

class InputPriceViewController: BaseViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var priceTextField: PriceTextField!
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceBoxView: UIView!
    @IBOutlet weak var dateBoxView: UIView!
    @IBOutlet weak var priceTitleLabel: UILabel!
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    
    var editItem: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func setupUI() {
        title = "input_price_title".localized()
        
        dateTitleLabel.text = "date_title".localized()
        priceTitleLabel.text = "price_title".localized()
        priceTextField.placeholder = "price_placeholder".localized()
        priceTextField.didChangeText = { [weak self] in
            self?.doneButton.alpha = $0?.isEmpty == true ? 0.6 : 1.0
        }
        
        dateLabel.text = Date.todayString
        datePicker.isHidden = true
        datePickerHeight.constant = 10
        datePicker.addTarget(self, action: #selector(changePickerDate(_:)), for: .valueChanged)
        
        segmentedControl.setTitle("expend_segmented_title".localized(), forSegmentAt: 0)
        segmentedControl.setTitle("income_segmented_title".localized(), forSegmentAt: 1)
        
        registerKeyboardShowNotification(selector: #selector(keyboardWillShow(notification:)))
        registerKeyboardHideNotification(selector: #selector(keyboardWillHide(notification:)))
        
        priceBoxView.setupCornerRadius()
        dateBoxView.setupCornerRadius()
        doneButton.setupCornerRadius()
        doneButton.alpha = 0.6
        doneButton.setTitle("next".localized(), for: .normal)
        currencyLabel.text = CurrencyManager.viewCurrency
        
        if let item = editItem {
            if item.type == .income {
                segmentedControl.selectedSegmentIndex = 1
            } else {
                segmentedControl.selectedSegmentIndex = 0
            }
            
            dateLabel.text = item.date.toString
            priceTextField.text = "\(item.price)".price(isEditing: true)
            doneButton.alpha = 1.0
            datePicker.date = item.date
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        priceTextField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        guard !priceTextField.isEmpty else { return }
        
        let type: CategoryType = segmentedControl.selectedSegmentIndex == 0 ? .expenditure : .income
        let vc = CategorySelectionViewController.init(type: type, editItem: editItem)
        navigationController?.pushViewController(vc, animated: true)
        
        AddItemManager.shared.setup(
            type: type == .expenditure ? .expenditure : .income,
            price: priceTextField.doubleValue,
            date: datePicker.date
        )
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        let height = keyboardHeight(notification: notification)
        doneButtonBottomPadding.constant = height - Device.safeAreaInsetsBottom + 10
        self.view.layoutIfNeeded()
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        doneButtonBottomPadding.constant = 0
    }
        
    @IBAction func dateButtonAction(_ sender: Any) {
        if datePicker.isHidden {
            datePickerHeight.constant = 315
            priceTextField.resignFirstResponder()
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.datePicker.isHidden = false
            }

        } else {
            hiddenDatePicker()
        }
    }
    
    private func hiddenDatePicker() {
        datePicker.isHidden = true
        datePickerHeight.constant = 10
        priceTextField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func changePickerDate(_ picker: UIDatePicker) {
        hiddenDatePicker()
        let dateString = picker.date.toString
        dateLabel.text = dateString
    }
}
