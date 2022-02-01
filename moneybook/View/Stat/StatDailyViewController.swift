//
//  StatDailyViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/19.
//

import UIKit

class StatDailyViewController: BaseViewController {
    enum Section: Int, CaseIterable {
        case date
        case summary
        case chart
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate = Date() {
        didSet {
            updateData()
        }
    }
    
    var items = [Item]()
    var sortByItems = [[Item]]()
    var totalIncome: Double = 0
    var totalExpend: Double = 0
    
    override func updateData() {
        self.items = (try? AppDatabase.shared.loadItems(dateInt: selectedDate.toInt, types: [.expenditure, .income])) ?? [Item]()
        
        self.sortByItems = Item.sortByDate(items: items)
        
        totalIncome = items.filter {
            $0.type == .income
        }.reduce(0) { partialResult, item in
            partialResult + item.price
        }
        
        totalExpend = items.filter {
            $0.type == .expenditure
        }.reduce(0) { partialResult, item in
            partialResult + item.price
        }
        
        tableView.reloadData()
    }
    
    override func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(ItemListTableViewCell.self)
        tableView.registerNib(DatePickerTableViewCell.self)
        tableView.registerNib(StatSummaryTableViewCell.self)
        tableView.registerNib(BudgetReportChartTableViewCell.self)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }   
    }
}

extension StatDailyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = Section(rawValue: indexPath.section)
        switch section {
        case .date:
            return UITableView.automaticDimension
            
        case .summary:
            return 158
            
        case .chart:
            return totalIncome == 0 && totalExpend == 0 ? 0 : 200
            
        case .none:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = Section(rawValue: section)
        if s == .date || s == .summary || s == .chart {
            return 1
        } else {
            return sortByItems[section - 3].count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count + sortByItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)
        switch section {
        case .date:
            let cell = tableView.dequeueReusableCell(DatePickerTableViewCell.self, forIndexPath: indexPath)
            cell.didChangeDate = { [weak self] in
                self?.selectedDate = $0
            }
            return cell
        case .summary:
            let cell = tableView.dequeueReusableCell(StatSummaryTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(income: totalIncome, expend: totalExpend)
            return cell
            
        case .chart:
            let cell = tableView.dequeueReusableCell(BudgetReportChartTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(expend: totalExpend, income: totalIncome)
            return cell
            
        case .none:
            let cell = tableView.dequeueReusableCell(ItemListTableViewCell.self, forIndexPath: indexPath)
            let item = sortByItems[indexPath.section - 3][indexPath.row]
            cell.updateUI(item: item)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section >= Section.allCases.count else { return }
        
        let item = self.sortByItems[indexPath.section - 3][indexPath.row]
        let vc = ItemDetailViewController.init(item: item)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section >= Section.allCases.count else { return 0.1 }
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section >= Section.allCases.count else { return nil }
        guard let item = self.sortByItems[section - 3].first else { return nil }
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: item.date.toString)
        return view
    }
}

extension StatDailyViewController: CalendarItems {
    var calendarItems: [Item] {
        items
    }
}
