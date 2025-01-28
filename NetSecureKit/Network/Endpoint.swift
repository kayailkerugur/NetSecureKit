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
} // SPM

extension Endpoint {
    func urlRequest() throws -> URLRequest {        
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            Logger.shared.log(message: "Geçersiz url")
            throw NetworkError.invalidURL
        }
        
        if let queryParameters = queryParameters {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            Logger.shared.log(message: "Geçersiz url")
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
