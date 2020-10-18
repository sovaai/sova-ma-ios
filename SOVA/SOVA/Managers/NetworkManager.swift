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
        let assistant = DataManager.shared.currentAssistants
        let waitCount = UserDefaults.standard.value(forKey: "waitCount") as? Int ?? 0
        let context = ["context":["count":waitCount]]
        NetworkManager.shared.sendEvent(cuid: assistant.cuid.string, euid: .inactive, context: context) { (answer, error) in
            guard answer != nil, error == nil else { return }
            UserDefaults.standard.setValue(waitCount + 1, forKey: "waitCount")
            let msg = Message(title: answer!, sender: .assistant)
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
            
            guard error == nil else { completion(nil, "Please check your network connection."); return }
            
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
                  let cuid = resultDict["cuid"] as? String else { completion(nil, "Server answer is wrong".localized); return }
                //                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                //                        completion(apiResponse.movies,nil)
            completion(cuid,nil)
        }
    }
    
    func sendMessage(cuid: String, message: String, context: [String: Any]? = nil, completion: @escaping (_ answer: String? ,_ error: String?)->()) {
        self.router.request(.request(cuid: cuid, text: message, context: context)) { data, response, error in
            
            guard error == nil else { completion(nil, "Please check your network connection."); return }
            
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
                  let value = text["value"] as? String else { completion(nil, "Server answer is wrong".localized); return }
                //                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                //                        completion(apiResponse.movies,nil)
            completion(value,nil)
        }
    }
    
    func sendEvent(cuid: String, euid: EventType, context: [String: Any]? = nil, completion: @escaping (_ answer: String?, _ error: String?) -> ()){
        self.router.request(.event(cuid: cuid, euid: euid.rawValue, context: context)) { (data, response, error) in
            guard error == nil else { completion(nil, "Please check your network connection."); return }
            
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
                  let value = text["value"] as? String else { completion(nil, "Server answer is wrong".localized); return }
                //                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                //                        completion(apiResponse.movies,nil)
            completion(value,nil)
        }
    }

}

enum NetworkResponse:String {
    case success = ""
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}


enum EventType: String{
    case ready = "00b2fcbe-f27f-437b-a0d5-91072d840ed3"
    case inactive = "29e75851-6cae-44f4-8a9c-f6489c4dca88"
}
//2 минуты
