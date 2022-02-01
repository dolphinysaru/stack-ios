//
//  BugetReportViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/10.
//

import UIKit

class BugetReportViewController: BaseViewController {
    var budget = Budget.load()
    var items = [[Item]]()
    var itemsOfChart = [String: [String: [Item]]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func updateData() {
        budget = Budget.load()
        self.title = (budget.shortStartDay ?? "") + "~" + (budget.shortEndDay ?? "")
        
        loadItems()
        tableView.reloadData()
    }
    
    func loadItems() {
        guard let items = try? budget.items(types: [.expenditure]) else { return }
        
        self.items = Item.sortByDate(items: items)
        updateDataOfChart(items: items)
    }
    
    private func updateDataOfChart(items: [Item]) {
        let budget = Budget.load()
        guard let start = budget.startDate() else { return }
        guard let end = budget.endDate() else { return }
        self.itemsOfChart = Item.makeChartData(startDate: start, endDate: end, items: items)
    }
    
    override func setupUI() {
        let rightBarButtonItem = UIBarButtonItem(title: "plan_edit".localized(), style: .done, target: self, action: #selector(editButtonAction))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(BudgetReportTopTableViewCell.self)
        tableView.registerNib(BudgetReportChartTableViewCell.self)
        tableView.registerNib(ItemListTableViewCell.self)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc
    func editButtonAction() {
        let vc = BudgetViewController(nibName: "BudgetViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension BugetReportViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section != 0 && indexPath.section != 1 else { return }
        
        let item = self.items[indexPath.section - 2][indexPath.row]
        let vc = ItemDetailViewController.init(item: item)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else if indexPath.section == 1{
            return 200
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        } else {
            return items[section - 2].count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2 + items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(BudgetReportTopTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(header: budget.cycleTerm.title, price: CurrencyManager.currencySymbol + " " + "\(budget.totalExpend)".price())
            cell.didTapAddButton = { [weak self] in
                let vc = InputPriceViewController(nibName: "InputPriceViewController", bundle: nil)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(BudgetReportChartTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(items: self.itemsOfChart)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(ItemListTableViewCell.self, forIndexPath: indexPath)
            let item = items[indexPath.section - 2][indexPath.row]
            cell.updateUI(item: item)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 && section != 1 else { return 0.1 }
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section != 0 && section != 1 else { return nil }
        guard let item = self.items[section - 2].first else { return nil }
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: item.date.toString)
        return view
    }
}
