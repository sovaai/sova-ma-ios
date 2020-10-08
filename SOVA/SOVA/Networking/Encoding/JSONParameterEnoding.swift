//
//  JSONParameterEnoding.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

public struct JSONParameterEncoder: ParameterEncoder {
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        do{
            let jsonasData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonasData
            guard urlRequest.value(forHTTPHeaderField: "Content-Type") == nil else { return }
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }catch{
            throw NetworkError.encodingFaild
        }
    }
}
