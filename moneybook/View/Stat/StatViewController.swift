//
//  StatViewController.swift
//  moneybook
//
//  Created by jedmin on 2022/01/01.
//

import UIKit

protocol CalendarItems {
    var calendarItems: [Item] { get }
}

class StatViewController: BaseViewController {
    @IBOutlet var cycleButtons: [UIButton]!
    @IBOutlet weak var selectionBarX: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    lazy var dailyVC: StatDailyViewController = {
        let vc = StatDailyViewController(nibName: "StatDailyViewController", bundle: nil)
        return vc
    }()
    
    lazy var weeklyVC: StatWeeklyViewController = {
        let vc = StatWeeklyViewController(nibName: "StatWeeklyViewController", bundle: nil)
        return vc
    }()
    
    lazy var monthlyVC: StatMonthlyViewController = {
        let vc = StatMonthlyViewController(nibName: "StatMonthlyViewController", bundle: nil)
        return vc
    }()
    
    lazy var yearlyVC: StatYearlyViewController = {
        let vc = StatYearlyViewController(nibName: "StatYearlyViewController", bundle: nil)
        return vc
    }()
    
    lazy var dataViewControllers: [UIViewController] = {
        return [dailyVC, weeklyVC, monthlyVC, yearlyVC]
    }()
        
    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return vc
    }()
    
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cycleButtonAction(_ sender: Any) {
        cycleButtons.forEach {
            $0.isSelected = false
        }
        
        (sender as? UIButton)?.isSelected = true
        
        let tag = (sender as? UIButton)?.tag ?? 10
        let index = tag - 10
        if index == selectedIndex {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection = selectedIndex > index ? .reverse : .forward
        
        selectedIndex = index
        
        let width: CGFloat = (self.view.frame.width - 40) / CGFloat(cycleButtons.count)
        
        selectionBarX.constant = 20 + width * CGFloat((index))
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        let vc = dataViewControllers[index]
        pageViewController.setViewControllers([vc], direction: direction, animated: true, completion: nil)
    }
        
    override func setupUI() {
        title = "calendar_title".localized()
        
        cycleButtons.forEach {
            $0.setTitleColor(UIColor.secondaryLabel, for: .normal)
            $0.setTitleColor(UIColor.label, for: .selected)
        }
        
        cycleButtons.first?.isSelected = true
        
        cycleButtons[0].setTitle("daily_calendar".localized(), for: .normal)
        cycleButtons[1].setTitle("weekly_calendar".localized(), for: .normal)
        cycleButtons[2].setTitle("monthly_calendar".localized(), for: .normal)
        cycleButtons[3].setTitle("yearly_calendar".localized(), for: .normal)
                
        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        pageViewController.setViewControllers([dailyVC], direction: .forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let image = UIImage(systemName: "chart.pie.fill")
        let rightButton = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(showChartView))
        navigationItem.rightBarButtonItem = rightButton
        
        isBannerAd = true
        
        if isEnabledAd {
            gadBannerController.didReceivedAd = { [weak self] in
                self?.updateConstraintsOfPageVC()
            }
        }
        
        self.loadGABannerView()
    }
    
    private func updateConstraintsOfPageVC() {
        pageViewController.view.snp.removeConstraints()
        pageViewController.view.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(-50)
        }
    }
    
    @objc func showChartView() {
        let vc = GraphViewController(nibName: "GraphViewController", bundle: nil)
        if let calItems = pageViewController.viewControllers?.first as? CalendarItems {
            vc.items = calItems.calendarItems
        }
        
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
}

extension StatViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = dataViewControllers.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        
        return dataViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = dataViewControllers.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == dataViewControllers.count {
            return nil
        }
        
        return dataViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let vc = pageViewController.viewControllers?.first {
            if let index = dataViewControllers.firstIndex(where: { $0 == vc }) {
                updateButtonUI(index: index)
            }
        }
    }
    
    private func updateButtonUI(index: Int) {
        cycleButtons.forEach {
            $0.isSelected = false
        }
        
        cycleButtons[index].isSelected = true
        
        let width: CGFloat = (self.view.frame.width - 40) / CGFloat(cycleButtons.count)
        
        selectionBarX.constant = 20 + width * CGFloat((index))
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
