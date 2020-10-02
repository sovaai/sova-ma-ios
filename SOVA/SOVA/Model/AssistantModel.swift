//
//  AssistantModel.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import Foundation

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
    
    static var currentAssistants: Assitant? = nil
    
    
    var id: String = UUID().uuidString
    var name: String
    var url: URL
    var token: Int
    var wordActive: Bool
    var word: String?
    
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
