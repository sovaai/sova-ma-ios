//
//  NetworkManager.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager{
    static let shared = NetworkManager()
    
    private var timer: Timer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: false, block: { (_) in
        guard let messgID = DataManager.shared.currentAssistants.messageListId.last, let msgList:MessageList = DataManager.shared.get(by: messgID), let msg = msgList.messages.last else { return }
        guard Date().timeIntervalSince(msg.date) >= 120 else { return }
        let waitCount = DataManager.shared.currentAssistants.waitCount
        let context = ["context":["count":waitCount]]
        NetworkManager.shared.sendEvent(cuid: DataManager.shared.currentAssistants.cuid.string, euid: .inactive, context: context) { (answer, error) in
            guard answer != nil, error == nil else { return }
            var assist = DataManager.shared.currentAssistants
            assist.waitCount += 1
            DataManager.shared.saveAssistant(assist)
            DataManager.shared.currentAssistants.save()
            let msg = Message(text: answer!)
            DataManager.shared.saveNew(msg)
        }
    })
   
    let router = Router<AssiatantApi>()
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
    func initAssistant(uuid: String, cuid: String?, context: [String:Any]?, url: URL? = nil,
                       completion: @escaping (_ cuid: String? ,_ error: String?)->()){
        self.router.request(.initChat(uuid: uuid, cuid: cuid, context: context), mainURL: url) { data, response, error in
            
            guard error == nil else { completion(nil, "Проверьте интернет соединение".localized); return }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            let result = self.handleNetworkResponse(response)
            
            guard case .success = result else {
                guard case .failure(let networkFailureError) = result else { return }
                completion(nil, networkFailureError)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            
            guard let json = responseData.jsonDictionary,
                  let resultDict = json["result"] as? [String: Any],
                  let cuid = resultDict["cuid"] as? String else { completion(nil, "Неверный ответ сервера".localized); return }
                //                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                //                        completion(apiResponse.movies,nil)
            completion(cuid,nil)
        }
    }
    
    func sendMessage(cuid: String, message: String, context: [String: Any]? = nil, completion: @escaping (_ answer: String?,_ animation: Int?, _ error: String?)->()) {
        self.router.request(.request(cuid: cuid, text: message, context: context)) { data, response, error in
            
            guard error == nil else { completion(nil, nil, "Проверьте интернет соединение".localized); return }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            let result = self.handleNetworkResponse(response)
            
            guard case .success = result else {
                guard case .failure(let networkFailureError) = result else { return }
                completion(nil, nil, networkFailureError)
                return
            }
            
            guard let responseData = data else {
                completion(nil, nil, NetworkResponse.noData.rawValue)
                return
            }
            
            
            guard let json = responseData.jsonDictionary,
                  let resultDict = json["result"] as? [String: Any],
                  let text = resultDict["text"] as? [String: Any],
                  let value = text["value"] as? String else { completion(nil, nil, "Неверный ответ сервера".localized); return }
   
            let animation = resultDict["animation"] as? [String: Any]
            let type = animation?["type"] as? Int
            completion(value,type,nil)
            self.checkBtns(text: value)
        }
    }
    
    func sendEvent(cuid: String, euid: EventType, context: [String: Any]? = nil, completion: @escaping (_ answer: String?, _ error: String?) -> ()){
        self.router.request(.event(cuid: cuid, euid: euid.rawValue, context: context)) { (data, response, error) in
            guard error == nil else { completion(nil, "Проверьте интернет соединение".localized); return }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            let result = self.handleNetworkResponse(response)
            
            guard case .success = result else {
                guard case .failure(let networkFailureError) = result else { return }
                completion(nil, networkFailureError)
                return
            }
            
            guard let responseData = data else {
                completion(nil, NetworkResponse.noData.rawValue)
                return
            }
            
            
            guard let json = responseData.jsonDictionary,
                  let resultDict = json["result"] as? [String: Any],
                  let text = resultDict["text"] as? [String: Any],
                  let value = text["value"] as? String else { completion(nil, "Неверный ответ сервера".localized); return }
                //                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                //                        completion(apiResponse.movies,nil)
            completion(value,nil)
            self.checkBtns(text: value)
        }
    }
    
    func checkBtns(text: String, array: [String] = []){
//        var texting = [String]()
//        guard let low = text.range(of: "<userlink>")?.upperBound,
//              let upper = text.range(of: "</userlink>")?.lowerBound else {
//            NotificationCenter.default.post(name: NSNotification.Name.init("updateBtns"), object: nil, userInfo: ["btnsData":array])
//            return
//        }
//        let textBtn = text[low..<upper]
//        texting.append(String(textBtn))
//        self.checkBtns(text: String(text[upper...]), array: texting)
    }

}

enum NetworkResponse:String {
    case success = ""
    case authenticationError =  "You need to be authenticated first."
    case badRequest =           "Bad request"
    case outdated =             "The url you requested is outdated."
    case failed =                "Network request failed."
    case noData =               "Response returned with no data to decode."
    case unableToDecode =       "We could not decode the response."
}


enum EventType: String{
    case ready = "00b2fcbe-f27f-437b-a0d5-91072d840ed3"
    case inactive = "29e75851-6cae-44f4-8a9c-f6489c4dca88"
}


enum AnimationType: Int{
    case hi = 1
    case no
    case yes
    case idle
    case idk
    case startIdle
    case stopIdle
    
    var videoPath: String {
        switch self {
        case .hi:
            return "hi"
        case .no:
            return "no"
        case .yes:
            return "yes"
        case .startIdle:
            return "idle_in"
        case .idle:
            return "idle"
        case .stopIdle:
            return "idle_out"
        case .idk:
            return "idk"
        }
    }
}


