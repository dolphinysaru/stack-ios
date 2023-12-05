//
//  GraphTableViewCell.swift
//  moneybook
//
//  Created by jedmin on 2022/01/23.
//

import UIKit
import DGCharts

class GraphTableViewCell: UITableViewCell {
    @IBOutlet weak var chartView: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }

    private func setupUI() {
        chartView.transparentCircleColor = .clear
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.noDataTextColor = .secondaryLabel
        chartView.noDataFont = .systemFont(ofSize: 13, weight: .medium)
        chartView.holeColor = .systemBackground
 
        let l = chartView.legend
        l.horizontalAlignment = .right
        l.verticalAlignment = .top
        l.orientation = .vertical
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
    }
    
    func updateUI(set: PieChartDataSet?, percent: Bool, noDataText: String) {
        guard let set = set else {
            chartView.data = nil
            chartView.noDataText = noDataText
            return
        }

        set.colors = [UIColor.systemBlue,
                      UIColor.systemGreen,
                      UIColor.systemRed,
                      UIColor.systemOrange,
                      UIColor.systemYellow,
                      UIColor.systemPink,
                      UIColor.systemPurple,
                      UIColor.systemTeal,
                      UIColor.systemIndigo,
                      UIColor.systemBrown]
        
        set.sliceSpace = 3
        set.entryLabelFont = .systemFont(ofSize: 11, weight: .semibold)
        set.entryLabelColor = .white
        
        let data = PieChartData(dataSet: set)
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .semibold))
        data.setValueTextColor(.white)
        
        chartView.data = data
        chartView.usePercentValuesEnabled = percent
        
        if percent {
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .percent
            pFormatter.maximumFractionDigits = 1
            pFormatter.multiplier = 1
            pFormatter.percentSymbol = " %"
            data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        } else {
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 1
            pFormatter.multiplier = 1
            pFormatter.percentSymbol = CurrencyManager.currencySymbol
            data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        }
    }
}
