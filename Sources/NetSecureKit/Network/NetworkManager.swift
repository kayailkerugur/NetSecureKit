//
//  NetworkManager.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 22.01.2025.
//

import Foundation

public final class NetworkManager {
    
    @MainActor public static func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type, completion: @escaping @Sendable (Result<T, NetworkError>) -> Void) {
        do {
            let request = try endpoint.urlRequest()
            
            Logger.shared.log(message: "\(request.url?.absoluteString ?? "") linkine ağ isteği gönderildi")

            let task = SSLChecker.shared.createSession().dataTask(with: request) { data, response, error in
                if #available(iOS 13.0, *) {
                    Task { @MainActor in
                        if let error = error {
                            Logger.shared.log(message: "Hata meydana geldi \(error.localizedDescription)")
                            completion(.failure(.custom(error)))
                            return
                        }
                        
                        guard let data = data else {
                            Logger.shared.log(message: "Data bulunamadı")
                            completion(.failure(.noData))
                            return
                        }
                        
                        do {
                            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                            Logger.shared.log(message: "Veri Alındı")
                            completion(.success(decodedResponse))
                        } catch {
                            Logger.shared.log(message: "decodingError")
                            completion(.failure(.decodingError))
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
            
            task.resume()
        } catch {
            completion(.failure(.custom(error)))
        }
    }
}
