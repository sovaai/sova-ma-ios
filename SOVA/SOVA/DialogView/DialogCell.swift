//
//  DialogCell.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit
import Foundation

extension DialogViewController{
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
            backgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            backgroundView.layer.cornerRadius = 17
            return backgroundView
        }()
        
        private var leftConstraint: NSLayoutConstraint!
        private var rightConstraint: NSLayoutConstraint!
        
        private var rightLabelConstrint: NSLayoutConstraint!
        private var leftLabelContraint: NSLayoutConstraint!
        
        private var bottomLine = UIView()
            
        private var sender: WhosMessage = .user{
            didSet{
                self.leftLabelContraint.constant = self.sender == .user ? 16 : 0
                self.rightLabelConstrint.constant = self.sender == .user ? 0 : -16
                self.leftConstraint.isActive = self.sender != .user
                self.rightConstraint.isActive = self.sender == .user
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.contentView.addSubview(messageBackground)
            self.messageBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
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
        

        func configure(with message: Message){
            self.sender = message.sender
            
            self.messageBackground.backgroundColor = self.sender.backgroundColor
            self.bottomLine.backgroundColor = self.sender.backgroundColor
            
            self.messageLabel.textColor = self.sender.messageColor
            self.messageLabel.text = message.title
            
            self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
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



