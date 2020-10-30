//
//  About.swift
//  SOVA
//
//  Created by Мурат Камалов on 13.10.2020.
//

import UIKit

class AboutVC: UIViewController{
    private var textFiled = UITextView()
    
    static func show(parent: UINavigationController){
        parent.pushViewController(AboutVC(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "О приложении".localized
        
        self.view.backgroundColor =  UIColor(named: "Colors/mainbacground")
       
        self.view.addSubview(self.textFiled)
        self.textFiled.translatesAutoresizingMaskIntoConstraints = false
        self.textFiled.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26).isActive = true
        self.textFiled.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        self.textFiled.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        self.textFiled.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.textFiled.font = UIFont.systemFont(ofSize: 15)
        self.textFiled.textColor = UIColor(named: "Colors/textColor")
        self.textFiled.allowsEditingTextAttributes = false
        self.textFiled.isEditable = false
        self.textFiled.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        let string = "SOVA Mobile Application\n\n\nПриложение для iOS и Android посредством которого Пользователь получает возможность делать голосовые и текстовые запросы к виртуальным ассистентам, созданным с помощью программного обеспечения SOVA. Подробная информация о SOVA и наших продуктах доступна на сайт SOVA.ai.\n\nSOVA Mobile Application распространяется под лицензией Apache License 2.0. Ознакомиться с исходным кодом приложения можно в нашем репозитории на GitHub.\n\nПолитика конфиденциальности.\n\nВерсия приложения 1.0.0\n\n© 2020 Virtual Assistant, LLC | SOVA.ai".localized
        
        let attributedString = NSMutableAttributedString(string: string)
        guard let url = URL(string: "http://www.apache.org/licenses/LICENSE-2.0"), let url1 = URL(string: "https://dev.sova.ai/static/288a1f7b0e04cb0df492ddfb58b8e114/Policy-RU.pdf"), let gitUrl = URL(string: "https://github.com/sovaai"), let sova = URL(string: "https://sova.ai/") else { return }

        
        attributedString.setAttributes([.link: url], range: NSMakeRange(353, 18))
        attributedString.setAttributes([.link: url1], range: NSMakeRange(452, 28))
        attributedString.setAttributes([.link: gitUrl], range: NSMakeRange(428, 21))
        attributedString.setAttributes([.link: sova], range: NSMakeRange(539, 7))
        
        self.textFiled.attributedText = attributedString
    }
}


