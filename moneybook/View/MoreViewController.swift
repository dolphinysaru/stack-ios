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

class MoreViewController: BaseViewController {
    enum Section: Int, CaseIterable {
        case featured
        case review
        case category
        case plan
        case currency
        
        var title: String? {
            switch self {
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        
        RemoteConfigManager.shared.fetchRemoteConfig(currentAppId: "1607015385") { [weak self] featured in
            self?.featuredApp = featured
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        gaId = ga_banner_id_setting
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let s = Section(rawValue: indexPath.section)
        switch s {
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
        view.updateUI(title: Section(rawValue: section)?.title ?? "")
        return view
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
