//
//  CategoryEditViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/24.
//

import UIKit

class CategoryEditViewController: BaseViewController {
    var categoryType: CategoryType = .expenditure
    @IBOutlet weak var tableView: UITableView!
    var categories = [Category]()
    var removedCategories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(CategoryEditTableViewCell.self)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func addCategory() {
        showCategoryAddView(category: nil)
    }
    
    func showCategoryAddView(category: Category?) {
        let vc = CategoryAddViewController(type: categoryType, category: category)
        vc.didAddCategory = { [weak self] in
            self?.updateData()
        }
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    override func updateData() {
        self.title = categoryType.editViewTitle
        
        let categories = CoreData.shared.loadCategories(type: categoryType)
        
        self.categories = categories.filter { $0.visible }
        self.removedCategories = categories.filter { !$0.visible }
        
        tableView.reloadData()
    }
}

extension CategoryEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categories.count
        } else {
            return removedCategories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(CategoryEditTableViewCell.self, forIndexPath: indexPath)
        var category: Category
        if indexPath.section == 0 {
            category = categories[indexPath.row]
        } else {
            category = removedCategories[indexPath.row]
        }
        
        cell.updateUI(category: category, removed: indexPath.section != 0)
        cell.didTapEditButton = { [weak self] in
            self?.showCategoryAddView(category: category)
        }
        
        cell.didTapRemoveToggleButton = { [weak self] in
            category.visible = !category.visible
            CoreData.shared.saveCategory(category, isNew: false)
            self?.updateData()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        view.updateUI(title: section == 0 ? "added_category_section_title".localized() : "removed_category_section_title".localized())
        return view
    }
}
