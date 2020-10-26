//
//  SupportCell.swift
//  SOVA
//
//  Created by Мурат Камалов on 23.10.2020.
//

import UIKit

//MARK: AnimationCell
class AnimationCell: UITableViewCell {
    
    private lazy var centralView = UIView()
    private lazy var rightView = UIView()
    private lazy var leftView = UIView()
    
    private var heightConstrints = [NSLayoutConstraint]()
    
    private var backgroundImageView = UIImageView()
    
    public var isAnimateStart: Bool = false{
        didSet{
            guard oldValue != self.isAnimateStart else { return }
            if isAnimateStart{
                self.startAnimate()
            }else{
                self.stopAnimate()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "Colors/mainbacground")
        
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.backgroundImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16).isActive = true
        self.backgroundImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.backgroundImageView.image = UIImage(named: "Menu/Bundle")?.allowTinted
        self.backgroundImageView.tintColor = UIColor(named: "Colors/assisTantColor")
        
        self.addSubview(self.centralView)
        self.addSubview(self.leftView)
        self.leftView.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.leftView.widthAnchor.constraint(equalTo: self.leftView.heightAnchor).isActive = true
        let heightConstrint = self.leftView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrint.isActive = true
        self.heightConstrints.append(heightConstrint)
        self.leftView.rightAnchor.constraint(equalTo: self.centralView.leftAnchor, constant: -3).isActive = true
        self.leftView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
        
        self.centralView.translatesAutoresizingMaskIntoConstraints = false
        self.centralView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.centralView.widthAnchor.constraint(equalTo: self.centralView.heightAnchor).isActive = true
        self.centralView.centerXAnchor.constraint(equalTo: self.backgroundImageView.centerXAnchor).isActive = true
        let heightConstrintCentr = self.centralView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrintCentr.isActive = true
        self.heightConstrints.append(heightConstrintCentr)
        self.centralView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
        
        self.addSubview(self.rightView)
        self.rightView.translatesAutoresizingMaskIntoConstraints = false
        self.rightView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.rightView.widthAnchor.constraint(equalTo: self.rightView.heightAnchor).isActive = true
        
        let heightConstrintRight = self.rightView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrintRight.isActive = true
        self.heightConstrints.append(heightConstrintRight)
        
        self.rightView.leftAnchor.constraint(equalTo: self.centralView.rightAnchor, constant: 3).isActive = true
        
        self.rightView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
        
        self.layoutIfNeeded()
        self.centralView.layer.cornerRadius = self.centralView.frame.height / 2
        self.leftView.layer.cornerRadius = self.leftView.frame.height / 2
        self.rightView.layer.cornerRadius = self.rightView.frame.height / 2
        
        self.backgroundImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func stopAnimate(){
        self.layer.removeAllAnimations()
    }
    
    private func startAnimate(){
        guard self.isAnimateStart else { return }
        UIView.animate(withDuration: 0.5) {
            self.heightConstrints[2].constant = 4
            self.heightConstrints[0].constant = 5
            self.rightView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
            self.leftView.backgroundColor = UIColor(named: "Colors/assistantTextColor")
            self.layoutIfNeeded()
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.heightConstrints[0].constant = 4
                self.heightConstrints[1].constant = 5
                self.leftView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
                self.centralView.backgroundColor = UIColor(named: "Colors/assistantTextColor")
                self.layoutIfNeeded()
            } completion: { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.heightConstrints[1].constant = 4
                    self.heightConstrints[2].constant = 5
                    self.centralView.backgroundColor = UIColor(named: "Colors/assistantTextColor")?.withAlphaComponent(0.4)
                    self.rightView.backgroundColor = UIColor(named: "Colors/assistantTextColor")
                    self.layoutIfNeeded()
                } completion: { (_) in
                    self.startAnimate()
                }
            }
        }
    }
}

//MARK: SimpleCell
extension DialogViewController{
    class SimpleCell: UITableViewCell{
        
        private var label = UILabel()
        
        public var title: String = ""{
            didSet{
                self.label.text = self.title
            }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            self.backgroundColor = UIColor(named: "Colors/mainbacground")
            self.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
            self.addSubview(self.label)
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.label.textColor = UIColor(named: "Colors/headerColor") ?? UIColor(r: 21, g: 31, b: 73, a: 0.3)
            self.label.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.label.font = UIFont.systemFont(ofSize: 12)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
