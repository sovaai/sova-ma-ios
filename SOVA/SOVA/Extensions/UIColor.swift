//
//  UIColor.swift
//  SOVA
//
//  Created by Мурат Камалов on 05.10.2020.
//

import UIKit

extension UIColor {
    convenience init(r: Int, g:Int, b:Int, a:CGFloat = 1 ) {
        self.init(red:   CGFloat( r )   / 255,
                  green: CGFloat( g ) / 255,
                  blue:  CGFloat( b )  / 255,
                  alpha: a )
    }
    
    static func rgba(_ r: Int,_ g:Int,_ b:Int,_ a:CGFloat = 1 ) -> UIColor{
        return UIColor.init(red:   CGFloat( r )   / 255,
                  green: CGFloat( g ) / 255,
                  blue:  CGFloat( b )  / 255,
                  alpha: a )
    }
}
