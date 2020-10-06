//
//  UIView.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import UIKit

extension UIView{
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func shadowOptions(with color: UIColor = .black, opacity: Float = 0.1, shadowOffSet: CGSize = .zero, shadowRadius: CGFloat = 5.0){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = shadowOffSet
        self.layer.shadowRadius = shadowRadius
    }
}
