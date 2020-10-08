//
//  String.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import Foundation

extension String{
    var localized: String{
        return NSLocalizedString(self, comment: "")
    }
}

extension UUID{
    var string: String{
        return self.uuidString.lowercased()
    }
}
