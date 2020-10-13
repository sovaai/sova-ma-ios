//
//  SendLogVC.swift
//  SOVA
//
//  Created by Мурат Камалов on 13.10.2020.
//

import UIKit
import MessageUI

class SendLogVC: UIViewController, MFMailComposeViewControllerDelegate {
    
   
    
    static func show(parent: UINavigationController){
        parent.pushViewController(SendLogVC(), animated: true)
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createLog()
    }
    
    
    
    
    func close(){
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

