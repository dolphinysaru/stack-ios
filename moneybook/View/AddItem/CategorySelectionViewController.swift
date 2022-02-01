//
//  CategorySelectionViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/02.
//

import UIKit

class CategorySelectionViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var categories = [Category]()
    let categoryType: CategoryType
    var editItem: Item?
    
    init(type: CategoryType, editItem: Item?) {
        self.categoryType = type
        self.editItem = editItem
        super.init(nibName: "CategorySelectionViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupUI() {
        title = categoryType.title
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(CategoryCollectionViewCell.self)
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func updateData() {
        super.updateData()
        
        loadData()
    }
    
    @objc func addCategory() {
        let vc = CategoryAddViewController(type: categoryType)
        vc.didAddCategory = { [weak self] in
            self?.updateData()
        }
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    func loadData() {
        let categories = try? AppDatabase.shared.loadCategories(type: categoryType)
        guard let categories = categories else { return }
        self.categories = categories.filter { $0.visible }
        
        collectionView.reloadData()
    }
}

extension CategorySelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath, cellType: CategoryCollectionViewCell.self)
        cell.updateUI(category: categories[indexPath.row])
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        switch categoryType {
        case .income:
            let vc = InputMemoViewController(nibName: "InputMemoViewController", bundle: nil)
            vc.editItem = editItem
            navigationController?.pushViewController(vc, animated: true)
            AddItemManager.shared.kind = category
            
        case .expenditure:
            let vc = CategorySelectionViewController.init(type: .payment, editItem: editItem)
            navigationController?.pushViewController(vc, animated: true)
            AddItemManager.shared.kind = category
            
        case .payment:
            let vc = InputMemoViewController(nibName: "InputMemoViewController", bundle: nil)
            vc.editItem = editItem
            navigationController?.pushViewController(vc, animated: true)
            AddItemManager.shared.payment = category
        }
    }
}
