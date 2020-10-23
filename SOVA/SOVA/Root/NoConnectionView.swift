//
//  NoConnectionView.swift
//  SOVA
//
//  Created by Мурат Камалов on 20.10.2020.
//

import UIKit

class NoInternetConnectionView: UIView{
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 40).isActive = true
        view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -40).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.437).isActive = true
        
        view.image = UIImage(named: "Menu/NoConnection")
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 24).isActive = true
        
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(r: 21,g: 31,b: 73,a: 0.5)
        label.text = "Нет интернет соединения".localized
        
        return label
    }()
    
    public func configure(with state: ConntectionState ){
        let isCorrect = state == .correct
        self.backgroundColor = isCorrect ? .clear : UIColor(named: "Colors/mainbacground")
        self.isHidden = isCorrect
        self.imageView.isHidden = isCorrect
        self.label.isHidden = isCorrect
    }
}


enum ConntectionState{
    case correct
    case incorrect
}
