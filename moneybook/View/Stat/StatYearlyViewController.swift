//
//  StatYearlyViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/19.
//

import UIKit

class StatYearlyViewController: BaseViewController {
    enum Section: Int, CaseIterable {
        case date
        case expend
        case expendChart
        case income
        case incomeChart
    }
    
    @IBOutlet weak var tableView: UITableView!
    private var startDate = Date()
    private var endDate = Date()
    var items = [Item]()
    var totalIncome: Double = 0
    var totalExpend: Double = 0
    var itemsOfChart = [String: [String: [Item]]]()
    var sortByItems = [[Item]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(DateSmallPickerTableViewCell.self)
        tableView.registerNib(StatSummaryTableViewCell.self)
        tableView.registerNib(BudgetReportChartTableViewCell.self)
        tableView.registerNib(ItemListTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        startDate = getStartDate(date: Date())
        endDate = getEndDate(start: startDate)
    }
    
    override func updateData() {
        self.items = (try? AppDatabase.shared.loadItems(fromDateInt: startDate.toInt, toDateInt: endDate.toInt, types: [.expenditure, .income])) ?? [Item]()
        
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
        
        self.itemsOfChart = Item.makeChartData(startDate: startDate, endDate: endDate, items: items, month: true)
        
        tableView.reloadData()
    }
    
    private func getStartDate(date: Date) -> Date {
        let year = date.thisYear
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: "\(year)-01-01") ?? Date()
    }
    
    private func getEndDate(start: Date) -> Date {
        let dayComp = DateComponents(year: 1)
        let onePlusMonth = Calendar.current.date(byAdding: dayComp, to: start) ?? Date()
        return Calendar.current.date(byAdding: DateComponents(day: -1), to: onePlusMonth) ?? Date()
    }
    
    private func updatePrevious() {
        let date = Calendar.current.date(byAdding: DateComponents(year: -1), to: startDate) ?? Date()
        startDate = getStartDate(date: date)
        endDate = getEndDate(start: startDate)
        updateData()
    }
    
    private func updateNext() {
        let date = Calendar.current.date(byAdding: DateComponents(year: 1), to: startDate) ?? Date()
        startDate = getStartDate(date: date)
        endDate = getEndDate(start: startDate)
        updateData()
    }
}

extension StatYearlyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = Section(rawValue: section)
        if s == .date || s == .expend || s == .expendChart || s == .income || s == .incomeChart {
            return 1
        } else {
            return sortByItems[section - 5].count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = Section(rawValue: indexPath.section)
        switch section {
        case .date:
            return 55
            
        case .expend:
            return 80
            
        case .expendChart:
            return totalExpend == 0 ? 0 : 200
            
        case .income:
            return 80
            
        case .incomeChart:
            return totalIncome == 0 ? 0 : 200
            
        case .none:
            return 50
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count + sortByItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)
        switch section {
        case .date:
            let cell = tableView.dequeueReusableCell(DateSmallPickerTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(startDate: startDate, endDate: endDate)
            cell.didTapPrevious = { [weak self] in
                self?.updatePrevious()
            }
            
            cell.didTapNext = { [weak self] in
                self?.updateNext()
            }
            
            return cell
            
        case .expend:
            let cell = tableView.dequeueReusableCell(StatSummaryTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(title: "total_expend_price".localized(), value: totalExpend)
            return cell
            
        case .expendChart:
            let cell = tableView.dequeueReusableCell(BudgetReportChartTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(items: self.itemsOfChart, income: false)
            return cell
            
        case .income:
            let cell = tableView.dequeueReusableCell(StatSummaryTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(title: "total_income_price".localized(), value: totalIncome)
            return cell
            
        case .incomeChart:
            let cell = tableView.dequeueReusableCell(BudgetReportChartTableViewCell.self, forIndexPath: indexPath)
            cell.updateUI(items: self.itemsOfChart, income: true)
            return cell
            
        case .none:
            let cell = tableView.dequeueReusableCell(ItemListTableViewCell.self, forIndexPath: indexPath)
            let item = sortByItems[indexPath.section - 5][indexPath.row]
            cell.updateUI(item: item)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section >= Section.allCases.count else { return }
        
        let item = self.sortByItems[indexPath.section - 5][indexPath.row]
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
        guard let item = self.sortByItems[section - 5].first else { return nil }
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: item.date.toString)
        return view
    }
}

extension StatYearlyViewController: CalendarItems {
    var calendarItems: [Item] {
        items
    }
}
