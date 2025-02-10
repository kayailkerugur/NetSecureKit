//
//  Endpoint.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 22.01.2025.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case custom(Error)
    case sslError
    case unknownError
}

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
    mutating func makeDataToModel<T: Codable>(model: T)
}

public struct EndpointModel: Endpoint {
    public var baseURL: String
    public var path: String
    public var method: HTTPMethod
    public var headers: [String: String]?
    public var queryParameters: [String: String]?
    public var body: Data?
    
    public init(baseURL: String, path: String, method: HTTPMethod, headers: [String : String]? = nil, queryParameters: [String : String]? = nil, model: Codable? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        if let model = model {
            self.makeDataToModel(model: model)
        }
    }
    
    mutating public func makeDataToModel<T: Codable>(model: T) {
        do {
            let modelData = try JSONEncoder().encode(model)
            self.body = modelData
        } catch {
            CapsulateLogger.addLog(functionName: #function, message: "Model dataya dönüşümü sırasında hata oluştu, hata: \(error.localizedDescription)")
        }
    }
}

extension Endpoint {
    func urlRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            CapsulateLogger.addLog(functionName: #function, message: "Geçersiz URL")

            throw NetworkError.invalidURL
        }
        
        if let queryParameters = queryParameters {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            CapsulateLogger.addLog(functionName: #function, message: "Geçersiz URL")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
}
