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
    
    private var _assitantsId: [String]? = nil {
        didSet{
            print("что-то не то")
        }
    }
    
    var currentAssistants: Assitant {
        get{
            guard self._currentAssistants == nil else {
                return self._currentAssistants!
            }
            guard let assistantId = UserDefaults.standard.value(forKey: "currentAssistantsId") as? String else {
                //поставить дефолтного бота
                let group = DispatchGroup()
            
                group.enter()
                self.createDefaultAssistant{
                    group.leave()
                }
                
                group.wait()
                
                return self._currentAssistants!
            }
            self._currentAssistants = self.get(by: assistantId)
            return self._currentAssistants!
        }
    }
    
    private var _currentAssistants : Assitant? = nil {
        didSet{
            print("меняем")
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
    
    private var _messageList: [MessageList]? = nil
    
    public func get(by id: String) -> Assitant?{
        let decoder = JSONDecoder()
        guard let assitantData = UserDefaults.standard.object(forKey: id) as? Data,
              let assitant = try? decoder.decode(Assitant.self, from: assitantData) else { return nil }
        return assitant
    }
    
    public func get(by Id: String) -> MessageList?{
        let decoder = JSONDecoder()
        guard let listData = UserDefaults.standard.object(forKey: Id) as? Data,
              let list = try? decoder.decode(MessageList.self, from: listData) else { return nil }
        return list
    }
    
    public func saveNew(_ message: Message){
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
    
    private func createDefaultAssistant(compition: @escaping () -> ()) {
        let url = URL(string: "https://biz.nanosemantics.ru/api/bat/nkd/json")!
        let uuid = UUID(uuidString: "b03822f6-362d-478b-978b-bed603602d0e")!
        NetworkManager.shared.initAssistant(uuid: uuid.string, cuid: nil, context: nil, url: url) { [weak self] (cuidString, error) in
            guard let self = self else { return }
            guard let cuidStr =  cuidString, let cuid = UUID(uuidString: cuidStr), error == nil else { fatalError() } //FIXME: Мы конкретно везде обосрались надо что - то делать
            let model = Assitant(name: "Лисенок".localized, url: url, uuid: uuid, cuid: cuid)
            
            self.saveAssistant(model)
            self._currentAssistants = model
            
            compition()
        }
    }
    
    public func reloadAssistantsId(){
        self._assitantsId = UserDefaults.standard.value(forKey: "assistantsIds") as? [String] ?? []
    }
    
    public func checkAnotherAssistant(_ id: String){
        guard self.currentAssistants.id != id else { return }
        UserDefaults.standard.setValue(id, forKey: "currentAssistantsId")
        self.reloadMessageList()
        NotificationCenter.default.post(name: NSNotification.Name.init("MessagesUpdate"), object: nil, userInfo: nil)
    }
    
    public func reloadMessageList(){
        self._messageList = self.currentAssistants.messageListId.compactMap{self.get(by: $0)}
        self._messageList?.sort{$0.date > $1.date}
    }
    
    public func saveAssistant(_ assistant: Assitant){
        assistant.save()
        guard self.assistantsId.contains(where: {$0 == assistant.id}) == false else { return }
        var array = self.assistantsId
        array.append(assistant.id)
        UserDefaults.standard.setValue(array, forKey: "assistantsIds")
        UserDefaults.standard.setValue(assistant.id, forKey: "currentAssistantsId")
        self.reloadAssistantsId()
        self.checkAnotherAssistant(assistant.id)
        NotificationCenter.default.post(name: NSNotification.Name.init("MessagesUpdate"), object: nil, userInfo: nil)
    }
    
    public func deleteAssistant(_ assistant: Assitant){
        defer {
            NotificationCenter.default.post(name: NSNotification.Name.init("MessagesUpdate"), object: nil, userInfo: nil)
        }
        assistant.delete()
        self._messageList = nil
        for id in assistant.messageListId{
            guard let mes: MessageList = self.get(by: id) else { continue }
            mes.delete()
        }
        guard self.currentAssistants.id == assistant.id else { return }
        UserDefaults.standard.removeObject(forKey: "currentAssistantsId")
        self._currentAssistants = nil
        guard let index = self.assistantsId.firstIndex(of: assistant.id) else { return }
        var array = self.assistantsId
        array.remove(at: index)
        UserDefaults.standard.setValue(array, forKey: "assistantsIds")
        self.reloadAssistantsId()
        guard let lastId = array.last else { return }
        self.checkAnotherAssistant(lastId)
     }
    
    func deleteAll(){
        for id in self.assistantsId  {
            guard let assistant: Assitant = self.get(by: id) else { continue }
            self.deleteAssistant(assistant)
        }
    }
    
    private init(){}
}
