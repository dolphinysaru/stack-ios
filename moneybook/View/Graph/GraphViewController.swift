//
//  GraphViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/23.
//

import UIKit
import Charts

class GraphViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var items = [Item]()
    var percentMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        title = "stat_title".localized()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(GraphTableViewCell.self)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        let image = UIImage(systemName: "arrow.triangle.2.circlepath")
        let rightButton = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(swapViewMode))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func swapViewMode() {
        percentMode = !percentMode
        tableView.reloadData()
    }
    
    var expendCategorySet: PieChartDataSet?
    var expendPaymentSet: PieChartDataSet?
    var incomeCategorySet: PieChartDataSet?
    
    private func setupExpendCategoryData() {
        var sorts = [String: Double]()
        
        // 지출 - 항목별
        items.filter {
            $0.type == .expenditure
        }.forEach {
            let kind = ($0.kind?.icon ?? "") + ($0.kind?.title ?? "")
            sorts[kind] = (sorts[kind] ?? 0) + $0.price
        }
        
        let expendCategoryData = sorts.map {
            return PieChartDataEntry(value: $0.value, label: $0.key)
        }.sorted {
            $0.value > $1.value
        }
                
        if expendCategoryData.isEmpty {
            expendCategorySet = nil
        } else {
            expendCategorySet = PieChartDataSet(entries: expendCategoryData, label: nil)
        }
    }
    
    private func setupExpendPaymentData() {
        var sorts = [String: Double]()
        
        // 지출 - 결제별
        items.filter {
            $0.type == .expenditure
        }.forEach {
            let payment = ($0.payment?.icon ?? "") + ($0.payment?.title ?? "")
            sorts[payment] = (sorts[payment] ?? 0) + $0.price
        }
        
        let expendPaymentData = sorts.map {
            return PieChartDataEntry(value: $0.value, label: $0.key)
        }.sorted {
            $0.value > $1.value
        }
                
        if expendPaymentData.isEmpty {
            expendPaymentSet = nil
        } else {
            expendPaymentSet = PieChartDataSet(entries: expendPaymentData, label: nil)
        }
    }
    
    private func setupIncomeCategoryData() {
        var sorts = [String: Double]()
        
        // 수입 - 항목별
        items.filter {
            $0.type == .income
        }.forEach {
            let kind = ($0.kind?.icon ?? "") + ($0.kind?.title ?? "")
            sorts[kind] = (sorts[kind] ?? 0) + $0.price
        }
        
        let incomeCategoryData = sorts.map {
            return PieChartDataEntry(value: $0.value, label: $0.key)
        }.sorted {
            $0.value > $1.value
        }
                
        if incomeCategoryData.isEmpty {
            incomeCategorySet = nil
        } else {
            incomeCategorySet = PieChartDataSet(entries: incomeCategoryData, label: nil)
        }
    }
    
    override func updateData() {
        setupExpendCategoryData()
        setupExpendPaymentData()
        setupIncomeCategoryData()
        tableView.reloadData()
    }
}

extension GraphViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.width
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(GraphTableViewCell.self, forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.updateUI(set: expendCategorySet, percent: percentMode, noDataText: "expend_no_data".localized())
        } else if indexPath.section == 1 {
            cell.updateUI(set: expendPaymentSet, percent: percentMode, noDataText: "expend_no_data".localized())
        } else {
            cell.updateUI(set: incomeCategorySet, percent: percentMode, noDataText: "income_no_data".localized())
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title: String
        if section == 0 {
            title = "expend_category_chart_section".localized()
        } else if section == 1 {
            title = "expend_payment_chart_section".localized()
        } else {
            title = "income_category_chart_section".localized()
        }
        
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: title)
        return view
    }
}
