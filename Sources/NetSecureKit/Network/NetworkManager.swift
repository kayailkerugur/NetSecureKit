//
//  NetworkManager.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 22.01.2025.
//

import Foundation

public final class NetworkManager: @unchecked Sendable {
    private var sslPinnig: Bool = false
    
    private var certificateName: String = ""
    
    public init(certificateName: String = "") {
        self.sslPinnig = true
        self.certificateName = certificateName
    }
    
    public func setSSLPinning(status: Bool) {
        self.sslPinnig = status
    }
    
    public func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping @Sendable (Result<T, NetworkError>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest()
            
            
            let task = SSLChecker(sslPinningEnabled: sslPinnig, serverCertificateName: certificateName).createSession().dataTask(with: request) { data, response, error in
                
                if let error = error {
                    completion(.failure(.custom(error)))
                    return
                }
                
                guard let data = data else {

                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)

                    completion(.success(decodedResponse))
                } catch {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    completion(.failure(.decodingError(data: data, statusCode: statusCode)))
                }
            }
            
            task.resume()
        } catch {
            completion(.failure(.custom(error)))
        }
    }
}
