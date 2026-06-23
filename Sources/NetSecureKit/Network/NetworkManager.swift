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
    
    public func requestWithStatusCode<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping @Sendable (Result<T, NetworkError>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest()

            let task = SSLChecker(
                sslPinningEnabled: sslPinnig,
                serverCertificateName: certificateName
            ).createSession().dataTask(with: request) { data, response, error in

                if let error = error {
                    completion(.failure(.custom(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.decodingError(data: data, statusCode: httpResponse.statusCode)))
                    return
                }

                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(.decodingError(data: data, statusCode: httpResponse.statusCode)))
                }
            }

            task.resume()
        } catch {
            completion(.failure(.custom(error)))
        }
    }
    
    public func requestAsync<T: Decodable & Sendable>(
        endpoint: Endpoint,
        responseType: T.Type
    ) async -> Result<T, NetworkError> {
        await withCheckedContinuation { continuation in
            request(endpoint: endpoint, responseType: responseType) { result in
                continuation.resume(returning: result)
            }
        }
    }
    public func requestData(
        endpoint: Endpoint,
        completion: @escaping @Sendable (Result<Data, NetworkError>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest()

            let task = SSLChecker(
                sslPinningEnabled: sslPinnig,
                serverCertificateName: certificateName
            ).createSession().dataTask(with: request) { data, response, error in

                if let error = error {
                    completion(.failure(.custom(error)))
                    return
                }

                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }

                completion(.success(data))
            }

            task.resume()
        } catch {
            completion(.failure(.custom(error)))
        }
    }
    
    public func requestEmpty(
        endpoint: Endpoint,
        completion: @escaping @Sendable (Result<Void, NetworkError>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest()

            let task = SSLChecker(
                sslPinningEnabled: sslPinnig,
                serverCertificateName: certificateName
            ).createSession().dataTask(with: request) { _, response, error in

                if let error = error {
                    completion(.failure(.custom(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.decodingError(data: Data(), statusCode: httpResponse.statusCode)))
                    return
                }

                completion(.success(()))
            }

            task.resume()
        } catch {
            completion(.failure(.custom(error)))
        }
    }
}
