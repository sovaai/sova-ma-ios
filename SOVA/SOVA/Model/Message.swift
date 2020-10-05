//
//  Message.swift
//  SOVA
//
//  Created by Мурат Камалов on 05.10.2020.
//

import Foundation
import UIKit

struct MessageList: Codable{
    var id: String = UUID().uuidString
    var assistantId: String
    var date: Date
    var messages: [Message]
}

struct Message: Codable {
    var id: String = UUID().uuidString
    var assistantId: String
    var date: Date
    var title: String
    var sender: WhosMessage
}

enum WhosMessage: String, Codable{
    case user
    case assistant
    
    var backgroundColor: UIColor{
        if self == .user{
            return UIColor(r: 56, g: 111, b: 254, a: 1)
        }else{
            return UIColor(r: 243, g: 243, b: 243, a: 1)
        }
    }
    
    var messageColor: UIColor{
        if self == .user{
            return UIColor(r: 255, g: 255, b: 255, a: 1)
        }else{
            return UIColor(r: 15, g: 31, b: 72, a: 1)
        }
    }
    
    var roundCorner: UIRectCorner{
        if self == .user{
            return [.topLeft,.topRight, .bottomLeft]
        }else{
            return [.topLeft,.topRight, .bottomRight]
        }
    }
    
    var rightAngle: UIRectCorner{
        if self == .user{
            return [.bottomRight]
        }else{
            return [.bottomLeft]
        }
    }
}
