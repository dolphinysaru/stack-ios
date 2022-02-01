//
//  CurrencyEditViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/25.
//

import UIKit

class CurrencyEditViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var currencys = [Currency]()
    
    override func setupUI() {
        title = "currency_setting_title".localized()
        
        currencys = Array(Set(Locale
            .availableIdentifiers
            .compactMap {
                let locale = Locale(identifier: $0)
                guard let symbol = locale.currencySymbol else { return nil }
                guard let code = locale.currencyCode else { return nil }
                return Currency(symbol: symbol, code: code)
        })).sorted(by: {
            $0.code < $1.code
        })
        
        if let index = currencys.firstIndex(of: CurrencyManager.currentCurrency) {
            currencys.remove(at: index)
            currencys.insert(CurrencyManager.currentCurrency, at: 0)
        }
        
        let current = Currency(symbol: Locale.current.currencySymbol ?? "", code: Locale.current.currencyCode ?? "")
        if let index = currencys.firstIndex(of: current), index != 0 {
            currencys.remove(at: index)
            currencys.insert(current, at: 1)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrencyEditViewController")
    }
}

extension CurrencyEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CurrencyManager.setupCurrency(currency: currencys[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyEditViewController", for: indexPath)
        let currency = currencys[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cell.textLabel?.text = currency.code + " - " + currency.symbol
        return cell
    }
}
