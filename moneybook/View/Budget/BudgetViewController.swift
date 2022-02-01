//
//  BudgetViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit

class BudgetViewController: BaseViewController {
    @IBOutlet weak var leftBoxView: UIView!
    @IBOutlet weak var rightBoxView: UIView!
    @IBOutlet weak var budgetBoxView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var leftMenuLabel: UILabel!
    @IBOutlet weak var rightMenuLabel: UILabel!
    @IBOutlet weak var leftValueLabel: UILabel!
    @IBOutlet weak var rightValueLabel: UILabel!
    @IBOutlet weak var budgeMenuLabel: UILabel!
    @IBOutlet weak var budgetTextField: PriceTextField!
    
    @IBOutlet weak var doneButtonBottomPadding: NSLayoutConstraint!
    
    @IBOutlet weak var cycleButton: UIButton!
    @IBOutlet weak var cycleStartButton: UIButton!
    @IBOutlet weak var currencyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func setupUI() {
        setupPrefersLargeTitles()
        
        title = "start_plan_button_title".localized()
        
        leftBoxView.setupCornerRadius()
        rightBoxView.setupCornerRadius()
        budgetBoxView.setupCornerRadius()
        doneButton.setupCornerRadius()
        
        leftMenuLabel.text = "cycle_menu".localized()
        
        if Budget.isSavedBudget() {
            let budget = Budget.load()
            
            if budget.cycleTerm == .monthly {
                leftValueLabel.text = "cycle_value_monthly".localized()
                
                rightMenuLabel.text = "start_day_menu".localized()
                rightValueLabel.text = "\(budget.startDay)"
            } else {
                leftValueLabel.text = "cycle_value_weekly".localized()
                rightValueLabel.text = weekdayNameFrom(at: budget.dayOfTheWeek.rawValue)
                rightMenuLabel.text = "start_day_of_week_menu".localized()
            }
            
            setupRightButton(monthly: budget.cycleTerm == .monthly)
            budgetTextField.text = budget.priceString
            doneButton.alpha = 1.0
        } else {
            leftValueLabel.text = "cycle_value_monthly".localized()
            rightValueLabel.text = "1"
            rightMenuLabel.text = "start_day_menu".localized()
            doneButton.alpha = 0.6
            setupRightButton(monthly: true)
        }
        
        budgeMenuLabel.text = "budget_menu".localized()
        budgetTextField.placeholder = "budget_textfield_placeholder".localized()
        budgetTextField.didChangeText = { [weak self] in
            self?.doneButton.alpha = $0?.isEmpty == true ? 0.6 : 1.0
        }
        
        doneButton.setTitle("common_save".localized(), for: .normal)
                
        registerKeyboardShowNotification(selector: #selector(keyboardWillShow(notification:)))
        registerKeyboardHideNotification(selector: #selector(keyboardWillHide(notification:)))
        
        setupLeftButton()
        setupCurrency()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        budgetTextField.becomeFirstResponder()
    }
    
    private func setupCurrency() {
        currencyLabel.text = CurrencyManager.viewCurrency
    }
        
    private func setupRightButton(monthly: Bool) {
        if monthly {
            let actions = Array(1...31).map { day in
                return UIAction(title: "\(day)") { [weak self] _ in
                    self?.rightValueLabel.text = "\(day)"
                }
            }
            
            cycleStartButton.menu = UIMenu(title: "start_day_menu".localized(), options: .displayInline, children: actions)
            cycleStartButton.showsMenuAsPrimaryAction = true
        } else {
            let actions = getWeekdays().map { day in
                return UIAction(title: day) { [weak self] _ in
                    self?.rightValueLabel.text = day
                }
            }
            
            cycleStartButton.menu = UIMenu(title: "start_day_of_week_menu".localized(), options: .displayInline, children: actions)
            cycleStartButton.showsMenuAsPrimaryAction = true
        }
    }
    
    private func setupLeftButton() {
        let month = UIAction(title: "cycle_value_monthly".localized()) { [weak self] _ in
            self?.leftValueLabel.text = "cycle_value_monthly".localized()
            self?.setupCycleUI(monthly: true)
        }
        
        let week = UIAction(title: "cycle_value_weekly".localized()) { [weak self] _ in
            self?.leftValueLabel.text = "cycle_value_weekly".localized()
            self?.setupCycleUI(monthly: false)
        }
        
        cycleButton.menu = UIMenu(title: "cycle_menu".localized(),
                                     image: nil,
                                     identifier: nil,
                                     options: .displayInline,
                                     children: [month, week])
        cycleButton.showsMenuAsPrimaryAction = true
    }
    
    private func setupCycleUI(monthly: Bool) {
        setupRightButton(monthly: monthly)
        
        if monthly {
            rightMenuLabel.text = "start_day_menu".localized()
            rightValueLabel.text = "1"
        } else {
            rightMenuLabel.text = "start_day_of_week_menu".localized()
            rightValueLabel.text = weekdayNameFrom(at: 1)
        }
    }
    
    func getWeekdays() -> [String] {
        let df = DateFormatter()
        df.locale = NSLocale.current
        return df.weekdaySymbols
    }
    
    func weekdayNameFrom(at weekdayNumber: Int) -> String {
        let df = DateFormatter()
        df.locale = NSLocale.current
        return df.weekdaySymbols[weekdayNumber]
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        guard !budgetTextField.isEmpty else { return }
        
        let term: Budget.CycleTerm = leftValueLabel.text == "cycle_value_monthly".localized() ? .monthly : .weekly        
        let dayOfTheWeek: Budget.DayOfTheWeek
        let startDay: Int
        
        if term == .monthly {
            dayOfTheWeek = .monday
            startDay = Int(rightValueLabel.text ?? "1") ?? 1
        } else {
            guard let day = rightValueLabel.text else { return }
            guard let index = getWeekdays().firstIndex(where: { $0 == day }) else { return }
            dayOfTheWeek = Budget.DayOfTheWeek(rawValue: index) ?? .monday
            startDay = 1
        }
        
        let budget = Budget(cycleTerm: term, price: budgetTextField.doubleValue, dayOfTheWeek: dayOfTheWeek, startDay: startDay)
        budget.save()
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func leftMenuButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        
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
}
