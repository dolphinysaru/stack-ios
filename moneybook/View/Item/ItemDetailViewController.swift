//
//  ItemDetailViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/11.
//

import UIKit

class ItemDetailViewController: BaseViewController {
    enum ExpendSection: Int, CaseIterable {
        case date
        case price
        case payment
        case memo
        
        var title: String {
            switch self {
            case .date:
                return "date_title".localized()
            case .price:
                return "price_title".localized()
            case .payment:
                return "payment_catgory".localized()
            case .memo:
                return "memo".localized()
            }
        }
    }
    
    enum IncomeSection: Int, CaseIterable {
        case date
        case price
        case memo
        
        var title: String {
            switch self {
            case .date:
                return "date_title".localized()
            case .price:
                return "price_title".localized()
            case .memo:
                return "memo".localized()
            }
        }
    }
    
    var item: Item
    
    @IBOutlet weak var tableView: UITableView!
    
    init(item: Item) {
        self.item = item
        super.init(nibName: "ItemDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
            
    override func updateData() {
        guard let id = item.id else { return }
        guard let item = try? AppDatabase.shared.loadItem(id) else { return }
        self.item = item
        
        if let category = try? AppDatabase.shared.loadCategory(item.kindId) {
            title = category.icon + " " + category.title
        }
        
        tableView.reloadData()
    }
        
    override func setupUI() {
        tableView.registerNib(ItemListTableViewCell.self)
        tableView.registerNib(ItemTitleTableViewCell.self)
        tableView.registerNib(ItemMemoTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonAction))
        let deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonAction))
        self.navigationItem.rightBarButtonItems = [editBarButtonItem, deleteBarButtonItem]
    }
    
    @objc func deleteButtonAction() {
        let alert = UIAlertController(title: "delete_alert_title".localized(), message: nil, preferredStyle: .actionSheet)
        
        let ok = UIAlertAction(title: "delete".localized(), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            try? AppDatabase.shared.removeItem(self.item)
            Budget.syncAppGroupData()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction(title: "cancel".localized(), style: .cancel) { _ in
            
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editButtonAction() {
        let vc = InputPriceViewController(nibName: "InputPriceViewController", bundle: nil)
        vc.editItem = item
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ItemDetailViewController: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       if item.type == .income {
           let section = IncomeSection(rawValue: indexPath.section)
           if section == .memo {
               return UITableView.automaticDimension
           }
       } else {
           let section = ExpendSection(rawValue: indexPath.section)
           if section == .memo {
               return UITableView.automaticDimension
           }
       }
       
       return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        item.type == .income ? IncomeSection.allCases.count : ExpendSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       if item.type == .income {
            let section = IncomeSection(rawValue: indexPath.section)
            switch section {
            case .date:
                let cell = tableView.dequeueReusableCell(ItemTitleTableViewCell.self, forIndexPath: indexPath)
                cell.updateUI(text: item.date.toString)
                return cell
            case .price:
                let cell = tableView.dequeueReusableCell(ItemTitleTableViewCell.self, forIndexPath: indexPath)
                cell.updateUI(text: CurrencyManager.currencySymbol + " + " + "\(item.price)".price())
                return cell
            case .memo:
                let cell = tableView.dequeueReusableCell(ItemMemoTableViewCell.self, forIndexPath: indexPath)
                cell.updateUI(text: item.memo)
                return cell
            case .none:
                break
            }
        } else {
            let section = ExpendSection(rawValue: indexPath.section)
            switch section {
            case .date:
                let cell = tableView.dequeueReusableCell(ItemTitleTableViewCell.self, forIndexPath: indexPath)
                cell.updateUI(text: item.date.toString)
                return cell
            case .price:
                let cell = tableView.dequeueReusableCell(ItemTitleTableViewCell.self, forIndexPath: indexPath)
                cell.updateUI(text: CurrencyManager.currencySymbol + " - " + "\(item.price)".price())
                return cell
            case .payment:
                let cell = tableView.dequeueReusableCell(ItemListTableViewCell.self, forIndexPath: indexPath)
                if let id = item.paymentId, let category = try? AppDatabase.shared.loadCategory(id) {
                    let image = UIImage.imageWithEmoji(emoji: category.icon, fontSize: 100, size: CGSize(width: 200, height: 200))
                    cell.updateUI(title: category.title, icon: image)
                }
                return cell
            case .memo:
                let cell = tableView.dequeueReusableCell(ItemMemoTableViewCell.self, forIndexPath: indexPath)
                cell.updateUI(text: item.memo)
                return cell
            case .none:
                break
            }
        }
        
        let cell = tableView.dequeueReusableCell(ItemListTableViewCell.self, forIndexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title: String
        if item.type == .income {
            let section = IncomeSection.allCases[section]
            title = section.title
        } else {
            let section = ExpendSection.allCases[section]
            title = section.title
        }
        
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: title)
        return view
        
    }
}
