//
//  BudgetReportChartTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/10.
//

import UIKit
import DGCharts

class BudgetReportChartTableViewCell: UITableViewCell {
    @IBOutlet weak var chartView: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    func setupUI() {
        chartView.delegate = self
        chartView.backgroundColor = .systemBackground
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.drawBordersEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.highlightFullBarEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.dragXEnabled = false
        chartView.dragYEnabled = false
                
        let l = chartView.legend
        l.textColor = .clear
        l.form = .none
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .secondaryLabel
        xAxis.axisLineColor = .clear
        xAxis.gridColor = .clear
        xAxis.granularity = 1
                
        let yAxis = chartView.leftAxis
        yAxis.labelFont = UIFont.systemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .clear
        yAxis.labelPosition = .insideChart
        yAxis.axisLineColor = .clear
        yAxis.gridColor = .clear
        
        let yRaxis = chartView.rightAxis
        yRaxis.axisLineColor = .clear
        yRaxis.labelTextColor = .secondaryLabel
        yRaxis.gridColor = .quaternaryLabel
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(items: [String: [String: [Item]]], income: Bool = false) {
        if income {
            let incomeVals = items.map { date -> BarChartDataEntry in
                let items = date.value[ItemType.income.rawValue]
                let sum = Budget.sumPriceOfItems(items ?? [Item]())
                return BarChartDataEntry(x: Double(date.key.suffix(2)) ?? 0, y: sum)
            }
            
            let set1 = BarChartDataSet(entries: incomeVals, label: "")
            set1.colors = [UIColor.systemGreen]
            
            let data = BarChartData(dataSets: [set1])
            data.setValueTextColor(.clear)
            chartView.data = data
        } else {
            let expendVals = items.map { date -> BarChartDataEntry in
                let items = date.value[ItemType.expenditure.rawValue]
                let sum = Budget.sumPriceOfItems(items ?? [Item]())
                return BarChartDataEntry(x: Double(date.key.suffix(2)) ?? 0, y: sum)
            }
            
            let set1 = BarChartDataSet(entries: expendVals, label: "")
            set1.colors = [UIColor.systemRed]
            
            let data = BarChartData(dataSets: [set1])
            data.setValueTextColor(.clear)
            chartView.data = data
        }
    }
    
    func updateUI(expend: Double, income: Double) {
        let paddingData1 = BarChartDataEntry(x: 0, y: 0)
        let expendData = BarChartDataEntry(x: 1, y: expend)
        let incomeData = BarChartDataEntry(x: 2, y: income)
        let paddingData2 = BarChartDataEntry(x: 3, y: 0)
        
        let set1 = BarChartDataSet(entries: [paddingData1, expendData, incomeData, paddingData2], label: "summary")
        set1.colors = [UIColor.systemRed, UIColor.systemRed, UIColor.systemGreen, UIColor.systemGreen]
        let data = BarChartData(dataSet: set1)
        data.setValueTextColor(.clear)
        chartView.data = data
        
        let xAxis = chartView.xAxis
        xAxis.setLabelCount(0, force: true)
        xAxis.labelTextColor = .clear
    }
    
    private func classificationDate(items: [Item]) -> [String: [String: [Item]]] {
        let budget = Budget.load()
        var dates = [String: [String: [Item]]]()
        guard let start = budget.startDate()?.toString(with: "yyyyMMdd") else { return dates }
        guard let end = budget.endDate()?.toString(with: "yyyyMMdd") else { return dates }
        
        guard let startInt = Int(start) else { return dates }
        guard let endInt = Int(end) else { return dates }
                
        for v in (startInt...endInt) {
            var d = [String: [Item]]()
            d[ItemType.expenditure.rawValue] = [Item]()
            d[ItemType.income.rawValue] = [Item]()
            
            dates["\(v)"] = d
        }
                
        items.forEach { item in
            let date = item.date.toString(with: "yyyyMMdd")
            if var d = dates[date], var i = d[item.type.rawValue] {
                i.append(item)
                d[item.type.rawValue] = i
                dates[date] = d
            }
        }
        
        return dates
    }
}

extension BudgetReportChartTableViewCell: ChartViewDelegate {
    
}
