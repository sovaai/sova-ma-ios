//
//  Array.swift
//  SOVA
//
//  Created by Мурат Камалов on 09.10.2020.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension Dictionary{
    var jsonData: Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self )
        } catch {
            return nil
        }
    }
}
