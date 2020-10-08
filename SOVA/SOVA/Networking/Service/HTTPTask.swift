//
//  HTTPTask.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask{
    case request
    case requestParameters(body: Parameters?, urlParameters: Parameters?)
    
    case requestParametersAndHeaders(bodyParameters: Parameters?, urlParameters: Parameters?, aditionHeaders: HTTPHeaders?)
}
