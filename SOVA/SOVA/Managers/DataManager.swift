//
//  DataManager.swift
//  SOVA
//
//  Created by Мурат Камалов on 05.10.2020.
//

import Foundation


//SingleTon 
class DataManager{
    static var shared =  DataManager()
    
    var assistantsId: [String] {
        guard self._assitantsId == nil else { return self._assitantsId!}
        self._assitantsId = UserDefaults.standard.value(forKey: "assistantsIds") as? [String] ?? []
        return self._assitantsId ?? []
    }
    
    var _assitantsId: [String]? = nil {
        didSet{
            UserDefaults.standard.setValue(self._assitantsId, forKey: "assistantsIds")
        }
    }
    
    var currentAssistants: Assitant {
        get{
            guard self._currentAssistants == nil else {
                return self._currentAssistants!
            }
            guard let assistantId = UserDefaults.standard.value(forKey: "currentAssistantsId") as? String else {
                //поставить деолтного бота
                let url = URL(string: "https://vk.com/feed")! //FIXME: ВЕРНУТЬ ПОСЛЕ ТЕСТА!
                let model = Assitant(name: "name", url: url, token: 12345, wordActive: false)
                if self._assitantsId == nil {
                    self._assitantsId = []
                }
                self._assitantsId?.append(model.id)
                self._currentAssistants = model
                model.save()
                return self._currentAssistants!
            }
            self._currentAssistants = self.get(by: assistantId)
            return self._currentAssistants!
        }
    }
    
    var _currentAssistants : Assitant? = nil {
        didSet{
            guard self._currentAssistants != nil else { self._currentAssistants = oldValue; return }
            UserDefaults.standard.setValue(self._currentAssistants?.id, forKey: "currentAssistantsId")
            self._messageList = nil
            NotificationCenter.default.post(name: NSNotification.Name.init("MessagesUpdate"), object: nil, userInfo: nil)
        }
    }
    
    var messageList: [MessageList] {
        get{
            guard self._messageList == nil else { return self._messageList!}
            self._messageList = self.currentAssistants.messageListId.compactMap{self.get(by: $0)}
            self._messageList?.sort{$0.date > $1.date}
            return self._messageList!
        }
    }
    
    var _messageList: [MessageList]? = nil
    
    func get(by id: String) -> Assitant?{
        let decoder = JSONDecoder()
        guard let assitantData = UserDefaults.standard.object(forKey: id) as? Data,
              let assitant = try? decoder.decode(Assitant.self, from: assitantData) else { return nil }
        return assitant
    }
    
    func get(by Id: String) -> MessageList?{
        let decoder = JSONDecoder()
        guard let listData = UserDefaults.standard.object(forKey: Id) as? Data,
              let list = try? decoder.decode(MessageList.self, from: listData) else { return nil }
        return list
    }
    
    func saveNew(_ message: Message){
        var ml: MessageList
        if self.messageList.isEmpty == false, self.messageList[0].date.asInt == message.date.asInt {
            ml = self.messageList[0]
            ml.messages.append(message)
            self._messageList![0] = ml
        }else{
            ml = MessageList()
            ml.save()
            ml.messages.append(message)
            self._messageList?.insert(ml, at: 0)
        }
        ml.save()
        
    }
    
    private init(){}
}
