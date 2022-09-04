//
//  InputMemoViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/03.
//

import UIKit
import WidgetKit

class InputMemoViewController: BaseViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButtonBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    var editItem: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func setupUI() {
        title = "memo_input_title".localized()
        doneButton.setupCornerRadius()
        doneButton.setTitle("common_save".localized(), for: .normal)
        
        registerKeyboardShowNotification(selector: #selector(keyboardWillShow(notification:)))
        registerKeyboardHideNotification(selector: #selector(keyboardWillHide(notification:)))
        
        textView.text = nil
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.setupCornerRadius()
        textView.delegate = self
        
        if let editItem = editItem {
            textView.text = editItem.memo
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        AddItemManager.shared.memo = textView.text ?? ""
        if let item = editItem {
            AddItemManager.shared.save(id: item.id)
        } else {
            AddItemManager.shared.save()
        }
        
        Budget.syncAppGroupData()
        
        guard let nc = navigationController else { return }
        for (index, vc) in nc.viewControllers.enumerated() where vc is InputPriceViewController {
            guard let popVC = nc.viewControllers[safe: index - 1] else { return }
            self.navigationController?.popToViewController(popVC, animated: true)
            break
        }
        
        if let top = navigationController?.topViewController as? BaseViewController {
            if isEnabledAd && RemoteConfigManager.shared.enabledInterstitial {
                top.loadGAInterstitial()
            }
        }
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        let height = keyboardHeight(notification: notification)
        doneButtonBottomPadding.constant = -(height - Device.safeAreaInsetsBottom + 10)
        self.view.layoutIfNeeded()
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        doneButtonBottomPadding.constant = 0
    }
}

extension InputMemoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
}
