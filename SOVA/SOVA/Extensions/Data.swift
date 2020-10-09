//
//  Data.swift
//  SOVA
//
//  Created by Мурат Камалов on 09.10.2020.
//

import Foundation

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension Data {
    
    var jsonDictionary: [String:Any]? {
        guard self.count > 0 else { return [String:Any]() }
        do {
            return try JSONSerialization.jsonObject(with: self ) as? [String:Any]
        } catch {
            return nil
        }
    }
}
