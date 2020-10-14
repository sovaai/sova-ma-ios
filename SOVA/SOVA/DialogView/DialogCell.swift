//
//  DialogCell.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit
import Foundation

class DialogCell: UICollectionViewCell{
    
    private(set) lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    
    lazy var messageBackground: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = UIColor(named: "Colors/userColor")
        backgroundView.layer.cornerRadius = 17
        return backgroundView
    }()
    
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!
    fileprivate var topConstrint: NSLayoutConstraint!
    
    fileprivate var rightLabelConstrint: NSLayoutConstraint!
    fileprivate var leftLabelContraint: NSLayoutConstraint!
    
    fileprivate var bottomLine = UIView()
    
    public var url: URL? = nil
    
    fileprivate var sender: WhosMessage = .user{
        didSet{
            self.leftLabelContraint.constant = self.sender == .user ? 16 : 0
            self.rightLabelConstrint.constant = self.sender == .user ? 0 : -16
            self.leftConstraint.isActive = self.sender != .user
            self.rightConstraint.isActive = self.sender == .user
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
        
    }
    
    fileprivate func setUp(){
        self.contentView.addSubview(messageBackground)
        self.topConstrint = self.messageBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        self.topConstrint.isActive = true
        self.messageBackground.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: 0).isActive = true
        self.leftConstraint = self.messageBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        self.rightConstraint = self.messageBackground.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        self.messageBackground.widthAnchor.constraint(lessThanOrEqualToConstant: 257).isActive = true
        self.leftConstraint.isActive = true
        self.rightConstraint.isActive = false
        
        self.messageBackground.addSubview(self.bottomLine)
        self.bottomLine.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLine.bottomAnchor.constraint(equalTo: self.messageBackground.bottomAnchor).isActive = true
        self.bottomLine.heightAnchor.constraint(equalToConstant: 17).isActive = true
        self.rightLabelConstrint = self.bottomLine.rightAnchor.constraint(equalTo: self.messageBackground.rightAnchor)
        self.leftLabelContraint = self.bottomLine.leftAnchor.constraint(equalTo: self.messageBackground.leftAnchor)
        self.rightLabelConstrint.isActive = true
        self.leftLabelContraint.isActive = true
        
        self.messageBackground.addSubview(self.messageLabel)
        self.messageLabel.rightAnchor.constraint(lessThanOrEqualTo: messageBackground.rightAnchor, constant: -16) .isActive = true
        self.messageLabel.topAnchor.constraint(equalTo: messageBackground.topAnchor, constant: 16).isActive = true
        self.messageLabel.bottomAnchor.constraint(equalTo: messageBackground.bottomAnchor, constant: -16).isActive = true
        self.messageLabel.leftAnchor.constraint(equalTo: messageBackground.leftAnchor, constant: 16).isActive = true
    }
    
    
    func configure(with message: Message, and indent: CGFloat){
        self.sender = message.sender
        
        self.topConstrint.constant = indent
        
        self.messageBackground.backgroundColor = self.sender.backgroundColor
        self.bottomLine.backgroundColor = self.sender.backgroundColor
        
        self.messageLabel.textColor = self.sender.messageColor
        self.messageLabel.text = message.title.html2String
        
        guard let startIndex = message.title.range(of: "<a href=\"") else{ return }
        var string = message.title[startIndex.upperBound...]
        guard let endIndex = string.firstIndex(where: {$0 == "\""}) else { return }
        string = string[...endIndex]
        
        while string.first != "h" {
            string.removeFirst()
        }
        string.removeLast()
        guard let url = URL(string: String(string)) else { return }
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
}


class AnimationCell: UICollectionViewCell {
    
    private lazy var centralView = UIView()
    private lazy var rightView = UIView()
    private lazy var leftView = UIView()
    
    private var heightConstrints = [NSLayoutConstraint]()
    
    private var backgroundImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.addSubview(self.backgroundImageView)
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        self.backgroundImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.backgroundImageView.image = UIImage(named: "Menu/Bundle")
        
