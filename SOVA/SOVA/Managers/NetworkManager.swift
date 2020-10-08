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
    
    func getNewMovies(uuid: String, completion: @escaping (_ movie: [Assitant]?,_ error: String?)->()){
        router.request(.initChat(uuid: "b03822f6-362d-478b-978b-bed603602d0e", cuid: nil, context: nil)) { data, response, error in
            
            guard error == nil else { completion(nil, "Please check your network connection."); return }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            let result = self.handleNetworkResponse(response)
            
            switch result {
            case .success:
                guard let responseData = data else {
                    completion(nil, NetworkResponse.noData.rawValue)
                    return
                }
                do {
                    print(responseData)
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    print(jsonData)
                    //                        let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
                    //                        completion(apiResponse.movies,nil)
                    completion(nil,nil)
                }catch {
                    print(error)
                    completion(nil, NetworkResponse.unableToDecode.rawValue)
                }
            case .failure(let networkFailureError):
                completion(nil, networkFailureError)
            }
            
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


