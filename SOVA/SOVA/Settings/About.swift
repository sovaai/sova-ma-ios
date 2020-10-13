//
//  About.swift
//  SOVA
//
//  Created by Мурат Камалов on 13.10.2020.
//

import UIKit

class AboutVC: UIViewController{
    private var label = UILabel()
    private var textFiled = UITextView()
    
    static func show(parent: UINavigationController){
        parent.pushViewController(AboutVC(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "О приложении".localized
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 26).isActive = true
        self.label.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        
        self.label.text = "SOVA Mobile App".localized
        self.label.font = UIFont.systemFont(ofSize: 15)
        self.label.textColor = .black
        
        self.view.addSubview(self.textFiled)
        self.textFiled.translatesAutoresizingMaskIntoConstraints = false
        self.textFiled.topAnchor.constraint(equalTo: self.label.bottomAnchor, constant: 16).isActive = true
        self.textFiled.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        self.textFiled.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16).isActive = true
        self.textFiled.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.textFiled.font = UIFont.systemFont(ofSize: 15)
        self.textFiled.textColor = .black
        self.textFiled.allowsEditingTextAttributes = false
        
        self.textFiled.text = "Для современного мира сплочённость команды профессионалов требует определения и уточнения кластеризации усилий. Для современного мира укрепление и развитие внутренней структуры позволяет оценить значение новых принципов формирования материально-технической и кадровой базы. Имеется спорная точка зрения, гласящая примерно следующее: диаграммы связей объективно рассмотрены соответствующими инстанциями. Прежде всего, социально-экономическое развитие предоставляет широкие возможности для поэтапного и.".localized
    }
}