        self.addSubview(self.centralView)
        self.addSubview(self.leftView)
        self.leftView.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.leftView.widthAnchor.constraint(equalTo: self.leftView.heightAnchor).isActive = true
        let heightConstrint = self.leftView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrint.isActive = true
        self.heightConstrints.append(heightConstrint)
        self.leftView.rightAnchor.constraint(equalTo: self.centralView.leftAnchor, constant: -3).isActive = true
        self.leftView.backgroundColor = UIColor.rgba(15, 31, 72, 0.4)
        
        self.centralView.translatesAutoresizingMaskIntoConstraints = false
        self.centralView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.centralView.widthAnchor.constraint(equalTo: self.centralView.heightAnchor).isActive = true
        self.centralView.centerXAnchor.constraint(equalTo: self.backgroundImageView.centerXAnchor).isActive = true
        let heightConstrintCentr = self.centralView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrintCentr.isActive = true
        self.heightConstrints.append(heightConstrintCentr)
        self.centralView.backgroundColor = UIColor.rgba(15, 31, 72, 0.4)
        
        self.addSubview(self.rightView)
        self.rightView.translatesAutoresizingMaskIntoConstraints = false
        self.rightView.centerYAnchor.constraint(equalTo: self.backgroundImageView.centerYAnchor).isActive = true
        self.rightView.widthAnchor.constraint(equalTo: self.rightView.heightAnchor).isActive = true
        
        let heightConstrintRight = self.rightView.heightAnchor.constraint(equalToConstant: 4)
        heightConstrintRight.isActive = true
        self.heightConstrints.append(heightConstrintRight)
        
        self.rightView.leftAnchor.constraint(equalTo: self.centralView.rightAnchor, constant: 3).isActive = true
        
        self.rightView.backgroundColor = UIColor.rgba(15, 31, 72, 0.4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.centralView.layer.cornerRadius = self.centralView.frame.height / 2
        self.leftView.layer.cornerRadius = self.leftView.frame.height / 2
        self.rightView.layer.cornerRadius = self.rightView.frame.height / 2
    }
    
    func stopAnimate(){
        self.layer.removeAllAnimations()
    }
    
    func startAnimate(){
        UIView.animate(withDuration: 0.5) {
            self.heightConstrints[2].constant = 4
            self.heightConstrints[0].constant = 5
            self.rightView.backgroundColor = UIColor.rgba(15, 31, 72, 0.4)
            self.leftView.backgroundColor = UIColor.rgba(15, 31, 72, 1)
            self.layoutIfNeeded()
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                self.heightConstrints[0].constant = 4
                self.heightConstrints[1].constant = 5
                self.leftView.backgroundColor = UIColor.rgba(15, 31, 72, 0.4)
                self.centralView.backgroundColor = UIColor.rgba(15, 31, 72, 1)
                self.layoutIfNeeded()
            } completion: { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.heightConstrints[1].constant = 4
                    self.heightConstrints[2].constant = 5
                    self.centralView.backgroundColor = UIColor.rgba(15, 31, 72, 0.4)
                    self.rightView.backgroundColor = UIColor.rgba(15, 31, 72, 1)
                    self.layoutIfNeeded()
                } completion: { (_) in
                    self.startAnimate()
                }

            }

        }

    }
}

extension DialogViewController{
    class SimpleCell: UICollectionViewCell{
        
        private var label = UILabel()
        
        public var title: String = ""{
            didSet{
                self.label.text = self.title
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.heightAnchor.constraint(equalToConstant: 64).isActive = true
            
            self.addSubview(self.label)
            self.label.translatesAutoresizingMaskIntoConstraints = false
            self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.label.textColor = UIColor(named: "Colors/headerColor") ?? UIColor(r: 21, g: 31, b: 73, a: 0.3)
            self.label.font = UIFont.systemFont(ofSize: 12)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
}
