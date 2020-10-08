//
//  EndPointType.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

protocol EndPointType{
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}


