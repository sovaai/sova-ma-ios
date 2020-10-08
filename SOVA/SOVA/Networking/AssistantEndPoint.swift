//
//  AssistantEndPoint.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

public enum AssiatantApi {
    case initChat(uuid:String, cuid:String?, context: [String:Any]?)
    case request(cuid: String, text: String, context: [String:Any]?)
    case event(cuid: String, euid: String, context: [String:Any]?)
}

extension AssiatantApi: EndPointType {
    
    var baseURL: URL {
        return DataManager.shared.currentAssistants.url
    }
    
    var path: String {
        switch self {
        case .initChat:
            return "Chat.init"
        case .request:
            return "Chat.request"
        case .event:
            return "Chat.event"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var task: HTTPTask {
        switch self {
        case .initChat(let uuid,let cuid,let context):
            return .requestParameters(body: ["uuid" : uuid, "cuid" : cuid, "context": context], urlParameters: nil)
        case .request(let cuid,let text,let context):
            return .requestParameters(body: ["cuid": cuid, "text": text, "context": context], urlParameters: nil)
        case .event(let cuid,let euid,let context):
            return .requestParameters(body: ["cuid":cuid, "euid": euid, "context": context], urlParameters: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
