//
//  Cashes.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//
import Foundation

enum Language: String{
    case russian = "Русский"
    case english = "English"
    case chinese = "漢字"
    
    func save(){
        UserDefaults.standard.setValue(self.rawValue, forKey: "Language")
    }
    
    static var userValue: String{
        guard let value = UserDefaults.standard.value(forKey: "Language") as? String else { return self.english.rawValue }
        return value
    }
}
