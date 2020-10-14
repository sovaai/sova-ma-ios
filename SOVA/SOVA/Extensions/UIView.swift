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
    
    func shadowOptions(with color: UIColor = (UIColor(named: "Colors/textColor") ?? .black), opacity: Float = 0.1, shadowOffSet: CGSize = .zero, shadowRadius: CGFloat = 5.0){
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = shadowOffSet
        self.layer.shadowRadius = shadowRadius
    }
}

extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}

public extension UIApplication {

     func override(_ userInterfaceStyle: UIUserInterfaceStyle) {
         if supportsMultipleScenes {
             for connectedScene in connectedScenes {
                 if let scene = connectedScene as? UIWindowScene {
                     for window in scene.windows {
                          window.overrideUserInterfaceStyle = userInterfaceStyle
                     }
                 }
             }
         }
         else {
             for window in windows {
                 window.overrideUserInterfaceStyle = userInterfaceStyle
             }
         }
     }
 }
