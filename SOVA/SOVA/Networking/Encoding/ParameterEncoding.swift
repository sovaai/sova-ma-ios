//
//  ParameterEncoding.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

public typealias Parameters = [String: Any?]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum NetworkError: String, Error {
    case parametersNill = "Parameters were nil"
    case encodingFaild = "Parameter encoding failed"
    case missingURL = "URL is nil"
}
