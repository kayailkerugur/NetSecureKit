//
//  NetworkManager.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 22.01.2025.
//

import Foundation

public class NetworkManager {
    public static let shared = NetworkManager()
    
    private init() {}
    
    public func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        do {
            let request = try endpoint.urlRequest()
            
            Logger.shared.log(message: "\(request.url?.absoluteString ?? "") linkine ağ isteği gönderildi")

            let task = SSLChecker.shared.createSession().dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.custom(error)))
                    Logger.shared.log(message: "Hata meydana geldi \(error.localizedDescription)")
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
                    completion(.failure(.decodingError))
                    Logger.shared.log(message: "decodingError")
                }
            }
            
            task.resume()
        } catch {
            completion(.failure(.custom(error)))
        }
    }
}
