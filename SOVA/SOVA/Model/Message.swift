//
//  Message.swift
//  SOVA
//
//  Created by Мурат Камалов on 05.10.2020.
//

import Foundation
import UIKit

struct MessageList: Codable{
    var id: String = UUID().string
    var assistantId: String = DataManager.shared.currentAssistants.id
    var date: Date = Date()
    var messages: [Message] = []
    
    func save(){
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else { return }
        UserDefaults.standard.setValue(encoded, forKey: self.id)
        NotificationCenter.default.post(name: NSNotification.Name.init("MessagesUpdate"), object: nil, userInfo: ["Id": self.id])
        guard var assistant: Assitant = DataManager.shared.get(by: self.assistantId),
              assistant.messageListId.contains(where: {$0 == self.id}) == false else { return }
        assistant.messageListId.append(self.id)
        assistant.save()
    }
    
}

struct Message: Codable {
    var id: String = UUID().string
    var assistantId: String = DataManager.shared.currentAssistants.id
    
    var date: Date = Date()
    var title: String
    var sender: WhosMessage = .user
    
    func save(){
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else { return }
        UserDefaults.standard.setValue(encoded, forKey: self.id)
        guard var assistant: Assitant = DataManager.shared.get(by: self.assistantId),
              assistant.messageListId.contains(where: {$0 == self.id}) == false else { return }
        assistant.messageListId.append(self.id)
        assistant.save()
    }
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
