//
//  UIImage.swift
//  SOVA
//
//  Created by Мурат Камалов on 07.10.2020.
//

import UIKit

extension UIImage{
    var allowTinted: UIImage{
        return self.withRenderingMode(.alwaysTemplate)
    }
}
