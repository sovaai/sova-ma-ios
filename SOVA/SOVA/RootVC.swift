//
//  RootVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 20.10.2020.
//

import UIKit

class PageViewController: UIPageViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        self.setViewControllers([self.dilogVc], direction: .forward, animated: true, completion: nil)
    }
    
    private var dilogVc: DialogViewController = DialogViewController.shared
    private var animateVC: AnimateVC = AnimateVC.shared
    
    private var curentVC: UIViewController = DialogViewController.shared
    
    private var nextVC: UIViewController {
        get{
            self.curentVC = self.curentVC is DialogViewController ? self.animateVC : self.dilogVc
            return self.curentVC
        }
    }
        
}

extension PageViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return self.nextVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return self.nextVC
    }
}

extension PageViewController: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, self.curentVC is AnimateVC else { return }
        self.animateVC.configure()
    }
}
