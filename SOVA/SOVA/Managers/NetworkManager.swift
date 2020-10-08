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
    
    private init(){}
    
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


