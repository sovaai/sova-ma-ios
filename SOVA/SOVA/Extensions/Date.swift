//
//  Date.swift
//  SOVA
//
//  Created by Мурат Камалов on 06.10.2020.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    var asInt: Int{
        let components = self.get(.day, .month, .year)
        var value = (components.year ?? 0) * 10000
        value += (components.month ?? 0) * 100
        value += components.day ?? 0
        return value
    }
}
