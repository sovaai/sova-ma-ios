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
        NotificationCenter.default.post(name: NSNotification.Name.init("MessagesUpdate"), object: nil, userInfo: ["list": DataManager.shared.messageList])
        guard var assistant: Assitant = DataManager.shared.getAssistant(by: self.assistantId),
              assistant.messageListId.contains(where: {$0 == self.id}) == false else { return }
        assistant.messageListId.append(self.id)
        assistant.save()
    }
    
    func delete(){
        UserDefaults.standard.removeObject(forKey: self.id)
        for messgae in self.messages {
            messgae.delete()
        }
    }
}

struct Message: Codable {
    var id: String = UUID().string
    var assistantId: String = DataManager.shared.currentAssistants.id
    
    var date: Date = Date()
    var text: String {
        didSet{
            self.createTitle()
        }
    }
    
    var title: String? = nil
    var sender: WhosMessage = .user
    
    public private(set) var ranges : [NSRange : String]  = [:] // возможен только у асисента
    public var conteintsLinks: Bool = true
    
    func save(){
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else { return }
        UserDefaults.standard.setValue(encoded, forKey: self.id)
        guard var assistant: Assitant = DataManager.shared.getAssistant(by: self.assistantId),
              assistant.messageListId.contains(where: {$0 == self.id}) == false else { return }
        assistant.messageListId.append(self.id)
        assistant.save()
    }
    
    func delete(){
        UserDefaults.standard.removeObject(forKey: self.id)
    }
    
    mutating func createTitle(){
        if self.sender == .user {
            self.title = self.text
        }else{
            let ranges = self.checkUserLinks(firstText: self.text.html2String, text: self.text)
            self.ranges = ranges
        }
    }
    
    private func checkUserLinks(firstText: String, text: String, ranges: [NSRange : String] = [:] ) -> [NSRange : String]{
        
        guard let low = text.range(of: "<userlink>")?.upperBound,
              let upper = text.range(of: "</userlink>")?.lowerBound,
              let upperforRemove = text.range(of: "</userlink>")?.upperBound else { return ranges}
        let textBtn = text[low..<upper]
        var rangeArray = ranges
        if let range = firstText.range(of: textBtn) {
            let rangeVal = NSRange(range, in: self.text.html2String)
            let text = self.text.html2String[range]
            rangeArray[rangeVal] = String(text)
        }
        return self.checkUserLinks(firstText: firstText,text: String(text[upperforRemove...]), ranges: rangeArray)
    }
    
    mutating func checkUrls(){
        guard self.sender != .user, let att = self.text.html2AttributedString else { return }
        let wholeRange = NSRange((att.string.startIndex...), in: att.string)
        att.enumerateAttribute(.link, in: wholeRange, options: []) { (value, range, pointee) in
            guard let url = value as? URL, var fakeURLString = url.absoluteString as? String, let rangeString = fakeURLString.range(of: "http") else{ return }
            let startIndex = rangeString.lowerBound
            fakeURLString.removeSubrange(..<startIndex)
            self.ranges[range] = fakeURLString
        }
    }
    
    init(text: String) {
        self.text = text
        self.createTitle()
    }
    
    init(text: String,sender: WhosMessage = .user) {
        self.text = text
        self.sender = sender
        self.createTitle()
        self.checkUrls()
    }
}

enum WhosMessage: String, Codable{
    case user
    case assistant
    
    var backgroundColor: UIColor{
        if self == .user{
            return UIColor(named: "Colors/userColor") ?? UIColor(r: 56, g: 111, b: 254, a: 1)
        }else{
            return UIColor(named: "Colors/assisTantColor") ?? UIColor(r: 243, g: 243, b: 243, a: 1)
        }
    }
    
    var messageColor: UIColor{
        if self == .user{
            return UIColor(r: 255, g: 255, b: 255, a: 1)
        }else{
            return UIColor(named: "Colors/assistantTextColor") ?? UIColor(r: 15, g: 31, b: 72, a: 1)
        }
    }
}
