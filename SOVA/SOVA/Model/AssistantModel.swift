//
//  AssistantModel.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import Foundation
import UIKit

struct Assitant: Codable{
    
    static var assistantsId: [String] {
        guard self._assitantsId == nil else { return self._assitantsId!}
        self._assitantsId = UserDefaults.standard.value(forKey: "assistantsIds") as? [String] ?? []
        return self._assitantsId ?? []
    }
    
    static private var _assitantsId: [String]? = nil {
        didSet{
            UserDefaults.standard.setValue(self._assitantsId, forKey: "assistantsIds")
        }
    }
    
    static var currentAssistants: Assitant {
        get{
            guard self._currentAssistants == nil else {
                if self._currentAssistants == nil{
                    print("хуй")
                }
                return self._currentAssistants!
            }
            guard let first = self.assistantsId.first else {
                //поставить деолтного бота
                let url = URL(string: "https://vk.com/feed")! //FIXME: ВЕРНУТЬ ПОСЛЕ ТЕСТА!
                let model = Assitant(name: "name", url: url, token: 12345, wordActive: false)
                self._currentAssistants = model
                return self._currentAssistants!
            }
            self._currentAssistants = self.get(by: first)
            return self._currentAssistants!
        }
    }
    
    static var _currentAssistants : Assitant? = nil
    
    
    var id: String = UUID().uuidString
    var name: String
    var url: URL
    var token: Int
    var wordActive: Bool
    var word: String?
    
    var messageList: [MessageList] {
        get{
            let message1 = Message(assistantId: self.id, date: Date(), title: "необходимо подключить аккаунт SOVA в Настройках приложения.", sender: .assistant)
            let message2 = Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальным ассистентом 🤖 необходимо подключить аккаунт xSOVA в Настройках приложения.Чтобы начать общаться с виртуальным ассистентом 🤖 необходимо подключить аккаунт xSOVA в Настройках приложения.Чтобы начать общаться с виртуальным ассистентом 🤖 необходимо подключить аккаунт xSOVA в Настройках приложения.", sender: .user)
            let message3 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общатьЧтобы начать общаться с виртуальным ассистеся с виртуальным ассистентом 🤖", sender: .assistant)
            let message4 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message5 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начЧтобы начать общаться с виртуальным ассистеать общЧтобы начать общаться с виртуальным ассистеаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message6 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message7 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаЧтобы начать общаться с виртуальным ассистеться с виртуальным ассистентом 🤖", sender: .assistant)
            let message8 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начЧтобы начать общаться с виртуальным ассистеать оЧтобы начать общаться с виртуальным ассистебщаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message9 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message10 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message11 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начатЧтобы начать общаЧтобы начать общаться с виртуальным ассистеться с виртуальным ассистеь общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message12 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общЧтобы начать общаться с виртуальным ассистеаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message13 =  Message(assistantId: self.id, date: Date(), title: "Чтобы нЧтобы начать общаться с виртуальным ассистеачЧтобы начать общаться с виртуальным ассистеать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message14 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            let message15 =  Message(assistantId: self.id, date: Date(), title: "Чтобы начать общаться с виртуальнЧтобы начать общаться с виртуальным ассистеым ассистентом 🤖", sender: .assistant)
            let message16 =  Message(assistantId: self.id, date: Date(), title: "Чтобы нЧтобы начать общаться с виртуальным ассистеачать общаться с виртуальным ассистентом 🤖", sender: .assistant)
            
            let ml1 = MessageList(assistantId: self.id, date: Date(), messages: [message1,message2])
            let ml2 =  MessageList(assistantId: self.id, date: Date(), messages: [message3])
            let ml3 = MessageList(assistantId: self.id, date: Date(), messages: [message4,message5, message6, message7, message8, message9, message10, message11])
            let ml4 =  MessageList(assistantId: self.id, date: Date(), messages: [message11, message12, message13, message14, message15, message16])
            return [ml1, ml2, ml3, ml4]
        }
    }
    
    func save(){
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else { return }
        UserDefaults.standard.setValue(encoded, forKey: self.id)
        guard Assitant.assistantsId.contains(where: {$0 == self.id}) == false else { return }
        //Никогда не будет nil т.к до этого обращаемся к assistants, который собирает потом _assitants
        Assitant._assitantsId?.append(self.id)
    }
    
    func delete(){
        UserDefaults.standard.removeObject(forKey: self.id)
    }
    
    static func get(by id: String) -> Assitant?{
        let decoder = JSONDecoder()
        guard let assitantData = UserDefaults.standard.object(forKey: id) as? Data,
              let assitant = try? decoder.decode(Assitant.self, from: assitantData) else { return nil }
        return assitant
    }
    
    func get(){
        
    }
}
