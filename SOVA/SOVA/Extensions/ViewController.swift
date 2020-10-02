//
//  ViewController.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit


extension UIViewController{
    func showSimpleAlert(title: String?, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        self.present(alert, animated: true)
    }
}

extension UINavigationController{
    func pushViewController(_ viewController: UIViewController,
                            animated: Bool,
                            completion: (() -> Void)?) {
        
        DispatchQueue.main.async {
            self.pushViewController(viewController, animated: animated)

            if animated, let coordinator = self.transitionCoordinator {
                coordinator.animate(alongsideTransition: nil) { _ in
                    completion?()
                }
            } else {
                completion?()
            }
        }
    }
}
