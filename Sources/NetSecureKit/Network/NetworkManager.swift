//
//  NetworkManager.swift
//  NetSecureKit
//
//  Created by İlker Kaya on 22.01.2025.
//

import Foundation

public final class NetworkManager: @unchecked Sendable {
    private let logger: Logger
    
    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func request<T: Decodable>(
        endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping @Sendable (Result<T, NetworkError>) -> Void
    ) {
        do {
            let request = try endpoint.urlRequest(logger: logger)
            
            logger.log(message: "\(request.url?.absoluteString ?? "") linkine ağ isteği gönderildi")
            
            let task = SSLChecker(logger: logger).createSession().dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                if let error = error {
                    self.logger.log(message: "Hata meydana geldi: \(error.localizedDescription)")
                    completion(.failure(.custom(error)))
                    return
                }
                
                guard let data = data else {
                    self.logger.log(message: "Data bulunamadı")
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    self.logger.log(message: "Gelen veri: \(String(data: data, encoding: .utf8) ?? "Veri okunamadı")")
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    self.logger.log(message: "Veri alındı ve başarıyla çözümlendi")
                    completion(.success(decodedResponse))
                } catch {
                    self.logger.log(message: "Decoding sırasında hata: \(error.localizedDescription)")
                    completion(.failure(.decodingError))
                }
            }
            
            task.resume()
        } catch {
            logger.log(message: "İstek oluşturulurken hata: \(error.localizedDescription)")
            completion(.failure(.custom(error)))
        }
    }
}
