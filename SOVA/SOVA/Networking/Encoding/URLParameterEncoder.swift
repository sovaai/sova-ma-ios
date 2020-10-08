//
//  URLParameterEncoder.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

public struct URLParameterEncoder: ParameterEncoder{
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty else { return }
        urlComponents.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
            
            
            urlComponents.queryItems?.append(queryItem)
        }
        
        urlRequest.url = urlComponents.url
        
    }
}
