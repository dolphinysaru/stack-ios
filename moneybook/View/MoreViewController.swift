//
//  MoreViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit
import MessageUI
import StoreKit
import Toast_Swift
import StoreKit
import SafariServices

class MoreViewController: BaseViewController {
    enum Section: Int, CaseIterable {
        case iap
        case featured
        case review
        case category
        case plan
        case currency
        
        var title: String? {
            switch self {
            case .iap:
                return "buy".localized()
            case .featured:
                return "featured".localized()
            case .review:
                return "service".localized()
            case .category:
                return "category_title".localized()
            case .plan:
                return "plan_title".localized()
            case .currency:
                return "currency_section_title".localized()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    var featuredApp = [FeaturedApp]()
    var proProduct: SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        title = "more_title".localized()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(MoreTableViewCell.self)
        tableView.register(UINib(nibName: "FeaturedTableViewCell", bundle: nil), forCellReuseIdentifier: "FeaturedTableViewCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bannerHeight + 10, right: 0)
        
        RemoteConfigManager.shared.fetchRemoteConfig(currentAppId: "1607015385") { [weak self] featured in
            self?.featuredApp = featured
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        InAppProducts.store.requestProducts { [weak self] success, products in
            guard let self = self else { return }
            guard success else { return }
            guard let product = products?.first else { return }
            self.proProduct = product
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        isBannerAd = true
    }
    
    private func resetBudget() {
        let alert = UIAlertController(title: "remove_plan_message".localized(), message: nil, preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "delete".localized(), style: .destructive) { [weak self] _ in
            Budget.reset()
            self?.view.makeToast("complete_remove_plan_message".localized())
        }
        alert.addAction(delete)
        
        let cancel = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String else { return nil }
        let versionAndBuild: String = "vserion: \(version), build: \(build)"
        return versionAndBuild
    }
    
    func mailBody() -> String {
        let appVersion = version ?? "Unknown"
        let osVersion = UIDevice.current.systemVersion
        let deviceInfo = UIDevice.modelName
        
        return "\n\n\nAsk for Stack\nVersion : \(appVersion)\niOS Version : \(osVersion)\nDevice Model : \(deviceInfo)"
    }
}

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    private func shareApplication() {
        let appID = "1607015385"
        let items = [URL(string: "https://itunes.apple.com/app/id\(appID)")!]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    private func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setToRecipients(["dolphiny.saru@gmail.com"])
            mailComposerVC.setMessageBody(mailBody(), isHTML: false)
            present(mailComposerVC, animated: true, completion: nil)
        } else {
            let recipients = "mailto:dolphiny.saru@gmail.com"
            UIApplication.shared.open(URL(string: recipients)!, options: [:], completionHandler: nil)
        }
    }
    
    func requestReview() {
        let viewController = SKStoreProductViewController()
        viewController.delegate = self
        let parameters = [SKStoreProductParameterITunesItemIdentifier: 1607015385]
        viewController.loadProduct(withParameters: parameters, completionBlock: nil)
        self.present(viewController, animated: true, completion: nil)
    }
    
    func openSafari(_ url: String) {
        guard let url = URL(string: url) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
     }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let s = Section(rawValue: indexPath.section)
        switch s {
        case .iap:
            if indexPath.row == 0 {
                guard !InAppProducts.store.isProductPurchased(InAppProducts.product) else { return }
                
                InAppProducts.store.requestProducts(
                    { success, products in
                        guard success else { return }
                        guard let product = products?.first else { return }
                        InAppProducts.store.buyProduct(product) { [weak self] success, message in
                            guard let self = self else { return }
                            let title: String
                            if success {
                                title = "already_iap_buy".localized()
                            } else {
                                title = "failed_iap_buy".localized()
                            }
                            
                            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                            let ok = UIAlertAction(title: "common_confirm".localized(), style: .default, handler: nil)
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                            
                            self.tableView.reloadData()
                        }
                    }
                )
            } else if indexPath.row == 1 && !InAppProducts.store.isProductPurchased(InAppProducts.product) {
                InAppProducts.store.restorePurchases { [weak self] success, message in
                    guard let self = self else { return }
                    let title: String
                    if success {
                        title = "success_restore".localized()
                    } else {
                        title = "fail_restore".localized()
                    }
                    
                    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "common_confirm".localized(), style: .default, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                    self.tableView.reloadData()
                }
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let term = UIAlertAction(title: "terms_of_use".localized(), style: .default) { [weak self] _ in
                    self?.openSafari("https://flower-cough-b87.notion.site/Terms-of-Use-c0b4c8935d004c9b8764fba4ca23271e")
                }
                
                alert.addAction(term)
                
                let privacy = UIAlertAction(title: "privacy_policy".localized(), style: .default) { [weak self] _ in
                    self?.openSafari("https://flower-cough-b87.notion.site/Privacy-Policy-fc135c7efaaf4f6f8fccdda256de81cf")
                }
                alert.addAction(privacy)
                
                let cancel = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
            }
            
        case .featured:
            break
            
        case .review:
            if indexPath.row == 0 {
                shareApplication()
            } else if indexPath.row == 1 {
                requestReview()
            } else {
                sendMail()
            }
            
        case .category:
            let vc = CategoryEditViewController(nibName: "CategoryEditViewController", bundle: nil)
            if indexPath.row == 0 {
                vc.categoryType = .expenditure
            } else if indexPath.row == 1 {
                vc.categoryType = .payment
            } else {
                vc.categoryType = .income
            }
            
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .plan:
            if indexPath.row == 0 {
                let vc = BudgetViewController(nibName: "BudgetViewController", bundle: nil)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                resetBudget()
            }
            
        case .currency:
            let vc = CurrencyEditViewController(nibName: "CurrencyEditViewController", bundle: nil)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .none: break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = Section(rawValue: section)
        switch s {
        case .iap:
            return InAppProducts.store.isProductPurchased(InAppProducts.product) ? 2 : 3
        case .featured:
            return featuredApp.count
        case .review:
            return 3
        case .category:
            return 3
        case .plan:
            return 2
        case .currency:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let s = Section(rawValue: indexPath.section)
        switch s {
        case .iap:
            let cell = tableView.dequeueReusableCell(MoreTableViewCell.self, forIndexPath: indexPath)
            if indexPath.row == 0 {
                if InAppProducts.store.isProductPurchased(InAppProducts.product) {
                    cell.textLabel?.text = "already_iap_buy".localized()
                } else {
                    cell.textLabel?.text = "buy".localized() + ", " + (proProduct?.localizedPrice ?? "") + "/" + "month".localized()
                }
            } else if indexPath.row == 1 && !InAppProducts.store.isProductPurchased(InAppProducts.product) {
                cell.textLabel?.text = "restore".localized()
            } else {
                cell.textLabel?.text = "term_privacy_policy".localized()
            }
            
            return cell
            
        case .featured:
            let app = featuredApp[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeaturedTableViewCell", for: indexPath) as! FeaturedTableViewCell
            cell.updateUI(
                icon: app.icon,
                appname: app.appname.localiedString,
                description: app.description.localiedString,
                appId: app.appid
            )
            return cell
        case .review:
            let cell = tableView.dequeueReusableCell(MoreTableViewCell.self, forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "share_title".localized()
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "review_title".localized()
            } else {
                cell.textLabel?.text = "email_send_title".localized()
            }
            
            return cell
        case .category:
            let cell = tableView.dequeueReusableCell(MoreTableViewCell.self, forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = CategoryType.expenditure.editViewTitle
            } else if indexPath.row == 1 {
                cell.textLabel?.text = CategoryType.payment.editViewTitle
            } else {
                cell.textLabel?.text = CategoryType.income.editViewTitle
            }
            
            return cell
        case .plan:
            let cell = tableView.dequeueReusableCell(MoreTableViewCell.self, forIndexPath: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "plan_edit".localized()
            } else {
                cell.textLabel?.text = "plan_reset".localized()
            }
            
            return cell
            
        case .currency:
            let cell = tableView.dequeueReusableCell(MoreTableViewCell.self, forIndexPath: indexPath)
            cell.textLabel?.text = "currency_setting_title".localized()
            return cell
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        let s = Section(rawValue: section)
        if s == .iap {
            view.updateUI(title: (proProduct?.localizedTitle ?? "") + ", " + (proProduct?.localizedDescription ?? ""))
        } else {
            view.updateUI(title: Section(rawValue: section)?.title ?? "")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let s = Section(rawValue: section)
        if s == .iap {
            return 35
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        let s = Section(rawValue: section)
        if s == .iap {
            let title = String(format: "proversion_footer".localized(), (proProduct?.localizedPrice ?? ""))
            view.updateUI(title: title)
            return view
        } else {
            return nil
        }
    }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension MoreViewController: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
