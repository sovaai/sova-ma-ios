//
//  NetworkRouter.swift
//  SOVA
//
//  Created by Мурат Камалов on 08.10.2020.
//

import Foundation

public typealias NetworkRouterCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion )
    func cancel()
}

class Router<EndPoint: EndPointType>: NetworkRouter {
    
    private var task: URLSessionTask?
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do{
            let request = try self.buildRequest(from: route)
            self.task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                completion(data,response,error)
            })
        }catch{
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest{
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = route.httpMethod.rawValue
        do{
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters, let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
            case .requestParametersAndHeaders(let bodyParameters,let urlParameters,let aditionHeaders):
                self.addAdditionalHeaders(aditionHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
            }
        }catch{
            throw error
        }
        return request
    }
    
    private func configureParameters(bodyParameters: Parameters?,urlParameters: Parameters?, request: inout URLRequest) throws {
        do{
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters{
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        }catch{
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest){
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    
}
