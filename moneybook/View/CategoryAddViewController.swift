//
//  CategoryAddViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/24.
//

import UIKit
import Toast

class CategoryAddViewController: BaseViewController {
    let categoryType: CategoryType
    let isEdit: Bool
    var editCategory: Category?
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionButtonBottomPadding: NSLayoutConstraint!
    
    var didAddCategory: (() -> Void)?
    
    var name: String? {
        didSet {
            if name?.isEmpty == true || emoji?.isEmpty == true {
                actionButton.alpha = 0.6
            } else {
                actionButton.alpha = 1.0
            }
        }
    }
    
    var emoji: String? {
        didSet {
            if name?.isEmpty == true || emoji?.isEmpty == true {
                actionButton.alpha = 0.6
            } else {
                actionButton.alpha = 1.0
            }
        }
    }
    
    init(type: CategoryType, category: Category? = nil) {
        self.categoryType = type
        self.isEdit = category != nil
        self.editCategory = category
        super.init(nibName: "CategoryAddViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        
        actionButton.setupCornerRadius()
            
        if isEdit {
            switch categoryType {
            case .income:
                title = "edit_income_title".localized()
            case .expenditure:
                title = "edit_expend_title".localized()
            case .payment:
                title = "edit_payment_title".localized()
            }
        } else {
            switch categoryType {
            case .income:
                title = "add_income_title".localized()
            case .expenditure:
                title = "add_expend_title".localized()
            case .payment:
                title = "add_payment_title".localized()
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(InputTableViewCell.self)
        
        registerKeyboardShowNotification(selector: #selector(keyboardWillShow(notification:)))
        registerKeyboardHideNotification(selector: #selector(keyboardWillHide(notification:)))
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InputTableViewCell {
            cell.textField.becomeFirstResponder()
        }
        
        actionButton.setTitle("common_save".localized(), for: .normal)
        actionButton.alpha = 0.6
        
        if let category = editCategory {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InputTableViewCell {
                cell.textField.text = category.title
            }
            
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? InputTableViewCell {
                cell.emojiTextField.text = category.icon
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let textField = EmojiTextField()
        if textField.textInputMode == nil {
            self.view.makeToast("not_emoji_keyboard_toast_message".localized(), duration: 10)
        }
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        let height = keyboardHeight(notification: notification)
        actionButtonBottomPadding.constant = height - Device.safeAreaInsetsBottom + 10
        self.view.layoutIfNeeded()
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        actionButtonBottomPadding.constant = 0
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        if actionButton.alpha == 0.6 {
            return
        }
        
        guard let name = name else {
            return
        }

        guard let emoji = emoji else {
            return
        }
        
        if let editCategory = editCategory {
            let category = Category(id: editCategory.id, title: name, icon: emoji, updateAt: Date(), type: categoryType, visible: true)
            CoreData.shared.saveCategory(category, isNew: false)
        } else {
            let category = Category(id: nil, title: name, icon: emoji, updateAt: Date(), type: categoryType, visible: true)
            CoreData.shared.saveCategory(category)
        }
        
        didAddCategory?()
        
        dismiss(animated: true, completion: nil)
    }
}

extension CategoryAddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(InputTableViewCell.self, forIndexPath: indexPath)
        cell.updateUI(isEmojiInput: indexPath.section != 0)
        cell.didChangeText = { [weak self] in
            if let _ = $0 as? EmojiTextField {
                self?.emoji = $1
            } else {
                self?.name = $1
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: section == 0 ? "category_name_input".localized() : "category_emoji_input".localized())
        return view
    }
}

